package Ocsinventory::Agent::Task::NetDiscovery;

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
use Ocsinventory::Agent::Config;
use Ocsinventory::Logger;
use Ocsinventory::Agent::Storage;
use Ocsinventory::Agent::XML::Query::SimpleMessage;
use Ocsinventory::Agent::XML::Response::Prolog;
use Ocsinventory::Agent::Network;
use Ocsinventory::Agent::SNMP;
use Ocsinventory::Agent::Task::NetDiscovery::dico;

use Ocsinventory::Agent::AccountInfo;

sub main {
    my ( undef ) = @_;

    my $self = {};
    bless $self;

    my $storage = new Ocsinventory::Agent::Storage({
            target => {
                vardir => $ARGV[0],
            }
        });

    my $data = $storage->restore("Ocsinventory::Agent");
    $self->{data} = $data;
    my $myData = $self->{myData} = $storage->restore(__PACKAGE__);

    my $config = $self->{config} = $data->{config};
    my $target = $self->{'target'} = $data->{'target'};
    my $logger = $self->{logger} = new Ocsinventory::Logger ({
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
        if ($num->{NAME} eq "NETDISCOVERY") {
            $continue = 1;
            $self->{NETDISCOVERY} = $num;
        }
      }
    }
    if ($continue eq "0") {
        $logger->debug("No NETDISCOVERY. Exiting...");
        exit(0);
    }

    if ($target->{'type'} ne 'server') {
        $logger->debug("No server. Exiting...");
        exit(0);
    }

    my $network = $self->{network} = new Ocsinventory::Agent::Network ({

            logger => $logger,
            config => $config,
            target => $target,

        });

   $self->StartThreads();

   exit(0);
}


