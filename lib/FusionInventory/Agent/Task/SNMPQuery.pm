package FusionInventory::Agent::Task::SNMPQuery;

use strict;
no strict 'refs';
use warnings;

use threads;
use threads::shared;
if ($threads::VERSION > 1.32){
   threads->set_stack_size(20*8192);
}

use Data::Dumper;

use Net::SNMP qw(:snmp);
use Compress::Zlib;
use LWP::UserAgent;
use HTTP::Request::Common;
use XML::Simple;
use File::stat;

use ExtUtils::Installed;
use FusionInventory::Agent::Config;
use FusionInventory::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Agent::XML::Response::Prolog;
use FusionInventory::Agent::Network;
use FusionInventory::Agent::SNMP;

use FusionInventory::Agent::AccountInfo;

sub main {
    my ( undef ) = @_;

    my $self = {};
    bless $self;

    my $storage = new FusionInventory::Agent::Storage({
            target => {
                vardir => $ARGV[0],
            }
        });

    my $data = $storage->restore("FusionInventory::Agent");
    $self->{data} = $data;
    my $myData = $self->{myData} = $storage->restore(__PACKAGE__);

    my $config = $self->{config} = $data->{config};
    my $target = $self->{'target'} = $data->{'target'};
    my $logger = $self->{logger} = new FusionInventory::Logger ({
            config => $self->{config}
        });
    $self->{prologresp} = $data->{prologresp};

   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
   $hour  = sprintf("%02d", $hour);
   $min  = sprintf("%02d", $min);
   $yday = sprintf("%04d", $yday);
   $self->{PID} = $yday.$hour.$min;

    my $continue = 0;
    foreach my $num (@{$self->{'prologresp'}->{'parsedcontent'}->{OPTION}}) {
      if (defined($num)) {
        if ($num->{NAME} eq "SNMPQUERY") {
            $continue = 1;
            $self->{SNMPQUERY} = $num;
        }
      }
    }
    if ($continue eq "0") {
        $logger->debug("No SNMPQuery. Exiting...");
        exit(0);
    }

    if ($target->{'type'} ne 'server') {
        $logger->debug("No server. Exiting...");
        exit(0);
    }

    my $network = $self->{network} = new FusionInventory::Agent::Network ({

            logger => $logger,
            config => $config,
            target => $target,

        });

   $self->StartThreads();

   exit(0);
}


