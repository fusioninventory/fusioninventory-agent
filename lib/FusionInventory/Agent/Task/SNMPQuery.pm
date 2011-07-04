package FusionInventory::Agent::Task::SNMPQuery;

use strict;
use warnings;
use threads;
use threads::shared;
if ($threads::VERSION > 1.32){
   threads->set_stack_size(20*8192);
}
use base 'FusionInventory::Agent::Task';

use Encode qw(encode);
use File::stat;
use XML::Simple;

use FusionInventory::Agent::HTTP::Client::OCS;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::SNMP;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::XML::Query;

use FusionInventory::Agent::Task::SNMPQuery::Cisco;
use FusionInventory::Agent::Task::SNMPQuery::Procurve;
use FusionInventory::Agent::Task::SNMPQuery::ThreeCom;
use FusionInventory::Agent::Task::SNMPQuery::Nortel;

our $VERSION = '1.3';
my $maxIdx : shared = 0;

sub run {
    my ($self) = @_;

    my $config = $self->{config};
    my $target = $self->{target};
    my $logger = $self->{logger};
    $self->{logger}->debug("FusionInventory SNMPQuery module ".$VERSION);

   if ( not eval { require Net::SNMP; 1 } ) {
      $self->{logger}->debug("Can't load Net::SNMP. Exiting...");
      return;
   }

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
        $logger->debug("No SNMPQuery Asked by the server. Exiting...");
        return;
    }

    if ($target->{'type'} ne 'server') {
        $logger->debug("No server to get order from. Exiting...");
        return;
    }

      $self->{inventory} = new FusionInventory::Agent::XML::Query({

          # TODO, check if the accoun{info,config} are needed in localmode
#          accountinfo => $accountinfo,
#          accountconfig => $accountinfo,
          target => $target,
          config => $config,
          logger => $logger,

      });

   $self->StartThreads();
}