sub StartThreads {
   my ($self, $params) = @_;
#	my $data = $self->{'parsedcontent'}->{OPTION};

#	my $fragment = shift;
#	my $PID = shift;
#	my $log = shift;
#	my $Bin = shift;
#	my $config = shift;
#	my $agent_version = shift;
#   my $argnodisplay = shift;
#   my $agentkey = shift;   =>   $self->{config}->{deviceid}
my $Bin;
my $log;


	my $nb_threads_discovery = $self->{NETDISCOVERY}->{PARAM}->[0]->{THREADS_DISCOVERY};
	my $nb_core_discovery    = $self->{NETDISCOVERY}->{PARAM}->[0]->{CORE_DISCOVERY};


#   print "**************************************\n";
#   print "* Threads discovery : ".$nb_threads_discovery."\n";
#   print "* Core discovery : ".$nb_core_discovery."\n";
#   print "**************************************\n";

   # Send infos to server :
   my $xml_thread = {};
   $xml_thread->{QUERY} = "NETDISCOVERY";
   $xml_thread->{DEVICEID} = $self->{target}->{deviceid};
   $xml_thread->{CONTENT}->{AGENT}->{START} = '1';
   $xml_thread->{CONTENT}->{AGENT}->{AGENTVERSION} = $self->{config}->{VERSION};
   $xml_thread->{CONTENT}->{PROCESSNUMBER} = $self->{NETDISCOVERY}->{PARAM}->[0]->{PID};
   $self->SendInformations($xml_thread);
   undef($xml_thread);

   my $ModuleNmapScanner = 0;
   my $ModuleNmapParser = 0;
   my $ModuleNetNBName = 0;
   my $iplist = {};
   my $iplist2 = &share({});
   my %TuerThread;
   my %ArgumentsThread;

   eval { require Nmap::Parser; };
   if ($@) {
      eval { require Nmap::Scanner; };
      if ($@) {
         print "Can't load Nmap::Parser && map::Scanner. Nmap can't be used!";
      } else {
         $ModuleNmapScanner = 1;
      }
   } else {
      $ModuleNmapParser = 1;
   }

   eval { require Net::NBName; };
   if ($@) {
      print "Can't load Net::NBName. Netbios detection can't be used!";
   } else {
      $ModuleNetNBName = 1;
   }

   # Auth SNMP
   my $authlist = $self->AuthParser($self->{NETDISCOVERY});

   ##### Get IP to scan
   use Net::IP;

   # Dispatch IPs to different core
   my $startIP = '';

   my @i;
   my $nbip = 0;
   my $countnb;
   my $core_counter = 0;
   my $nb_ip_per_thread = 25;
   my $limitip = $nb_threads_discovery * $nb_ip_per_thread;
   my $ip;
   my $max_procs;
   my $pm;
   my $description;

   #============================================
   # Begin ForkManager (multiple core / process)
   #============================================
   $max_procs = $nb_core_discovery * $nb_threads_discovery;
   if ($nb_core_discovery > 1) {
      use Parallel::ForkManager;
      $pm=new Parallel::ForkManager($max_procs);
   }

   my @Thread;
   my $xml_Thread : shared = '';
   my %xml_out : shared;
   for(my $p = 0; $p < $nb_core_discovery; $p++) {
      if ($nb_core_discovery > 1) {
         my $pid = $pm->start and next;
      }

      my $threads_run = 0;
      my $loopip : shared = 1;
      my $exit : shared = 0;

      $iplist = &share({});


      while ($loopip eq "1") {
         $countnb = 0;
         $nbip = 0;
         $core_counter = 0;

         if ($threads_run eq "0") {
            $iplist2 = &share({});
            $iplist = &share({});
         }


         if (ref($self->{NETDISCOVERY}->{RANGEIP}) eq "HASH"){
            if ($self->{NETDISCOVERY}->{RANGEIP}->{IPSTART} eq $self->{NETDISCOVERY}->{RANGEIP}->{IPEND}) {
               if ($threads_run eq "0") {
                  $iplist->{$countnb} = &share({});
               }
               $iplist->{$countnb}->{IP} = $self->{NETDISCOVERY}->{RANGEIP}->{IPSTART};
               $iplist->{$countnb}->{ENTITY} = $self->{NETDISCOVERY}->{RANGEIP}->{ENTITY};
               $iplist2->{$countnb} = $countnb;
               $countnb++;
               $nbip++;
            } else {
               $ip = new Net::IP ($self->{NETDISCOVERY}->{RANGEIP}->{IPSTART}.' - '.$self->{NETDISCOVERY}->{RANGEIP}->{IPEND});
               do {
                  if ($threads_run eq "0") {
                     $iplist->{$countnb} = &share({});
                  }
                  $iplist->{$countnb}->{IP} = $ip->ip();
                  $iplist->{$countnb}->{ENTITY} = $self->{NETDISCOVERY}->{RANGEIP}->{ENTITY};
                  $iplist2->{$countnb} = $countnb;
                  $countnb++;
                  $nbip++;
                  if ($nbip eq $limitip) {
                     if ($ip->ip() ne $self->{NETDISCOVERY}->{RANGEIP}->{IPEND}) {
                        $self->{NETDISCOVERY}->{RANGEIP}->{IPSTART} = $ip->ip();
                        goto CONTINUE;
                     }
                  }
               } while (++$ip);
               undef $self->{NETDISCOVERY}->{RANGEIP};
            }
         } else {
            foreach my $num (@{$self->{NETDISCOVERY}->{RANGEIP}}) {
               if ($num->{IPSTART} eq $num->{IPEND}) {
                  if ($threads_run eq "0") {
                     $iplist->{$countnb} = &share({});
                  }
                  $iplist->{$countnb}->{IP} = $num->{IPSTART};
                  $iplist->{$countnb}->{ENTITY} = $num->{ENTITY};
                  $iplist2->{$countnb} = $countnb;
                  $countnb++;
                  $nbip++;
               } else {
                  if ($num->{IPSTART} ne "") {
                     $ip = new Net::IP ($num->{IPSTART}.' - '.$num->{IPEND});
                     do {
                        if ($threads_run eq "0") {
                           $iplist->{$countnb} = &share({});
                        }
                        $iplist->{$countnb}->{IP} = $ip->ip();
                        $iplist->{$countnb}->{ENTITY} = $num->{ENTITY};
                        $iplist2->{$countnb} = $countnb;
                        $countnb++;
                        $nbip++;
                        if ($nbip eq $limitip) {
                           if ($ip->ip() ne $num->{IPEND}) {
                              $num->{IPSTART} = $ip->ip();
                              goto CONTINUE;
                           }
                        }
                     } while (++$ip);
                     undef $ip;
                     $num->{IPSTART} = "";
                  }
               }
            }
         }
         $loopip = 0;

         if ($nbip > ($nb_ip_per_thread * 4)) {
            
         } elsif ($nbip > $nb_ip_per_thread) {
            $nb_threads_discovery = int($nbip / $nb_ip_per_thread) + 4;
         } else {
            $nb_threads_discovery = $nbip;
         }

         CONTINUE:
         # Send NB ips to server :
         $xml_thread = {};
         $xml_thread->{QUERY} = "NETDISCOVERY";
         $xml_thread->{CONTENT}->{AGENT}->{NBIP} = $nbip;
         $xml_thread->{CONTENT}->{PROCESSNUMBER} = $self->{NETDISCOVERY}->{PARAM}->[0]->{PID};
         $self->SendInformations($xml_thread);
         undef($xml_thread);

         if ($threads_run eq "0") {
            #write_pid();
            # CrÃ©ation des threads
            $TuerThread{$p} = &share([]);
         }

         for(my $j = 0 ; $j < $nb_threads_discovery ; $j++) {
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

         while ($i < $nb_threads_discovery) {
            $ArgumentsThread{'Bin'}[$p][$i] = $Bin;
            $ArgumentsThread{'log'}[$p][$i] = $log;
            $ArgumentsThread{'PID'}[$p][$i] = $self->{PID};
            $i++;
         }
         #===================================
         # Create Thread management others threads
         #===================================
         $exit = 2;

         if ($threads_run eq "0") {
            my $Threadmanagement = threads->create( sub {
                                                      $nb_threads_discovery = shift;

                                                      $exit = 0;

                                                      BOUCLETMANAGE: while($exit eq "0") {
                                                         sleep 2;
                                                         my $count = 0;
                                                         for(my $i = 0 ; $i < $nb_threads_discovery ; $i++) {
                                                            if ($TuerThread{$p}[$i] eq "1") {
                                                               $count++;
                                                            }
                                                            if ($TuerThread{$p}[$i] eq "2") {
                                                               $count++;
                                                            }
                                                            if ( $count eq $nb_threads_discovery ) {
                                                               $exit = 1;
                                                            }
                                                         }
                                                      }
                                                      if ($loopip eq "1") {
                                                         while($exit ne "2") {
                                                            sleep 1;
                                                         }
                                                         for(my $i = 0 ; $i < $nb_threads_discovery ; $i++) {
                                                            $TuerThread{$p}[$i] = "0";
                                                         }
                                                         $exit = 0;
                                                         goto BOUCLETMANAGE;
                                                      }
                                                      return;
                                                   }, $nb_threads_discovery)->detach();


            #===================================
            # Create all Threads
            #===================================
            my $k = 0;
            for(my $j = 0; $j < $nb_threads_discovery; $j++) {
               $threads_run = 1;
               $k++;
               $Thread[$p][$j] = threads->create( sub {
                                                         my $p = shift;
                                                         my $t = shift;
                                                         my $authlist = shift;

                                                         my $device_id;
                                                         my $xml_thread = {};
                                                         my $count = 0;

                                                         BOUCLET: while (1) {
                                                            #print "Thread\n";
                                                            # Lance la procÃ©dure et rÃ©cupÃ¨re le rÃ©sultat
                                                            $device_id = "";
                                                            {
                                                               lock $iplist2;
                                                               if (keys %{$iplist2} ne "0") {
                                                                  my @keys = sort keys %{$iplist2};
                                                                  $device_id = pop @keys;
                                                                  delete $iplist2->{$device_id};
                                                               } else {
                                                                  last BOUCLET;
                                                               }
                                                            }
                                                            my $datadevice = discovery_ip_threaded(
                                                                  $iplist->{$device_id},
                                                                  $ArgumentsThread{'log'}[$p][$t],
                                                                  $ArgumentsThread{'Bin'}[$p][$t],
                                                                  $ArgumentsThread{'PID'}[$p][$t],
                                                                  $self->{config}->{VERSION},
                                                                  $authlist,
                                                                  $ModuleNmapScanner,
                                                                  $ModuleNetNBName,
                                                                  $ModuleNmapParser
                                                               );
                                                            undef $iplist->{$device_id}->{IP};
                                                            undef $iplist->{$device_id}->{ENTITY};
                                                            if (keys %{$datadevice}) {
                                                               $xml_thread->{CONTENT}->{DEVICE}->[$count] = $datadevice;
                                                               $xml_thread->{DEVICEID} = $self->{target}->{deviceid};
                                                               $xml_thread->{CONTENT}->{PROCESSNUMBER} = $self->{NETDISCOVERY}->{PARAM}->[0]->{PID};
                                                               $count++;
                                                            }
                                                         }
                                                         $xml_thread->{QUERY} = "NETDISCOVERY";
                                                         #if (($count > 0) && (!empty($xml_thread))) {
                                                         if ($count > 0) {
                                                            $self->SendInformations($xml_thread);
                                                         }
                                                         if ($loopip eq "1") {
                                                            $TuerThread{$p}[$t] = 2;
                                                            while ($TuerThread{$p}[$t] eq "2") {
                                                               sleep 1;
                                                            }
                                                            goto BOUCLET;
                                                         } else {
                                                            $TuerThread{$p}[$t] = 1;
                                                         }
                                                         return;
                                                      }, $p, $j, $authlist)->detach();
               if ($k eq "2") {
                  sleep 1;
                  $k = 0;
               }
            }
         }
        while($exit ne "1") {
           sleep 2;
        }
      } # End loopip
     if ($nb_core_discovery > 1) {
         $pm->finish;
      }
   }
   if ($nb_core_discovery > 1) {
      $pm->wait_all_children;
   }

   # Send infos to server :
   undef($xml_thread);
   $xml_thread->{QUERY} = "NETDISCOVERY";
   $xml_thread->{CONTENT}->{AGENT}->{END} = '1';
   $xml_thread->{CONTENT}->{PROCESSNUMBER} = $self->{NETDISCOVERY}->{PARAM}->[0]->{PID};
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
      if ($xml ne "") {
         my $data_compressed = Compress::Zlib::compress($xml);
         send_snmp_http2($data_compressed,$self->{PID},$config->{'server'});
      }
   }
}