sub StartThreads {
   my ($self, $params) = @_;

   my $num_files = 1;
   my $device;
   my @devicetype;
   my $num;
   my $log;

   my $nb_threads_query = $self->{SNMPQUERY}->{PARAM}->[0]->{THREADS_QUERY};
	my $nb_core_query = $self->{SNMPQUERY}->{PARAM}->[0]->{CORE_QUERY};

   $devicetype[0] = "NETWORKING";
   $devicetype[1] = "PRINTER";

   # Send infos to server :
   my $xml_thread = {};
   $xml_thread->{QUERY} = "SNMPQUERY";
   $xml_thread->{DEVICEID} = $self->{target}->{deviceid};
   $xml_thread->{CONTENT}->{AGENT}->{START} = '1';
   $xml_thread->{CONTENT}->{AGENT}->{AGENTVERSION} = $self->{config}->{VERSION};
   $xml_thread->{CONTENT}->{PROCESSNUMBER} = $self->{SNMPQUERY}->{PARAM}->[0]->{PID};
   $self->SendInformations($xml_thread);
   undef($xml_thread);

	#===================================
	# Threads et variables partagées
	#===================================
   my %TuerThread : shared;
	my %ArgumentsThread :shared;
   my $devicelist = {};
   my %devicelist2 : shared;
   my $modelslist = {};
   my $authlist = {};
	my @Thread;

	$ArgumentsThread{'id'} = &share([]);
	$ArgumentsThread{'log'} = &share([]);
	$ArgumentsThread{'Bin'} = &share([]);
	$ArgumentsThread{'PID'} = &share([]);

   # Dispatch devices to different core
   my @i;
   my $nbip = 0;
   my @countnb;
   my $core_counter = 0;

   for($core_counter = 0 ; $core_counter < $nb_core_query ; $core_counter++) {
      $countnb[$core_counter] = 0;
      $devicelist2{$core_counter} = &share({});
   }

   $core_counter = 0;
   if (defined($self->{SNMPQUERY}->{DEVICE})) {
      if (ref($self->{SNMPQUERY}->{DEVICE}) eq "HASH"){
         #if (keys (%{$data->{DEVICE}}) eq "0") {
         for (@devicetype) {
            if ($self->{SNMPQUERY}->{DEVICE}->{TYPE} eq $_) {
               if (ref($self->{SNMPQUERY}->{DEVICE}) eq "HASH"){
                  if ($core_counter eq $nb_core_query) {
                     $core_counter = 0;
                  }
                  $devicelist->{$core_counter}->{$countnb[$core_counter]} = {
                                 ID             => $self->{SNMPQUERY}->{DEVICE}->{ID},
                                 IP             => $self->{SNMPQUERY}->{DEVICE}->{IP},
                                 TYPE           => $self->{SNMPQUERY}->{DEVICE}->{TYPE},
                                 AUTHSNMP_ID    => $self->{SNMPQUERY}->{DEVICE}->{AUTHSNMP_ID},
                                 MODELSNMP_ID   => $self->{SNMPQUERY}->{DEVICE}->{MODELSNMP_ID}
                              };
                  $devicelist2{$core_counter}{$countnb[$core_counter]} = $countnb[$core_counter];
                  $countnb[$core_counter]++;
                  $core_counter++;
               } else {
                  foreach $num (@{$self->{SNMPQUERY}->{DEVICE}->{$_}}) {
                     if ($core_counter eq $nb_core_query) {
                        $core_counter = 0;
                     }
                     #### MODIFIER
                     $devicelist->{$core_counter}->{$countnb[$core_counter]} = $num;
                     $devicelist2{$core_counter}[$countnb[$core_counter]] = $countnb[$core_counter];
                     $countnb[$core_counter]++;
                     $core_counter++;
                  }
               }
            }
         }
      } else {
         foreach $device (@{$self->{SNMPQUERY}->{DEVICE}}) {
            if (defined($device)) {
               if (ref($device) eq "HASH"){
                  if ($core_counter eq $nb_core_query) {
                     $core_counter = 0;
                  }
                  #### MODIFIER
                  $devicelist->{$core_counter}->{$countnb[$core_counter]} = {
                                 ID             => $device->{ID},
                                 IP             => $device->{IP},
                                 TYPE           => $device->{TYPE},
                                 AUTHSNMP_ID    => $device->{AUTHSNMP_ID},
                                 MODELSNMP_ID   => $device->{MODELSNMP_ID}
                              };
                  $devicelist2{$core_counter}{$countnb[$core_counter]} = $countnb[$core_counter];
                  $countnb[$core_counter]++;
                  $core_counter++;
               } else {
                  foreach $num (@{$device}) {
                     if ($core_counter eq $nb_core_query) {
                        $core_counter = 0;
                     }
                     #### MODIFIER
                     $devicelist->{$core_counter}->{$countnb[$core_counter]} = $num;
                     $devicelist2{$core_counter}[$countnb[$core_counter]] = $countnb[$core_counter];
                     $countnb[$core_counter]++;
                     $core_counter++;
                  }
               }
            }
         }
      }
   }

   # Models SNMP
   $modelslist = ModelParser($self->{SNMPQUERY});

   # Auth SNMP
   $authlist = AuthParser($self->{SNMPQUERY});

   my $pm;

   #============================================
	# Begin ForkManager (multiple core / process)
	#============================================
   my $max_procs = $nb_core_query*$nb_threads_query;
   if ($nb_core_query > 1) {
      use Parallel::ForkManager;
      $pm=new Parallel::ForkManager($max_procs);
   }

   my $xml_Thread : shared = '';
   my %xml_out : shared;
   my $sendXML :shared = 0;
   for(my $p = 0; $p < $nb_core_query; $p++) {
      if ($nb_core_query > 1) {
   		my $pid = $pm->start and next;
      }
#      write_pid();
      # Création des threads
      $TuerThread{$p} = &share([]);

      for(my $j = 0 ; $j < $nb_threads_query ; $j++) {
         $TuerThread{$p}[$j]    = 0;					# 0 : thread en vie, 1 : thread se termine
      }
      #==================================
      # Prepare in variables devices to query
      #==================================
      $ArgumentsThread{'id'}[$p] = &share([]);
      $ArgumentsThread{'Bin'}[$p] = &share([]);
      $ArgumentsThread{'log'}[$p] = &share([]);
      $ArgumentsThread{'PID'}[$p] = &share([]);

      my $i = 0;
      my $Bin;
      while ($i < $nb_threads_query) {
         $ArgumentsThread{'Bin'}[$p][$i] = $Bin;
         $ArgumentsThread{'log'}[$p][$i] = $log;
         $ArgumentsThread{'PID'}[$p][$i] = $self->{PID};
         $i++;
      }
      #===================================
      # Create all Threads
      #===================================
      for(my $j = 0; $j < $nb_threads_query; $j++) {
         $Thread[$p][$j] = threads->create( sub {
                                                   my $p = shift;
                                                   my $t = shift;
                                                   my $devicelist = shift;
                                                   my $modelslist = shift;
                                                   my $authlist = shift;
                                                   my $PID = shift;

                                                   my $device_id;
                                                   my $xml_thread = {};
                                                   my $count = 0;
                                                   my $xmlout;
                                                   my $xml;
                                                   my $data_compressed;

                                                   #$xml_thread->{CONTENT}->{AGENT}->{DEVICEID}; # Key
                                                   # PID ?
                                                   #

                                                   BOUCLET: while (1) {
                                                      #print "Thread\n";
                                                      # Lance la procédure et récupère le résultat
                                                      $device_id = "";

                                                      {
                                                         lock %devicelist2;
                                                         if (keys %{$devicelist2{$p}} ne "0") {
                                                            my @keys = sort keys %{$devicelist2{$p}};
                                                            $device_id = pop @keys;
                                                            delete $devicelist2{$p}{$device_id};
                                                         } else {
                                                            last BOUCLET;
                                                         }
                                                      }
                                                      #print Dumper($devicelist->{$device_id});
                                                      my $datadevice = query_device_threaded(
                                                         $devicelist->{$device_id},
                                                         $ArgumentsThread{'log'}[$p][$t],
                                                         $ArgumentsThread{'Bin'}[$p][$t],
                                                         $ArgumentsThread{'PID'}[$p][$t],
                                                         $self->{config}->{VERSION},
                                                         $modelslist->{$devicelist->{$device_id}->{MODELSNMP_ID}}, # Passer uniquement le modèlle correspondant au device, ex : $modelslist->{'1'}
                                                         $authlist->{$devicelist->{$device_id}->{AUTHSNMP_ID}}
                                                         );
                                                         print Dumper($datadevice);
                                                      #undef $devicelist[$p]{$device_id};
                                                      $xml_thread->{CONTENT}->{DEVICE}->[$count] = $datadevice;
                                                      $xml_thread->{CONTENT}->{PROCESSNUMBER} = $self->{SNMPQUERY}->{PARAM}->[0]->{PID};
                                                      $count++;
                                                      if ($count eq "4") { # Send all of 4 devices
                                                         $xml_thread->{QUERY} = "SNMPQUERY";
                                                         $self->SendInformations($xml_thread);
                                                         $TuerThread{$p}[$t] = 1;
                                                         $count = 0;
                                                      }
                                                   }
                                                   $xml_thread->{QUERY} = "SNMPQUERY";
                                                   $self->SendInformations($xml_thread);
                                                   $TuerThread{$p}[$t] = 1;
                                                   return;
                                                }, $p, $j, $devicelist->{$p},$modelslist,$authlist,$self->{PID})->detach();
         sleep 1;
      }

      my $exit = 0;
      while($exit eq "0") {
         sleep 2;
         my $count = 0;
         for(my $i = 0 ; $i < $nb_threads_query ; $i++) {
            if ($TuerThread{$p}[$i] eq "1") {
               $count++;
            }
            if ( $count eq $nb_threads_query ) {
               $exit = 1;
            }
         }
      }

      if ($nb_core_query > 1) {
         $pm->finish;
      }
	}
   if ($nb_core_query > 1) {
   	$pm->wait_all_children;
   }

   # Send infos to server :
   undef($xml_thread);
   $xml_thread->{QUERY} = "SNMPQUERY";
   $xml_thread->{CONTENT}->{AGENT}->{END} = '1';
   $xml_thread->{CONTENT}->{PROCESSNUMBER} = $self->{SNMPQUERY}->{PARAM}->[0]->{PID};
   $self->SendInformations($xml_thread);
   undef($xml_thread);

}