sub StartThreads {
   my ($self, $params) = @_;

   my $num_files = 1;
   my $device;
   my @devicetype;
   my $num;
   my $log;

  my $storage = $self->{storage};


   my $nb_threads_query = $self->{SNMPQUERY}->{PARAM}->[0]->{THREADS_QUERY};
	my $nb_core_query = $self->{SNMPQUERY}->{PARAM}->[0]->{CORE_QUERY};

   if ( not eval { require Parallel::ForkManager; 1 } ) {
      if ($nb_core_query > 1) {
         $self->{logger}->debug("Parallel::ForkManager not installed, so only 1 core will be used...");
         $nb_core_query = 1;      
      }
   }

   $devicetype[0] = "NETWORKING";
   $devicetype[1] = "PRINTER";

   my $xml_thread = {};

	#===================================
	# Threads et variables partagÃ©es
	#===================================
   my %TuerThread : shared;
	my %ArgumentsThread :shared;
   my $devicelist = {};
   my %devicelist2 : shared;
   my $modelslist = {};
   my $authlist = {};
	my @Thread;
   my $sentxml = {};

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
      $pm=new Parallel::ForkManager($max_procs);
   }

   if ($countnb[0] <  $nb_threads_query) {
      $nb_threads_query = $countnb[0];
   }

   my $xml_Thread : shared = '';
   my %xml_out : shared;
   my $sendXML :shared = 0;
   for(my $p = 0; $p < $nb_core_query; $p++) {
      if ($nb_core_query > 1) {
   		my $pid = $pm->start and next;
      }
#      write_pid();
      # create the threads
      $TuerThread{$p} = &share([]);
      my $sendbylwp : shared;

# 0 : thread is alive, 1 : thread is dead 
      for(my $j = 0 ; $j < $nb_threads_query ; $j++) {
         $TuerThread{$p}[$j]    = 0;
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
                                                   my $self = shift;

                                                   my $device_id;

                                                   my $xml_thread = {};                                                   
                                                   my $count = 0;
                                                   my $xmlout;
                                                   my $xml;
                                                   my $data_compressed;
                                                   my $loopthread = 0;

                                                   $self->{logger}->debug("Core $p - Thread $t created");

                                                   while ($loopthread ne "1") {
                                                      # Lance la procÃ©dure et rÃ©cupÃ¨re le rÃ©sultat
                                                      $device_id = "";
                                                      {
                                                         lock(%devicelist2);
                                                         if (keys %{$devicelist2{$p}} ne "0") {
                                                            my @keys = sort keys %{$devicelist2{$p}};
                                                            $device_id = pop @keys;
                                                            delete $devicelist2{$p}{$device_id};
                                                         } else {
                                                            $loopthread = 1;
                                                         }
                                                      }
                                                      if ($loopthread ne "1") {
                                                         my $datadevice = $self->query_device_threaded({
                                                               device              => $devicelist->{$device_id},
                                                               modellist           => $modelslist->{$devicelist->{$device_id}->{MODELSNMP_ID}},
                                                               authlist            => $authlist->{$devicelist->{$device_id}->{AUTHSNMP_ID}}
                                                            });
                                                         $xml_thread->{DEVICE}->[$count] = $datadevice;
                                                         $xml_thread->{MODULEVERSION} = $VERSION;
                                                         $xml_thread->{PROCESSNUMBER} = $self->{SNMPQUERY}->{PARAM}->[0]->{PID};
                                                         $count++;
                                                         if (($count eq "1") || (($loopthread eq "1") && ($count > 0))) {
                                                            $maxIdx++;
                                                             $storage->save({
                                                                     idx =>
                                                                     $maxIdx,
                                                                     data => $xml_thread
                                                                 });
                                                             
                                                            $count = 0;
                                                         }
                                                      }
                                                      sleep 1;
                                                   }

                                                   $TuerThread{$p}[$t] = 1;
                                                   $self->{logger}->debug("Core $p - Thread $t deleted");
                                                }, $p, $j, $devicelist->{$p},$modelslist,$authlist,$self)->detach();
         sleep 1;
      }

      my $network = $self->{network} = new FusionInventory::Agent::HTTP::Client::OCS({

               logger => $self->{logger},
               config => $self->{config},
               target => $self->{target},

           });
      push(@LWP::Protocol::http::EXTRA_SOCK_OPTS, MaxLineLength => 16*1024);

      # Send infos to server :
      my $xml_thread = {};
      $xml_thread->{AGENT}->{START} = '1';
      $xml_thread->{AGENT}->{AGENTVERSION} = $self->{config}->{VERSION};
      $xml_thread->{MODULEVERSION} = $VERSION;
      $xml_thread->{PROCESSNUMBER} = $self->{SNMPQUERY}->{PARAM}->[0]->{PID};
      $self->SendInformations({
         data => $xml_thread
         });
      undef($xml_thread);


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
         foreach my $idx (1..$maxIdx) {
            if (!defined($sentxml->{$idx})) {
                my $data = $storage->restore({
                        idx => $idx
                    });

                $self->SendInformations({
                        data => $data
                    });
                $sentxml->{$idx} = 1;
                $storage->remove({
                     idx => $idx
                  });
                sleep 1;
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

   foreach my $idx (1..$maxIdx) {
      if (!defined($sentxml->{$idx})) {
          my $data = $storage->restore({
                  idx => $idx
              });
          $self->SendInformations({
                  data => $data
              });
          $sentxml->{$idx} = 1;
          sleep 1;
       }

   }
   $storage->removeSubDumps();

   # Send infos to server :
   undef($xml_thread);
   $xml_thread->{AGENT}->{END} = '1';
   $xml_thread->{PROCESSNUMBER} = $self->{SNMPQUERY}->{PARAM}->[0]->{PID};
   sleep 1; # Wait for threads be terminated
   $self->SendInformations({
      data => $xml_thread
      });
   undef($xml_thread);

}



sub sendEndToServer() {
   my ($self) = @_;

   my $network = $self->{network} = new FusionInventory::Agent::HTTP::Client::OCS({

            logger => $self->{logger},
            config => $self->{config},
            target => $self->{target},

        });
   push(@LWP::Protocol::http::EXTRA_SOCK_OPTS, MaxLineLength => 16*1024);

   # Send infos to server :
   my $xml_thread;
   $xml_thread->{AGENT}->{END} = '1';
   $xml_thread->{PROCESSNUMBER} = $self->{SNMPQUERY}->{PARAM}->[0]->{PID};
   $self->SendInformations({
      data => $xml_thread
      });
   undef($xml_thread);
}



sub SendInformations{
   my ($self, $message) = @_;

   my $xmlMsg = FusionInventory::Agent::XML::Query->new(
           {
           config => $self->{config},
           logger => $self->{logger},
           target => $self->{target},
           msg    => {
           QUERY => 'SNMPQUERY',
           CONTENT   => $message->{data},
           },
           });
   $self->{network}->send({message => $xmlMsg});
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
   my $list;
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
         foreach $list ($num->{GET}) {
            if (ref($list) eq "HASH") {

            } else {
               foreach $lists (@{$list}) {
                  $modelslist->{ $num->{ID} }->{GET}->{$lists->{OBJECT}} = {
                        OBJECT   => $lists->{OBJECT},
                        OID      => $lists->{OID},
                        VLAN     => $lists->{VLAN}
                     };
               }
            }
            undef $lists;
         }
         foreach $list ($num->{WALK}) {
            if (ref($list) eq "HASH") {

            } else {
               foreach $lists (@{$list}) {
                  $modelslist->{ $num->{ID} }->{WALK}->{$lists->{OBJECT}} = {
                          OBJECT   => $lists->{OBJECT},
                          OID      => $lists->{OID},
                          VLAN     => $lists->{VLAN}
                        };
               }
            }
            undef $lists;
         }         
      }
   }
   return $modelslist;
}