sub AuthParser {
   my ($self, $dataAuth) = @_;

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
   if ($response->content eq "Impossible to copy file in ../../../files/_plugins/tracker/") {
      ErrorCode('1002');
      delete_pid();
      exit;
   }
	#print $response->content."\n";
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


sub discovery_ip_threaded {
   my $ip = shift;
   my $log = shift;
	my $Bin = shift;
	my $PID = shift;
	my $agent_version = shift;
   my $authlist = shift;
   my $ModuleNmapScanner = shift;
   my $ModuleNetNBName = shift;
   my $ModuleNmapParser = shift;
   my $datadevice = {};

   my $entity=0;

   #** Nmap discovery
   if ($ModuleNmapParser eq "1") {
      my $scan = new Nmap::Parser;
      $scan->parsescan('nmap','-sP --system-dns --max-retries 1 --max-rtt-timeout 1000 ', $ip->{IP});
      if (exists($scan->{HOSTS}->{$ip->{IP}}->{addrs}->{mac}->{addr})) {
         $datadevice->{MAC} = special_char($scan->{HOSTS}->{$ip->{IP}}->{addrs}->{mac}->{addr});
      }
      if (exists($scan->{HOSTS}->{$ip->{IP}}->{addrs}->{mac}->{vendor})) {
         $datadevice->{NETPORTVENDOR} = special_char($scan->{HOSTS}->{$ip->{IP}}->{addrs}->{mac}->{vendor});
      }

      if (exists($scan->{HOSTS}->{$ip->{IP}}->{hostnames}->[0]->{name})) {
         $datadevice->{DNSHOSTNAME} = special_char($scan->{HOSTS}->{$ip->{IP}}->{hostnames}->[0]->{name});
      }
   } elsif ($ModuleNmapScanner eq "1") {
      my $scan = new Nmap::Scanner;
      my $results_nmap = $scan->scan('-sP --system-dns --max-retries 1 --max-rtt-timeout 1000 '.$ip->{IP});

      my $xml_nmap = new XML::Simple;
      my $macaddress = "";
      my $hostname = "";
      my $netportvendor = "";

      foreach my $key (keys (%{$$results_nmap{'ALLHOSTS'}})) {
         for (my $n=0; $n<@{$$results_nmap{'ALLHOSTS'}{$key}{'addresses'}}; $n++) {
            if ($$results_nmap{'ALLHOSTS'}{$key}{'addresses'}[$n]{'addrtype'} eq "mac") {
               $datadevice->{MAC} = special_char($$results_nmap{'ALLHOSTS'}{$key}{'addresses'}[$n]{'addr'});
               if (defined($$results_nmap{'ALLHOSTS'}{$key}{'addresses'}[$n]{'vendor'})) {
                  $datadevice->{NETPORTVENDOR} = special_char($$results_nmap{'ALLHOSTS'}{$key}{'addresses'}[$n]{'vendor'});
               }
            }
         }
         if (exists($$results_nmap{'ALLHOSTS'}{$key}{'hostnames'}[0])) {
            for (my $n=0; $n<@{$$results_nmap{'ALLHOSTS'}{$key}{'hostnames'}}; $n++) {
               $datadevice->{DNSHOSTNAME} = special_char($$results_nmap{'ALLHOSTS'}{$key}{'hostnames'}[$n]{'name'});
            }
         }
      }
   }

   #** Netbios discovery
   if ($ModuleNetNBName eq "1") {
      my $nb = Net::NBName->new;

      my $domain = "";
      my $user = "";
      my $machine = "";
      my $type = 0;

      my $ns = $nb->node_status($ip->{IP});
      if ($ns) {
         for my $rr ($ns->names) {
             if ($rr->suffix == 0 && $rr->G eq "GROUP") {
               $datadevice->{WORKGROUP} = special_char($rr->name);
             }
             if ($rr->suffix == 3 && $rr->G eq "UNIQUE") {
               $datadevice->{USERSESSION} = special_char($rr->name);
             }
             if ($rr->suffix == 0 && $rr->G eq "UNIQUE") {
                 $machine = $rr->name unless $rr->name =~ /^IS~/;
                 $datadevice->{NETBIOSNAME} = special_char($machine);
                 $type = 1;
             }
         }
      }
   }

#my $clock2 = [gettimeofday];
#print "[".$ip->{IP}."] NetBios : ".tv_interval($clock2, $clock1)."\n";

   #threads->yield;
   my $i = 4;
   my $snmpv;
   while ($i ne "1") {
      $i--;
      $snmpv = $i;
      if ($i eq "2") {
         $snmpv = "2c";
      }
      for my $key ( keys %{$authlist} ) {
         if ($authlist->{$key}->{VERSION} eq $snmpv) {
            my $session = new Ocsinventory::Agent::SNMP ({

               version      => $authlist->{$key}->{VERSION},
               hostname     => $ip->{IP},
               community    => $authlist->{$key}->{COMMUNITY},
               username     => $authlist->{$key}->{USERNAME},
               authpassword => $authlist->{$key}->{AUTHPASSWORD},
               authprotocol => $authlist->{$key}->{AUTHPROTOCOL},
               privpassword => $authlist->{$key}->{PRIVPASSWORD},
               privprotocol => $authlist->{$key}->{PRIVPROTOCOL},
               translate    => 1,

            });

            if (!defined($session->{SNMPSession}->{session})) {
               #print("SNMP ERROR: %s.\n", $error);
#               print "[".$ip->{IP}."] GNERROR ()".$authlist->{$key}->{VERSION}."\n";
            } else {
#            print Dumper($session);
            #print "[".$ip->{IP}."] GNE () \n";
               my $description = $session->snmpget({
                     oid => '1.3.6.1.2.1.1.1.0',
                     up  => 1,
                  });
               if ($description =~ m/No response from remote host/) {
                  #print "[".$ip->{IP}."][NO][".$authlist->{$key}->{VERSION}."][".$authlist->{$key}->{COMMUNITY}."]\n";
                  #$session->close;
               } elsif ($description =~ m/No buffer space available/) {
                  #print "[".$ip->{IP}."][NO][".$authlist->{$key}->{VERSION}."][".$authlist->{$key}->{COMMUNITY}."]\n";
                  #$session->close;
               } elsif ($description ne "null") {
                  #print "[".$ip->{IP}."][YES][".$authlist->{$key}->{VERSION}."][".$authlist->{$key}->{COMMUNITY}."]\n";

                  # ***** manufacturer specifications
                  # If HP printer detected, get best sysDescr
                  $description = hp_discovery($description, $session);

                  # If Wyse thin clients
                  $description = wyse_discovery($description, $session);
                  #$description = cisco_discovery($description);

                  # If Samsung printer detected, get best sysDescr
                  $description = samsung_discovery($description, $session);

                  # If Epson printer detected, get best sysDescr
                  $description = epson_discovery($description, $session);

                  # If Altacel switch detected, get best sysDescr
                  $description = alcatel_discovery($description, $session);

                  # If Kyocera printer detected, get best sysDescr
                  $description = kyocera_discovery($description, $session);

                  $datadevice->{DESCRIPTION} = $description;

                  my $name = $session->snmpget({
                        oid => '.1.3.6.1.2.1.1.5.0',
                        up  => 1,
                     });
                  if ($name eq "null") {
                     $name = "";
                  }
                  # Serial Number
                  my ($serial, $type, $model, $mac) = verifySerial($description, $session);
                  if ($serial eq "Received noSuchName(2) error-status at error-index 1") {
                     $serial = '';
                  }
                  if ($serial eq "noSuchInstance") {
                     $serial = '';
                  }
                  if ($serial eq "noSuchObject") {
                     $serial = '';
                  }
                  if ($serial eq "No response from remote host") {
                     $serial = '';
                  }
                  $datadevice->{SERIAL} = $serial;
                  $datadevice->{MODELSNMP} = $model;
                  $datadevice->{AUTHSNMP} = $key;
                  $datadevice->{TYPE} = $type;
                  $datadevice->{SNMPHOSTNAME} = $name;
                  $datadevice->{IP} = $ip->{IP};
                  $datadevice->{MAC} = $mac;
                  $datadevice->{ENTITY} = $entity;
                  #$session->close;
                  return $datadevice;
       #           return constructxmlDiscovery($description, $name, $serial, $ip, $type,$entity,$model,$$authSNMP_discovery{$key}{'ID'},$macaddress,$hostname,$domain,$user,$machine,$netportvendor);
               } else {
                  #debug($log,"[".$ip."][NO][".$$authSNMP_discovery{$key}{'version'}."][".$$authSNMP_discovery{$key}{'community'}."] ".$session->error, "",$PID,$Bin);
                  $session->close;
               }
            }
         }
      }
   }

#my $clock3 = [gettimeofday];
#print "[".$ip->{IP}."] SNMP : ".tv_interval($clock3, $clock2)."\n";

   if ((exists($datadevice->{MAC})) || (exists($datadevice->{DNSHOSTNAME})) || (exists($datadevice->{NETBIOSNAME}))) {
      $datadevice->{IP} = $ip->{IP};
      $datadevice->{ENTITY} = $entity;
   }
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



sub verifySerial {
   my $description = shift;
   my $session     = shift;

   my $oid;
   my $macreturn = '';
   my $modelreturn = '';
   my $serial;
   my $serialreturn = '';

   my $xmlDico = Ocsinventory::Agent::Task::NetDiscovery::dico::loadDico();
   foreach my $num (@{$xmlDico->{DEVICE}}) {
      if ($num->{SYSDESCR} =~ /sasyamal/){
            print Dumper($num->{SYSDESCR});
         }
      if ($num->{SYSDESCR} eq $description) {
         
         if (defined($num->{SERIAL})) {
            $oid = $num->{SERIAL};
				$serial = $session->snmpget({
                     oid => $oid,
                     up  => 1,
                  });
         }
         if (defined($serial)) {
            $serialreturn = $serial;
         }
         my $typereturn  = $num->{TYPE};
         if (defined($num->{MODELSNMP})) {
            $modelreturn = $num->{MODELSNMP};
         }
         if (defined($num->{MAC})) {
            $oid = $num->{MAC};
            $macreturn  = $session->snmpget({
                        oid => $oid,
                        up  => 1,
                     });
         }

			return ($serialreturn, $typereturn, $modelreturn, $macreturn);
      }
   }
	return ("", 0, "", "");
}


############# Contructors #################


sub hp_discovery {
   my $description = shift;
   my $session     = shift;

   if($description =~ m/HP ETHERNET MULTI-ENVIRONMENT/) {
      my $description_new = $session->snmpget({
                        oid => '.1.3.6.1.2.1.25.3.2.1.3.1',
                        up  => 1,
                     });
      if (($description_new ne "null") && ($description_new ne "No response from remote host")) {
         $description = $description_new;
      } elsif ($description_new eq "No response from remote host") {
         $description_new = $session->snmpget({
                        oid => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                        up  => 1,
                     });
         if ($description_new ne "null") {
            my @infos = split(/;/,$description_new);
            foreach (@infos) {
               if ($_ =~ /^MDL:/) {
                  $_ =~ s/MDL://;
                  $description = $_;
                  last;
               } elsif ($_ =~ /^MODEL:/) {
                  $_ =~ s/MODEL://;
                  $description = $_;
                  last;
               }
            }
         }
      }
   }
   return $description;
}



sub wyse_discovery {
   my $description = shift;
   my $session     = shift;

   if ($description =~ m/Linux/) {
      my $description_new = $session->snmpget({
                        oid => '.1.3.6.1.4.1.714.1.2.5.6.1.2.1.6.1',
                        up  => 1,
                     });
      if ($description_new ne "null") {
         $description = "Wyse ".$description_new;
      }
   }

   # OR ($description{'.1.3.6.1.2.1.1.1.0'} =~ m/Windows/))
   # In other oid for Windows

   return $description;
}


sub samsung_discovery {
   my $description = shift;
   my $session     = shift;

   if($description =~ m/SAMSUNG NETWORK PRINTER,ROM/) {
      my $description_new = $session->snmpget({
                        oid => '.1.3.6.1.4.1.236.11.5.1.1.1.1.0',
                        up  => 1,
                     });
      if ($description_new ne "null") {
         $description = $description_new;
      }
   }
   return $description;
}


sub epson_discovery {
   my $description = shift;
   my $session     = shift;

   if($description =~ m/EPSON Built-in/) {
      my $description_new = $session->snmpget({
                        oid => '.1.3.6.1.4.1.1248.1.1.3.1.3.8.0',
                        up  => 1,
                     });
      if ($description_new ne "null") {
         $description = $description_new;
      }
   }
   return $description;
}


sub alcatel_discovery {
   my $description = shift;

   # example : 5.1.6.485.R02 Service Release, September 26, 2008.

   if ($description =~ m/^([1-9]{1}).([0-9]{1}).([0-9]{1})(.*) Service Release,(.*)([0-9]{1}).$/ ) {
      my $description_new = snmpget('.1.3.6.1.2.1.47.1.1.1.1.13.1',1);
      if (($description_new ne "null") && ($description_new ne "No response from remote host")) {
         if ($description_new eq "OS66-P24") {
            $description = "OmniStack 6600-P24";
         } else {
            $description = $description_new;
         }
      }
   }
   return $description;
}


sub kyocera_discovery {
   my $description = shift;
   my $session     = shift;

   if ($description =~ m/,HP,JETDIRECT,J/) {
      my $description_new = $session->snmpget({
                        oid => '.1.3.6.1.4.1.1229.2.2.2.1.15.1',
                        up  => 1,
                     });
      if (($description_new ne "null") && ($description_new ne "No response from remote host")) {
         $description = $description_new;
      }
   } elsif ($description eq "KYOCERA MITA Printing System") {
      my $description_new = $session->snmpget({
                        oid => '.1.3.6.1.4.1.1347.42.5.1.1.2.1',
                        up  => 1,
                     });
      if (($description_new ne "null") && ($description_new ne "No response from remote host")) {
         $description = $description_new;
      }

   }
   return $description;
}


1;