sub SendInformations{
   my ($self, $message) = @_;

   my $config = $self->{config};
   my $target = $self->{'target'};
   my $logger = $self->{logger};

   my $network = $self->{network};

   if ($config->{stdout}) {
      $message->printXML();
   } elsif ($config->{local}) {
      $message->writeXML();
   } elsif ($config->{server}) {

      my $xmlout = new XML::Simple(
                           RootName => 'REQUEST',
                           NoAttr => 1,
                           KeyAttr => [],
                           suppressempty => 1
                        );
      my $xml = $xmlout->XMLout($message);
      if (($xml ne "") && ($xml ne "<REQUEST>
  <QUERY>SNMPQUERY</QUERY>
</REQUEST>")){
         my $data_compressed = Compress::Zlib::compress($xml);
         send_snmp_http2($data_compressed,$self->{PID},$config->{'server'});
      }
   }
}

sub AuthParser {
   #my ($self, $dataAuth) = @_;
my $dataAuth = shift;
   my $authlist = {};
   if (ref($dataAuth->{AUTHENTICATION}) eq "HASH"){
      $authlist->{$dataAuth->{AUTHENTICATION}->{ID}} = {
               COMMUNITY      => $dataAuth->{AUTHENTICATION}->{COMMUNITY},
               VERSION        => $dataAuth->{AUTHENTICATION}->{VERSION},
               USERNAME       => $dataAuth->{AUTHENTICATION}->{USERNAME},
               AUTHPASSWORD   => $dataAuth->{AUTHENTICATION}->{AUTHPASSPHRASE},
               AUTHPROTOCOL   => $dataAuth->{AUTHENTICATION}->{AUTHPROTOCOL},
               PRIVPASSWORD   => $dataAuth->{AUTHENTICATION}->{PRIVPASSPHRASE},
               PRIVPROTOCOL   => $dataAuth->{AUTHENTICATION}->{PRIVPROTOCOL}
            };
   } else {
      foreach my $num (@{$dataAuth->{AUTHENTICATION}}) {
         $authlist->{ $num->{ID} } = {
               COMMUNITY      => $num->{COMMUNITY},
               VERSION        => $num->{VERSION},
               USERNAME       => $num->{USERNAME},
               AUTHPASSWORD   => $num->{AUTHPASSPHRASE},
               AUTHPROTOCOL   => $num->{AUTHPROTOCOL},
               PRIVPASSWORD   => $num->{PRIVPASSPHRASE},
               PRIVPROTOCOL   => $num->{PRIVPROTOCOL}
            };
      }
   }
   return $authlist;
}


sub ModelParser {
   my $dataModel = shift;

   my $modelslist = {};
   my $lists;
   if (ref($dataModel->{MODEL}) eq "HASH"){
      foreach $lists (@{$dataModel->{MODEL}->{GET}}) {
         $modelslist->{$dataModel->{MODEL}->{ID}}->{GET}->{$lists->{OBJECT}} = {
                     OBJECT   => $lists->{OBJECT},
                     OID      => $lists->{OID},
                     VLAN     => $lists->{VLAN}
                  };
      }
      undef $lists;
      foreach $lists (@{$dataModel->{MODEL}->{WALK}}) {
         $modelslist->{$dataModel->{MODEL}->{ID}}->{WALK}->{$lists->{OBJECT}} = {
                     OBJECT   => $lists->{OBJECT},
                     OID      => $lists->{OID},
                     VLAN     => $lists->{VLAN}
                  };
      }
      undef $lists;
   } else {
      foreach my $num (@{$dataModel->{MODEL}}) {
         foreach my $list ($num->{GET}) {
            if (ref($list) eq "HASH") {

            } else {
               foreach my $lists (@{$list}) {
                  $modelslist->{ $num->{ID} }->{GET}->{$lists->{OBJECT}} = {
                        OBJECT   => $lists->{OBJECT},
                        OID      => $lists->{OID},
                        VLAN     => $lists->{VLAN}
                     };
               }
            }
         }
         undef $lists;
         foreach my $list ($num->{WALK}) {
            if (ref($list) eq "HASH") {

            } else {
               foreach my $lists (@{$list}) {
                  $modelslist->{ $num->{ID} }->{WALK}->{$lists->{OBJECT}} = {
                          OBJECT   => $lists->{OBJECT},
                          OID      => $lists->{OID},
                          VLAN     => $lists->{VLAN}
                        };
               }
            }
         }
         undef $lists;
      }
   }
         print Dumper($modelslist);
   return $modelslist;
}



sub send_snmp_http {
	my $data_compressed = shift;
	my $PID = shift;
	my $config = shift;

 	my $url = $config;
	# Must send file and not by POST
	my $userAgent = LWP::UserAgent->new();
	my $response = $userAgent->post($url, [
	'upload' => '1',
	'data' => [ undef, $PID.'.xml.gz', Content => $data_compressed ],
	'md5_gzip' => '567894'],
	'content_type' => 'multipart/form-data');

	print $response->error_as_HTML . "\n" if $response->is_error;
}

sub send_snmp_http2 {
	my $data_compressed = shift;
	my $PID = shift;
	my $config = shift;

   my $req = HTTP::Request->new(POST => $config);
   $req->header('Pragma' => 'no-cache', 'Content-type',
      'application/x-compress');

   $req->content($data_compressed);
   my $req2 = LWP::UserAgent->new(keep_alive => 1);
   my $res = $req2->request($req);

   # Checking if connected
   if(!$res->is_success) {
      print "PROBLEM\n";
      return;
   }
}



sub query_device_threaded {
	my $device = shift;
	my $log = shift;
	my $Bin = shift;
	my $PID = shift;
	my $agent_version = shift;
   my $modelslist = shift;
   my $authlist = shift;

# GESTION DES VLANS : CISCO
# .1.3.6.1.4.1.9.9.68.1.2.2.1.2 = vlan id
#
# vtpVlanName	.1.3.6.1.4.1.9.9.46.1.3.1.1.4.1
#

   my $ArraySNMPwalk = {};
   my $HashDataSNMP = {};
   my $datadevice = {};

	#threads->yield;
print $device->{IP}."\n";
	############### SNMP Queries ###############
   my $session = new FusionInventory::Agent::SNMP ({

               version      => $authlist->{VERSION},
               hostname     => $device->{IP},
               community    => $authlist->{COMMUNITY},
               username     => $authlist->{USERNAME},
               authpassword => $authlist->{AUTHPASSWORD},
               authprotocol => $authlist->{AUTHPROTOCOL},
               privpassword => $authlist->{PRIVPASSWORD},
               privprotocol => $authlist->{PRIVPROTOCOL},
               translate    => 1,

            });
	if (!defined($session->{SNMPSession}->{session})) {
		#debug($log,"[".$device->{IP}."] Error on connection","",$PID,$Bin);
		#print("SNMP ERROR: %s.\n", $error);
#      $datadevice->{ERROR}->{ID} = $device->{ID};
#      $datadevice->{ERROR}->{TYPE} = $device->{TYPE};
#      $datadevice->{ERROR}->{MESSAGE} = $error;
print "SNMP HS\n";
		return $datadevice;
	}
   my $session2 = new FusionInventory::Agent::SNMP ({

               version      => $authlist->{VERSION},
               hostname     => $device->{IP},
               community    => $authlist->{COMMUNITY},
               username     => $authlist->{USERNAME},
               authpassword => $authlist->{AUTHPASSWORD},
               authprotocol => $authlist->{AUTHPROTOCOL},
               privpassword => $authlist->{PRIVPASSWORD},
               privprotocol => $authlist->{PRIVPROTOCOL},
               translate    => 0,

            });


	my $error = '';
	# Query for timeout #
	my $description = $session->snmpget({
                     oid => '.1.3.6.1.2.1.1.1.0',
                     up  => 1,
                  });
	my $insertXML = '';
	if ($description =~ m/No response from remote host/) {
		$error = "No response from remote host";
		#debug($log,"[".$device->{IP}."] $error","",$PID,$Bin);
      $datadevice->{ERROR}->{ID} = $device->{ID};
      $datadevice->{ERROR}->{TYPE} = $device->{TYPE};
      $datadevice->{ERROR}->{MESSAGE} = $error;
		return $datadevice;
	} else {
		# Query SNMP get #
      for my $key ( keys %{$modelslist->{GET}} ) {
         if ($modelslist->{GET}->{$key}->{VLAN} eq "0") {
            my $oid_result = $session->snmpget({
                     oid => $modelslist->{GET}->{$key}->{OID},
                     up  => 1,
                  });
print $modelslist->{GET}->{$key}->{OID}." = ".$oid_result."\n";
            if (defined $oid_result
               && $oid_result ne ""
               && $oid_result ne "noSuchObject") {
               $HashDataSNMP->{$key} = $oid_result;
            }
         }
      }
      $datadevice->{INFO}->{ID} = $device->{ID};
      $datadevice->{INFO}->{TYPE} = $device->{TYPE};
      # Conversion
      ($datadevice, $HashDataSNMP) = ConstructDataDeviceSimple($HashDataSNMP,$datadevice);
#print Dumper($HashDataSNMP);
      print "DATADEVICE GET ========================\n";
print Dumper($datadevice);

      # Query SNMP walk #
      my $vlan_query = 0;
      for my $key ( keys %{$modelslist->{WALK}} ) {
         my $ArraySNMPwalk = {};
         $ArraySNMPwalk = $session->snmpwalk({
                        oid_start => $modelslist->{WALK}->{$key}->{OID}
                     });
         print Dumper($ArraySNMPwalk);
         $HashDataSNMP->{$key} = $ArraySNMPwalk;
         if ($modelslist->{WALK}->{$key}->{VLAN} eq "1") {
            $vlan_query = 1;
         }
      }
      # Conversion

      ($datadevice, $HashDataSNMP) = ConstructDataDeviceMultiple($HashDataSNMP,$datadevice);
#      print "DATADEVICE WALK ========================\n";

# print Dumper($datadevice);
# print Dumper($HashDataSNMP);

      if ($datadevice->{INFO}->{TYPE} eq "NETWORKING") {
         # Scan for each vlan (for specific switch manufacturer && model)
         # Implique de recréer une session spécialement pour chaque vlan : communauté@vlanID
         if ($vlan_query eq "1") {
            while ( (my $vlan_id,my $vlan_name) = each (%{$HashDataSNMP->{'vtpVlanName'}}) ) {
               for my $link ( keys %{$modelslist->{WALK}} ) {
                  if ($modelslist->{WALK}->{$link}->{VLAN} eq "1") {
                     $ArraySNMPwalk = {};
                     $ArraySNMPwalk = snmpwalk($modelslist->{WALK}->{$link}->{OID});
                     $HashDataSNMP->{VLAN}->{$vlan_id}->{$link} = $ArraySNMPwalk;
                  }
               }
               # Detect mac adress on each port
               if ($datadevice->{INFO}->{COMMENTS} =~ /Cisco/) {
                  ($datadevice, $HashDataSNMP) = Cisco_GetMAC($HashDataSNMP,$datadevice,$vlan_id);
               }
               delete $HashDataSNMP->{VLAN}->{$vlan_id};
            }
         } else {
            if ($datadevice->{INFO}->{COMMENTS} =~ /3Com IntelliJack/) {
               ($datadevice, $HashDataSNMP) = threecom_GetMAC($HashDataSNMP,$datadevice);
            }
         }
      }
      #print Dumper($datadevice);
      #print Dumper($HashDataSNMP);
	}
	#debug($log,"[".$device->{infos}->{ip}."] : end Thread", "",$PID,$Bin);
   return $datadevice;
}



sub special_char {
   if (defined($_[0])) {
      if ($_[0] =~ /0x$/) {
         return "";
      }
      $_[0] =~ s/([\x80-\xFF])//g;
      return $_[0];
   } else {
      return "";
   }
}


sub ConstructDataDeviceSimple {
   my $HashDataSNMP = shift;
   my $datadevice = shift;

   if (exists $HashDataSNMP->{macaddr}) {
      my @array = split(/(\S{2})/, $HashDataSNMP->{macaddr});
      $datadevice->{INFO}->{MAC} = $array[3].":".$array[5].":".$array[7].":".$array[9].":".$array[11].":".$array[13];
      delete $HashDataSNMP->{macaddr};
   }
   if (exists $HashDataSNMP->{cpuuser}) {
      $datadevice->{INFO}->{CPU} = $HashDataSNMP->{'cpuuser'} + $HashDataSNMP->{'cpusystem'};
      delete $HashDataSNMP->{'cpuuser'};
      delete $HashDataSNMP->{'cpusystem'};
   }
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cpu','INFO','CPU');
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'location','INFO','LOCATION');
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'firmware','INFO','FIRMWARE');
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'contact','INFO','CONTACT');
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'comments','INFO','COMMENTS');
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'uptime','INFO','UPTIME');
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'serial','INFO','SERIAL');
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'name','INFO','NAME');
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'model','INFO','MODEL');
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'entPhysicalModelName','INFO','MODEL');
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'enterprise','INFO','MANUFACTURER');
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'otherserial','INFO','OTHERSERIAL');
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'memory','INFO','MEMORY');
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'ram','INFO','RAM');

   if ($datadevice->{INFO}->{TYPE} eq "PRINTER") {
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesblack','CARTRIDGES','BLACK');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesblackphoto','CARTRIDGES','BLACKPHOTO');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgescyan','CARTRIDGES','CYAN');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesyellow','CARTRIDGES','YELLOW');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesmagenta','CARTRIDGES','MAGENTA');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgescyanlight','CARTRIDGES','CYANLIGHT');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesmagentalight','CARTRIDGES','MAGENTALIGHT');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesphotoconductor','CARTRIDGES','PHOTOCONDUCTOR');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorblack','CARTRIDGES','PHOTOCONDUCTORBLACK');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorcolor','CARTRIDGES','PHOTOCONDUCTORCOLOR');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorcyan','CARTRIDGES','PHOTOCONDUCTORCYAN');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesphotoconductoryellow','CARTRIDGES','PHOTOCONDUCTORYELLOW');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesphotoconductormagenta','CARTRIDGES','PHOTOCONDUCTORMAGENTA');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesunittransfertblack','CARTRIDGES','UNITTRANSFERBLACK');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesunittransfertcyan','CARTRIDGES','UNITTRANSFERCYAN');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesunittransfertyellow','CARTRIDGES','UNITTRANSFERYELLOW');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesunittransfertmagenta','CARTRIDGES','UNITTRANSFERMAGENTA');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgeswaste','CARTRIDGES','WASTE');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesfuser','CARTRIDGES','FUSER');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesbeltcleaner','CARTRIDGES','BELTCLEANER');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgesmaintenancekit','CARTRIDGES','MAINTENANCEKIT');

      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'pagecountertotalpages','PAGECOUNTERS','TOTAL');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'pagecounterblackpages','PAGECOUNTERS','BLACK');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'pagecountercolorpages','PAGECOUNTERS','COLOR');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'pagecounterrectoversopages','PAGECOUNTERS','RECTOVERSO');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'pagecounterscannedpages','PAGECOUNTERS','SCANNED');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'pagecountertotalpages_print','PAGECOUNTERS','PRINTTOTAL');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'pagecounterblackpages_print','PAGECOUNTERS','PRINTBLACK');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'pagecountercolorpages_print','PAGECOUNTERS','PRINTCOLOR');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'pagecountertotalpages_copy','PAGECOUNTERS','COPYTOTAL');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'pagecounterblackpages_copy','PAGECOUNTERS','COPYBLACK');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'pagecountercolorpages_copy','PAGECOUNTERS','COPYCOLOR');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'pagecountertotalpages_fax','PAGECOUNTERS','FAXTOTAL');

      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesblackMAX','cartridgesblackREMAIN',
                                                         'CARTRIDGE','BLACK');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgescyanMAX','cartridgescyanREMAIN',
                                                         'CARTRIDGE','CYAN');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesyellowMAX','cartridgesyellowREMAIN',
                                                         'CARTRIDGE','YELLOW');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesmagentaMAX','cartridgesmagentaREMAIN',
                                                         'CARTRIDGE','MAGENTA');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgescyanlightMAX','cartridgescyanlightREMAIN',
                                                         'CARTRIDGE','CYANLIGHT');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesmagentalightMAX','cartridgesmagentalightREMAIN',
                                                         'CARTRIDGE','MAGENTALIGHT');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorMAX','cartridgesphotoconductorREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTOR');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorblackMAX','cartridgesphotoconductorblackREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORBLACK');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorcolorMAX','cartridgesphotoconductorcolorREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORCOLOR');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorcyanMAX','cartridgesphotoconductorcyanREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORCYAN');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductoryellowMAX','cartridgesphotoconductoryellowREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORYELLOW');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductormagentaMAX','cartridgesphotoconductormagentaREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORMAGENTA');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesunittransfertblackMAX','cartridgesunittransfertblackREMAIN',
                                                         'CARTRIDGE','UNITTRANSFERBLACK');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesunittransfertcyanMAX','cartridgesunittransfertcyanREMAIN',
                                                         'CARTRIDGE','UNITTRANSFERCYAN');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesunittransfertyellowMAX','cartridgesunittransfertyellowREMAIN',
                                                         'CARTRIDGE','UNITTRANSFERYELLOW');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesunittransfertmagentaMAX','cartridgesunittransfertmagentaREMAIN',
                                                         'CARTRIDGE','UNITTRANSFERMAGENTA');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgeswasteMAX','cartridgeswasteREMAIN',
                                                         'CARTRIDGE','WASTE');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesfuserMAX','cartridgesfuserREMAIN',
                                                         'CARTRIDGE','FUSER');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesbeltcleanerMAX','cartridgesbeltcleanerREMAIN',
                                                         'CARTRIDGE','BELTCLEANER');
      ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,'cartridgesmaintenancekitMAX','cartridgesmaintenancekitREMAIN',
                                                         'CARTRIDGE','MAINTENANCEKIT');
   }
   return $datadevice, $HashDataSNMP;
}