sub query_device_threaded {
   my ($self, $params) = @_;

   my $ArraySNMPwalk = {};
   my $HashDataSNMP = {};
   my $datadevice = {};
   my $key;

	#threads->yield;
	############### SNMP Queries ###############
   my $session = new FusionInventory::Agent::SNMP ({

               version      => $params->{authlist}->{VERSION},
               hostname     => $params->{device}->{IP},
               community    => $params->{authlist}->{COMMUNITY},
               username     => $params->{authlist}->{USERNAME},
               authpassword => $params->{authlist}->{AUTHPASSWORD},
               authprotocol => $params->{authlist}->{AUTHPROTOCOL},
               privpassword => $params->{authlist}->{PRIVPASSWORD},
               privprotocol => $params->{authlist}->{PRIVPROTOCOL},
               translate    => 1,

            });
	if (!defined($session->{SNMPSession}->{session})) {
		return $datadevice;
	}
   my $session2 = new FusionInventory::Agent::SNMP ({

               version      => $params->{authlist}->{VERSION},
               hostname     => $params->{device}->{IP},
               community    => $params->{authlist}->{COMMUNITY},
               username     => $params->{authlist}->{USERNAME},
               authpassword => $params->{authlist}->{AUTHPASSWORD},
               authprotocol => $params->{authlist}->{AUTHPROTOCOL},
               privpassword => $params->{authlist}->{PRIVPASSWORD},
               privprotocol => $params->{authlist}->{PRIVPROTOCOL},
               translate    => 0,

            });


	my $error = '';
	# Query for timeout #
	my $description = $session->snmpGet({
                     oid => '.1.3.6.1.2.1.1.1.0',
                     up  => 1,
                  });
	my $insertXML = '';
	if ($description =~ m/No response from remote host/) {
		$error = "No response from remote host";
      $datadevice->{ERROR}->{ID} = $params->{device}->{ID};
      $datadevice->{ERROR}->{TYPE} = $params->{device}->{TYPE};
      $datadevice->{ERROR}->{MESSAGE} = $error;
		return $datadevice;
	} else {
		# Query SNMP get #
      if ($params->{device}->{TYPE} eq "PRINTER") {
         $params = cartridgesupport($params);
      }
      for $key ( keys %{$params->{modellist}->{GET}} ) {
         if ($params->{modellist}->{GET}->{$key}->{VLAN} eq "0") {
            my $oid_result = $session->snmpGet({
                     oid => $params->{modellist}->{GET}->{$key}->{OID},
                     up  => 1,
                  });
            if (defined $oid_result
               && $oid_result ne ""
               && $oid_result ne "noSuchObject") {
               $HashDataSNMP->{$key} = $oid_result;
            }
         }
      }
      $datadevice->{INFO}->{ID} = $params->{device}->{ID};
      $datadevice->{INFO}->{TYPE} = $params->{device}->{TYPE};
      # Conversion
      ($datadevice, $HashDataSNMP) = ConstructDataDeviceSimple($HashDataSNMP,$datadevice);


      # Query SNMP walk #
      my $vlan_query = 0;
      for $key ( keys %{$params->{modellist}->{WALK}} ) {
         $ArraySNMPwalk = $session->snmpWalk({
                        oid_start => $params->{modellist}->{WALK}->{$key}->{OID}
                     });
         $HashDataSNMP->{$key} = $ArraySNMPwalk;
         if (exists($params->{modellist}->{WALK}->{$key}->{VLAN})) {
            if ($params->{modellist}->{WALK}->{$key}->{VLAN} eq "1") {
               $vlan_query = 1;
            }
         }
      }
      # Conversion

      ($datadevice, $HashDataSNMP) = ConstructDataDeviceMultiple($HashDataSNMP,$datadevice, $self, $params->{modellist}->{WALK}->{vtpVlanName}->{OID}, $params->{modellist}->{WALK});

      if ($datadevice->{INFO}->{TYPE} eq "NETWORKING") {
         # Scan for each vlan (for specific switch manufacturer && model)
         # Implique de recrÃ©er une session spÃ©cialement pour chaque vlan : communautÃ©@vlanID
         if ($vlan_query eq "1") {
            while ( (my $vlan_id,my $vlan_name) = each (%{$HashDataSNMP->{'vtpVlanName'}}) ) {
               my $vlan_id_short = $vlan_id;
               $vlan_id_short =~ s/$params->{modellist}->{WALK}->{vtpVlanName}->{OID}//;
               $vlan_id_short =~ s/^.//;
                #Initiate SNMP connection on this VLAN
               my $session = new FusionInventory::Agent::SNMP ({

                              version      => $params->{authlist}->{VERSION},
                              hostname     => $params->{device}->{IP},
                              community    => $params->{authlist}->{COMMUNITY}."@".$vlan_id_short,
                              username     => $params->{authlist}->{USERNAME},
                              authpassword => $params->{authlist}->{AUTHPASSWORD},
                              authprotocol => $params->{authlist}->{AUTHPROTOCOL},
                              privpassword => $params->{authlist}->{PRIVPASSWORD},
                              privprotocol => $params->{authlist}->{PRIVPROTOCOL},
                              translate    => 1,

                           });
                  my $session2 = new FusionInventory::Agent::SNMP ({

                              version      => $params->{authlist}->{VERSION},
                              hostname     => $params->{device}->{IP},
                              community    => $params->{authlist}->{COMMUNITY}."@".$vlan_id_short,
                              username     => $params->{authlist}->{USERNAME},
                              authpassword => $params->{authlist}->{AUTHPASSWORD},
                              authprotocol => $params->{authlist}->{AUTHPROTOCOL},
                              privpassword => $params->{authlist}->{PRIVPASSWORD},
                              privprotocol => $params->{authlist}->{PRIVPROTOCOL},
                              translate    => 0,

                           });

               $ArraySNMPwalk = {};
               #$HashDataSNMP  = {};
               for my $link ( keys %{$params->{modellist}->{WALK}} ) {
                  if ($params->{modellist}->{WALK}->{$link}->{VLAN} eq "1") {
                     $ArraySNMPwalk = $session->snmpWalk({
                                        oid_start => $params->{modellist}->{WALK}->{$link}->{OID}
                     });
                     $HashDataSNMP->{VLAN}->{$vlan_id}->{$link} = $ArraySNMPwalk;
                  }
               }
               # Detect mac adress on each port
               if ($datadevice->{INFO}->{COMMENTS} =~ /Cisco/) {
                  ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Cisco::GetMAC($HashDataSNMP,$datadevice,$vlan_id,$self, $params->{modellist}->{WALK});
               }
               delete $HashDataSNMP->{VLAN}->{$vlan_id};
            }
         } else {
            if (defined ($datadevice->{INFO}->{COMMENTS})) {
               if ($datadevice->{INFO}->{COMMENTS} =~ /3Com IntelliJack/) {
                  $datadevice = FusionInventory::Agent::Task::SNMPQuery::ThreeCom::RewritePortOf225($datadevice, $self);
               } elsif ($datadevice->{INFO}->{COMMENTS} =~ /3Com/) {
                  ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::ThreeCom::GetMAC($HashDataSNMP,$datadevice,$self,$params->{modellist}->{WALK});
               } elsif ($datadevice->{INFO}->{COMMENTS} =~ /ProCurve/) {
                  ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Procurve::GetMAC($HashDataSNMP,$datadevice,$self, $params->{modellist}->{WALK});
               } elsif ($datadevice->{INFO}->{COMMENTS} =~ /Nortel/) {
                  ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Nortel::GetMAC($HashDataSNMP,$datadevice,$self, $params->{modellist}->{WALK});
               }
            }
         }
      }
	}
   return $datadevice;
}