sub ConstructDataDeviceMultiple {
   my $HashDataSNMP = shift;
   my $datadevice = shift;

   if (exists $HashDataSNMP->{ipAdEntAddr}) {
      my $i = 0;
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ipAdEntAddr}}) ) {
         $datadevice->{INFO}->{IPS}->{IP}->[$i] = $data;
         $i++;
      }
      delete $HashDataSNMP->{ipAdEntAddr};
   }
   if (exists $HashDataSNMP->{ifIndex}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ifIndex}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFNUMBER} = $data;
      }
      delete $HashDataSNMP->{ifIndex};
   }
   if (exists $HashDataSNMP->{ifdescr}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ifdescr}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFDESCR} = $data;
      }
      delete $HashDataSNMP->{ifdescr};
   }
   if (exists $HashDataSNMP->{ifName}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ifName}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFNAME} = $data;
      }
      delete $HashDataSNMP->{ifName};
   }
   if (exists $HashDataSNMP->{ifType}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ifType}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFTYPE} = $data;
      }
      delete $HashDataSNMP->{ifType};
   }
   if (exists $HashDataSNMP->{ifmtu}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ifmtu}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFMTU} = $data;
      }
      delete $HashDataSNMP->{ifmtu};
   }
   if (exists $HashDataSNMP->{ifspeed}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ifspeed}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFSPEED} = $data;
      }
      delete $HashDataSNMP->{ifspeed};
   }
   if (exists $HashDataSNMP->{ifstatus}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ifstatus}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFSTATUS} = $data;
      }
      delete $HashDataSNMP->{ifstatus};
   }
   if (exists $HashDataSNMP->{ifinternalstatus}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ifinternalstatus}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFINTERNALSTATUS} = $data;
      }
      delete $HashDataSNMP->{ifinternalstatus};
   }
   if (exists $HashDataSNMP->{iflastchange}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{iflastchange}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFLASTCHANGE} = $data;
      }
      delete $HashDataSNMP->{iflastchange};
   }
   if (exists $HashDataSNMP->{ifinoctets}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ifinoctets}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFINOCTETS} = $data;
      }
      delete $HashDataSNMP->{ifinoctets};
   }
   if (exists $HashDataSNMP->{ifoutoctets}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ifoutoctets}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFOUTOCTETS} = $data;
      }
      delete $HashDataSNMP->{ifoutoctets};
   }
   if (exists $HashDataSNMP->{ifinerrors}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ifinerrors}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFINERRORS} = $data;
      }
      delete $HashDataSNMP->{ifinerrors};
   }
   if (exists $HashDataSNMP->{ifouterrors}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ifouterrors}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFOUTERRORS} = $data;
      }
      delete $HashDataSNMP->{ifouterrors};
   }
   if (exists $HashDataSNMP->{ifPhysAddress}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{ifPhysAddress}}) ) {
         if ($data ne "") {
            my @array = split(/(\S{2})/, $data);
            $datadevice->{PORTS}->{PORT}->[$object]->{MAC} = $array[3].":".$array[5].":".$array[7].":".$array[9].":".$array[11].":".$array[13];
         }
      }
      delete $HashDataSNMP->{ifPhysAddress};
   }
   if (exists $HashDataSNMP->{portDuplex}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{portDuplex}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{IFPORTDUPLEX} = $data;
      }
      delete $HashDataSNMP->{portDuplex};
   }

   # Detect Trunk & CDP
   if (defined ($datadevice->{INFO}->{COMMENTS})) {
      if ($datadevice->{INFO}->{COMMENTS} =~ /Cisco/) {
         ($datadevice, $HashDataSNMP) = Cisco_TrunkPorts($HashDataSNMP,$datadevice);
         ($datadevice, $HashDataSNMP) = Cisco_CDPPorts($HashDataSNMP,$datadevice);
      }
   }

   # Detect VLAN
   if (exists $HashDataSNMP->{vmvlan}) {
      while ( my ($object,$data) = each (%{$HashDataSNMP->{vmvlan}}) ) {
         $datadevice->{PORTS}->{PORT}->[$object]->{VLANS}->{VLAN}->{NUMBER} = $data;
         $datadevice->{PORTS}->{PORT}->[$object]->{VLANS}->{VLAN}->{NAME} = $HashDataSNMP->{vtpVlanName}->{$data};
      }
      delete $HashDataSNMP->{vmvlan};
   }


   return $datadevice, $HashDataSNMP;
}