sub ConstructDataDeviceSimple {
   my $HashDataSNMP = shift;
   my $datadevice = shift;
   if (exists $HashDataSNMP->{macaddr}) {
      $datadevice->{INFO}->{MAC} = $HashDataSNMP->{macaddr};
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
   ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'firmware1','INFO','FIRMWARE');
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
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'tonerblack','CARTRIDGES','TONERBLACK');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'tonerblack2','CARTRIDGES','TONERBLACK2');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'tonercyan','CARTRIDGES','TONERCYAN');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'tonermagenta','CARTRIDGES','TONERMAGENTA');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'toneryellow','CARTRIDGES','TONERYELLOW');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'wastetoner','CARTRIDGES','WASTETONER');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgeblack','CARTRIDGES','CARTRIDGEBLACK');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgeblackphoto','CARTRIDGES','CARTRIDGEBLACKPHOTO');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgecyan','CARTRIDGES','CARTRIDGECYAN');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgecyanlight','CARTRIDGES','CARTRIDGECYANLIGHT');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgemagenta','CARTRIDGES','CARTRIDGEMAGENTA');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgemagentalight','CARTRIDGES','CARTRIDGEMAGENTALIGHT');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'cartridgeyellow','CARTRIDGES','CARTRIDGEYELLOW');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'maintenancekit','CARTRIDGES','MAINTENANCEKIT');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'drumblack','CARTRIDGES','DRUMBLACK');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'drumcyan','CARTRIDGES','DRUMCYAN');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'drummagenta','CARTRIDGES','DRUMMAGENTA');
      ($datadevice, $HashDataSNMP) = PutSimpleOid($HashDataSNMP,$datadevice,'drumyellow','CARTRIDGES','DRUMYELLOW');

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
   my $self = shift;
   my $vtpVlanName_oid = shift;
   my $walkoid = shift;
   
   my $object;
   my $data;

   if (exists $HashDataSNMP->{ipAdEntAddr}) {
      my $i = 0;
      while ( ($object,$data) = each (%{$HashDataSNMP->{ipAdEntAddr}}) ) {
         $datadevice->{INFO}->{IPS}->{IP}->[$i] = $data;
         $i++;
      }
      delete $HashDataSNMP->{ipAdEntAddr};
   }
   if (exists $HashDataSNMP->{ifIndex}) {
      my $num = 0;
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifIndex}}) ) {
         $self->{portsindex}->{lastSplitObject($object)} = $num;
         $datadevice->{PORTS}->{PORT}->[$num]->{IFNUMBER} = $data;
         $num++;
      }
      delete $HashDataSNMP->{ifIndex};
   }
   if (exists $HashDataSNMP->{ifdescr}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifdescr}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFDESCR} = $data;
      }
      delete $HashDataSNMP->{ifdescr};
   }
   if (exists $HashDataSNMP->{ifName}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifName}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFNAME} = $data;
      }
      delete $HashDataSNMP->{ifName};
   }
   if (exists $HashDataSNMP->{ifType}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifType}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFTYPE} = $data;
      }
      delete $HashDataSNMP->{ifType};
   }
   if (exists $HashDataSNMP->{ifmtu}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifmtu}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFMTU} = $data;
      }
      delete $HashDataSNMP->{ifmtu};
   }
   if (exists $HashDataSNMP->{ifspeed}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifspeed}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFSPEED} = $data;
      }
      delete $HashDataSNMP->{ifspeed};
   }
   if (exists $HashDataSNMP->{ifstatus}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifstatus}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFSTATUS} = $data;
      }
      delete $HashDataSNMP->{ifstatus};
   }
   if (exists $HashDataSNMP->{ifinternalstatus}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifinternalstatus}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFINTERNALSTATUS} = $data;
      }
      delete $HashDataSNMP->{ifinternalstatus};
   }
   if (exists $HashDataSNMP->{iflastchange}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{iflastchange}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFLASTCHANGE} = $data;
      }
      delete $HashDataSNMP->{iflastchange};
   }
   if (exists $HashDataSNMP->{ifinoctets}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifinoctets}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFINOCTETS} = $data;
      }
      delete $HashDataSNMP->{ifinoctets};
   }
   if (exists $HashDataSNMP->{ifoutoctets}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifoutoctets}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFOUTOCTETS} = $data;
      }
      delete $HashDataSNMP->{ifoutoctets};
   }
   if (exists $HashDataSNMP->{ifinerrors}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifinerrors}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFINERRORS} = $data;
      }
      delete $HashDataSNMP->{ifinerrors};
   }
   if (exists $HashDataSNMP->{ifouterrors}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifouterrors}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFOUTERRORS} = $data;
      }
      delete $HashDataSNMP->{ifouterrors};
   }
   if (exists $HashDataSNMP->{ifPhysAddress}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifPhysAddress}}) ) {
         if ($data ne "") {
#            my @array = split(/(\S{2})/, $data);
#            $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{MAC} = $array[3].":".$array[5].":".$array[7].":".$array[9].":".$array[11].":".$array[13];
             $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{MAC} = $data;
         }
      }
      delete $HashDataSNMP->{ifPhysAddress};
   }
   if (exists $HashDataSNMP->{ifaddr}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifaddr}}) ) {
         if ($data ne "") {
             my $shortobject = $object;
             $shortobject =~ s/$walkoid->{ifaddr}->{OID}//;
             $shortobject =~ s/^.//;
             $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$data}]->{IP} = $shortobject;
         }
      }
      delete $HashDataSNMP->{ifaddr};
   }
   if (exists $HashDataSNMP->{portDuplex}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{portDuplex}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFPORTDUPLEX} = $data;
      }
      delete $HashDataSNMP->{portDuplex};
   }

   # Detect Trunk & CDP
   if (defined ($datadevice->{INFO}->{COMMENTS})) {
      if ($datadevice->{INFO}->{COMMENTS} =~ /Cisco/) {
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Cisco::TrunkPorts($HashDataSNMP,$datadevice, $self);
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Cisco::CDPPorts($HashDataSNMP,$datadevice, $walkoid, $self);
      } elsif ($datadevice->{INFO}->{COMMENTS} =~ /ProCurve/) {
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Cisco::TrunkPorts($HashDataSNMP,$datadevice, $self);
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Procurve::CDPLLDPPorts($HashDataSNMP,$datadevice, $walkoid, $self);
      } elsif ($datadevice->{INFO}->{COMMENTS} =~ /Nortel/) {
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Nortel::VlanTrunkPorts($HashDataSNMP,$datadevice, $self);
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Nortel::LLDPPorts($HashDataSNMP,$datadevice, $walkoid, $self);
      }
   }

   # Detect VLAN
   if (exists $HashDataSNMP->{vmvlan}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{vmvlan}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{VLANS}->{VLAN}->{NUMBER} = $data;
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{VLANS}->{VLAN}->{NAME} = $HashDataSNMP->{vtpVlanName}->{$vtpVlanName_oid.".".$data};
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
      # Rewrite hexa to string
      if (($element eq "name") || ($element eq "otherserial")) {
         $HashDataSNMP->{$element} = HexaToString($HashDataSNMP->{$element});
      }
      # End rewrite hexa to string
      if (($element eq "ram") || ($element eq "memory")) {
         $HashDataSNMP->{$element} = int(( $HashDataSNMP->{$element} / 1024 ) / 1024);
      }
      if ($element eq "serial") {
         $HashDataSNMP->{$element} =~ s/^\s+//;
         $HashDataSNMP->{$element} =~ s/\s+$//;
         $HashDataSNMP->{$element} =~ s/(\.{2,})*//g;
      }
      if ($element eq "firmware1") {
         $datadevice->{$xmlelement1}->{$xmlelement2} = $HashDataSNMP->{"firmware1"}." ".$HashDataSNMP->{"firmware2"};
         delete $HashDataSNMP->{"firmware2"};
      } elsif (($element =~ /^toner/) || ($element eq "wastetoner") || ($element =~ /^cartridge/) || ($element eq "maintenancekit") || ($element =~ /^drum/)) {
         if ($HashDataSNMP->{$element."-level"} eq "-3") {
            $datadevice->{$xmlelement1}->{$xmlelement2} = 100;
         } else {
            ($datadevice, $HashDataSNMP) = PutPourcentageOid($HashDataSNMP,$datadevice,$element."-capacitytype",$element."-level", $xmlelement1, $xmlelement2);
            #$datadevice->{$xmlelement1}->{$xmlelement2} = $HashDataSNMP->{$element."-level"};
         }
      } else {
         $datadevice->{$xmlelement1}->{$xmlelement2} = $HashDataSNMP->{$element};
      }
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
   if (exists $HashDataSNMP->{$element1}) {
      if ((is_integer($HashDataSNMP->{$element2})) && (is_integer($HashDataSNMP->{$element1})) && ($HashDataSNMP->{$element1} ne '0')) {
         $datadevice->{$xmlelement1}->{$xmlelement2} = int ( ( 100 * $HashDataSNMP->{$element2} ) / $HashDataSNMP->{$element1} );
         delete $HashDataSNMP->{$element2};
         delete $HashDataSNMP->{$element1};
      }
   }
   return $datadevice, $HashDataSNMP;
}