sub PutSimpleOid {
   my $HashDataSNMP = shift;
   my $datadevice = shift;
   my $element = shift;
   my $xmlelement1 = shift;
   my $xmlelement2 = shift;

   if (exists $HashDataSNMP->{$element}) {
      if (($element eq "ram") || ($element eq "memory")) {
         $HashDataSNMP->{$element} = int(( $HashDataSNMP->{$element} / 1024 ) / 1024);
      }
      $datadevice->{$xmlelement1}->{$xmlelement2} = $HashDataSNMP->{$element};
      delete $HashDataSNMP->{$element};
   }
   return $datadevice, $HashDataSNMP;
}

sub PutPourcentageOid {
   my $HashDataSNMP = shift;
   my $datadevice = shift;
   my $element1 = shift;
   my $element2 = shift;
   my $xmlelement1 = shift;
   my $xmlelement2 = shift;

   if (exists $HashDataSNMP->{$xmlelement1}) {
      $datadevice->{$xmlelement1}->{$xmlelement2} = int ( ( 100 * $HashDataSNMP->{$element2} )
      / $HashDataSNMP->{$element1} );
      delete $HashDataSNMP->{$element2};
      delete $HashDataSNMP->{$element1};
   }
   return $datadevice, $HashDataSNMP;
}



1;