sub lastSplitObject {
   my $var = shift;

   my @array = split(/\./, $var);
   return $array[-1];
}


sub cartridgesupport {
   my $params = shift;

   for my $key ( keys %{$params->{modellist}->{GET}} ) {
      if (($key =~ /^toner/) || ($key eq "wastetoner") || ($key =~ /^cartridge/) || ($key eq "maintenancekit") || ($key =~ /^drum/)) {
         $params->{modellist}->{GET}->{$key."-capacitytype"}->{OID} = $params->{modellist}->{GET}->{$key}->{OID};
         $params->{modellist}->{GET}->{$key."-capacitytype"}->{OID} =~ s/43.11.1.1.6/43.11.1.1.8/;
         $params->{modellist}->{GET}->{$key."-capacitytype"}->{VLAN} = 0;

         $params->{modellist}->{GET}->{$key."-level"}->{OID} = $params->{modellist}->{GET}->{$key}->{OID};
         $params->{modellist}->{GET}->{$key."-level"}->{OID} =~ s/43.11.1.1.6/43.11.1.1.9/;
         $params->{modellist}->{GET}->{$key."-level"}->{VLAN} = 0;
      }
   }
   return $params;
}


sub is_integer {
   $_[0] =~ /^[+-]?\d+$/;
}

sub HexaToString {
   my $val = shift;

   if ($val =~ /0x/) {
      $val =~ s/0x//g;
      $val =~ s/([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/g;
      $val = encode('UTF-8', $val);
      $val =~ s/\0//g;
      $val =~ s/([\x80-\xFF])//g;
      $val =~ s/[\x00-\x1F\x7F]//g;
   }
   return $val;
}

1;
