package FusionInventory::Agent::Task::NetDiscovery;
our $VERSION = '1.2';

$ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::SAX::PurePerl';

use strict;
#no strict 'refs';
use warnings;

use threads;
use threads::shared;
if ($threads::VERSION > 1.32){
   threads->set_stack_size(20*8192);
}

use Data::Dumper;

use XML::Simple;
use Digest::MD5 qw(md5_hex);

use FusionInventory::Agent::Config;
use FusionInventory::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Agent::XML::Response::Prolog;
use FusionInventory::Agent::Network;
use FusionInventory::Agent::SNMP;
use FusionInventory::Agent::Task::NetDiscovery::Dico;

use FusionInventory::Agent::Task::NetDiscovery::Manufacturer::HewlettPackard;

use FusionInventory::Agent::AccountInfo;

sub main {
    my ( undef ) = @_;
    my $self = {};
    bless $self, 'FusionInventory::Agent::Task::NetDiscovery';

    my $storage = $self->{storage} = new FusionInventory::Agent::Storage({
            target => {
                vardir => $ARGV[0],
            }
        });

    my $data = $storage->restore({ module => "FusionInventory::Agent" });
    $self->{data} = $data;
    my $myData = $self->{myData} = $storage->restore();

    my $config = $self->{config} = $data->{config};
    my $target = $self->{'target'} = $data->{'target'};
    my $logger = $self->{logger} = new FusionInventory::Logger ({
            config => $self->{config}
        });
    $self->{prologresp} = $data->{prologresp};
    $self->{logger}->debug("FusionInventory NetDiscovery module ".$VERSION);

    if ($target->{type} ne 'server') {
        $logger->debug("No server. Exiting...");
        exit(0);
    }

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

    my $network = $self->{network} = new FusionInventory::Agent::Network ({

            logger => $logger,
            config => $config,
            target => $target,

        });

   $self->{countxml} = 0;

   $self->initModList();

   $self->StartThreads();

   exit(0);
}


sub StartThreads {
   my ($self, $params) = @_;
   
	my $nb_threads_discovery = $self->{NETDISCOVERY}->{PARAM}->[0]->{THREADS_DISCOVERY};
	my $nb_core_discovery    = $self->{NETDISCOVERY}->{PARAM}->[0]->{CORE_DISCOVERY};

   if ( not eval { require Parallel::ForkManager; 1 } ) {
      if ($nb_core_discovery > 1) {
         $self->{logger}->debug("Parallel::ForkManager not installed, so only 1 core will be used...");
         $nb_core_discovery = 1;
      }
   }

   my $xml_thread = {};

   my $ModuleNmapScanner = 0;
   my $ModuleNmapParser  = 0;
   my $ModuleNetNBName   = 0;
   my $ModuleNetSNMP     = 0;
   my $iplist = {};
   my $iplist2 = &share({});
   my %TuerThread;
   my %ArgumentsThread;
   my $maxIdx : shared = 0;
   my $storage = $self->{storage};
   my $sendstart = 0;
   my $dico;
   my $dicohash;

   # Load storage with XML dico
   if (defined($self->{NETDISCOVERY}->{DICO})) {
      $storage->save({
            idx => 999998,
            data => $self->{NETDISCOVERY}->{DICO}
        });
      $dicohash->{HASH} = md5_hex($self->{NETDISCOVERY}->{DICO});
      $storage->save({
            idx => 999999,
            data => $dicohash
        });
   }

   $dico = $storage->restore({
         idx => 999998
      });
   $dicohash = $storage->restore({
         idx => 999999
      });

   if ( (!defined($dico)) || !(%$dico)) {
      $dico = FusionInventory::Agent::Task::NetDiscovery::Dico::loadDico();
      $storage->save({
            idx => 999998,
            data => $dico
        });
      $dicohash->{HASH} = md5_hex($dico);
      $storage->save({
            idx => 999999,
            data => $dicohash
        });
   }
   if (defined($self->{NETDISCOVERY}->{DICOHASH})) {
      if ($dicohash->{HASH} eq $self->{NETDISCOVERY}->{DICOHASH}) {
         $self->{logger}->debug("Dico is up to date.");
      } else {
         # Send Dico request to plugin for next time :
         undef($xml_thread);
         $xml_thread->{AGENT}->{END} = '1';
         $xml_thread->{MODULEVERSION} = $VERSION;
         $xml_thread->{PROCESSNUMBER} = $self->{NETDISCOVERY}->{PARAM}->[0]->{PID};
         $xml_thread->{DICO}          = "REQUEST";
         $self->SendInformations({
            data => $xml_thread
            });
         undef($xml_thread);
         $self->{logger}->debug("Dico is old. Exiting...");
         exit(0);
      }
   }
   $self->{logger}->debug("Dico loaded.");

   if ( eval { require Nmap::Parser; 1 } ) {
      $ModuleNmapParser = 1;
   } elsif ( eval { require Nmap::Scanner; 1 } ) {
      if ($@) {
         $self->{logger}->debug("Can't load Nmap::Parser && map::Scanner. Nmap can't be used!");
      } else {
         $ModuleNmapScanner = 1;
      }
   }
   
   if ( eval { require Net::NBName; 1 } ) {
      $ModuleNetNBName = 1;
   } else {
      $self->{logger}->debug("Can't load Net::NBName. Netbios detection can't be used!");
   }

   if ( eval { require Net::SNMP; 1 } ) {
      $ModuleNetSNMP = 1;
   } else {
      $self->{logger}->debug("Can't load Net::SNMP. SNMP detection can't be used!");
   }


   # Auth SNMP
   my $authlist = $self->AuthParser($self->{NETDISCOVERY});

   ##### Get IP to scan
   use Net::IP;

   # Dispatch IPs to different core
   my $startIP = q{}; # Empty string

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
      $pm=new Parallel::ForkManager($max_procs);
   }

   my @Thread;
   my $xml_Thread : shared = q{}; # Empty string
   for(my $p = 0; $p < $nb_core_discovery; $p++) {
      if ($nb_core_discovery > 1) {
         my $pid = $pm->start and next;
      }

      my $threads_run = 0;
      my $loop_action : shared = 1;
      my $exit : shared = 0;

      my %ThreadState : shared;
      my %ThreadAction : shared;
      $iplist = &share({});
      my $loop_nbthreads : shared;
      my $sendbylwp : shared;
      my $sentxml = {};

      while ($loop_action > 0) {
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
                        ++$ip;
                        $self->{NETDISCOVERY}->{RANGEIP}->{IPSTART} = $ip->ip();
                        $loop_action = 1;
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
                              ++$ip;
                              $num->{IPSTART} = $ip->ip();
                              $loop_action = 1;
                              goto CONTINUE;
                           }
                        }
                     } while (++$ip);
                     undef $ip;
                     $num->{IPSTART} = q{}; # Empty string
                  }
               }
            }
         }
         $loop_action = 0;

#         if ($nbip > ($nb_ip_per_thread * 4)) {
#            
#         } elsif ($nbip > $nb_ip_per_thread) {
#            $nb_threads_discovery = int($nbip / $nb_ip_per_thread) + 4;
#         } else {
#            $nb_threads_discovery = $nbip;
#         }

         CONTINUE:
#$self->{logger}->debug("LOOP : ".$loop_action);
         $loop_nbthreads = $nb_threads_discovery;


         for(my $j = 0 ; $j < $nb_threads_discovery ; $j++) {
            $ThreadState{$j} = "0";
            $ThreadAction{$j} = "0";
         }
         #==================================
         # Prepare in variables devices to query
         #==================================
         $ArgumentsThread{'id'}[$p] = &share([]);

         my $i = 0;

         while ($i < $nb_threads_discovery) {
            $i++;
         }
         #===================================
         # Create Thread management others threads
         #===================================
         $exit = 2;
#$self->{logger}->debug("exit : ".$exit);
         if ($threads_run eq "0") {            
            #===================================
            # Create all Threads
            #===================================
            my $k = 0;
            for(my $j = 0; $j < $nb_threads_discovery; $j++) {
               $threads_run = 1;
               $k++;
               $Thread[$p][$j] = threads->create(
                  sub {
                     my $p = shift;
                     my $t = shift;
                     my $authlistt = shift;
                     my $self = shift;
                     my $loopthread = 0;
                     my $loopbigthread = 0;
                     my $count = 0;
                     my $device_id;
                     my $xml_threadt;

                     $self->{logger}->debug("Core $p - Thread $t created");
                     while ($loopbigthread ne "1") {
                        ##### WAIT ACTION #####
                        $loopthread = 0;
                        while ($loopthread ne "1") {
#$self->{logger}->debug("[".$t."] : waiting...");
                           if ($ThreadAction{$t} eq "3") { # STOP
                              $ThreadState{$t} = "2";
                              $self->{logger}->debug("Core $p - Thread $t deleted");
                              return;
                           } elsif ($ThreadAction{$t} ne "0") { # RUN
                              $ThreadState{$t} = "1";
                              $loopthread  = 1;
                           }
                           sleep 1;
                        }
                        ##### RUN ACTION #####
#$self->{logger}->debug("[".$t."] : run...");
                        $loopthread = 0;
                        while ($loopthread ne "1") {
                           $device_id = q{}; # Empty string
                           {
                              lock $iplist2;
                              if (keys %{$iplist2} ne "0") {
                                 my @keys = sort keys %{$iplist2};
                                 $device_id = pop @keys;
                                 delete $iplist2->{$device_id};
                              } else {
                                 $loopthread = 1;
                              }
                           }
                           if ($loopthread ne "1") {
                              my $datadevice = $self->discovery_ip_threaded({
                                    ip                  => $iplist->{$device_id}->{IP},
                                    entity              => $iplist->{$device_id}->{ENTITY},
                                    authlist            => $authlistt,
                                    ModuleNmapScanner   => $ModuleNmapScanner,
                                    ModuleNetNBName     => $ModuleNetNBName,
                                    ModuleNmapParser    => $ModuleNmapParser,
                                    ModuleNetSNMP       => $ModuleNetSNMP,
                                    dico                => $dico
                                 });
                              undef $iplist->{$device_id}->{IP};
                              undef $iplist->{$device_id}->{ENTITY};

                              if (keys %{$datadevice}) {
                                 $xml_threadt->{DEVICE}->[$count] = $datadevice;
                                 $xml_threadt->{MODULEVERSION} = $VERSION;
                                 $xml_threadt->{PROCESSNUMBER} = $self->{NETDISCOVERY}->{PARAM}->[0]->{PID};
                                 $count++;
                              }
                           }
                           if (($count eq "4") || (($loopthread eq "1") && ($count > 0))) {
                              $maxIdx++;
                              $storage->save({
                                    idx =>
                                    $maxIdx,
                                    data => $xml_threadt
                                });
                              
                              $count = 0;
                           }
                        }
                        ##### CHANGE STATE #####
                        if ($ThreadAction{$t} eq "2") { # STOP
                           $ThreadState{$t} = 2;
                           $ThreadAction{$t} = 0;
#$self->{logger}->debug("[".$t."] : stoping...");
                           $self->{logger}->debug("Core $p - Thread $t deleted");
                           return;
                        } elsif ($ThreadAction{$t} eq "1") { # PAUSE
                           $ThreadState{$t} = 0;
                           $ThreadAction{$t} = 0;
                        }
                     }
                  }, $p, $j, $authlist, $self
               )->detach();

               
               if ($k eq "4") {
                  sleep 1;
                  $k = 0;
               }
            }
            ##### Start Thread Management #####
               my $Threadmanagement = threads->create(
                  sub {
                     my ($self, $params) = @_;

                     my $count;
                     my $i;
                     my $loopthread;

                     while (1) {
                        if (($loop_action eq "0") && ($exit eq "2")) {
                           ## Kill threads who do nothing partiel ##
#                              for($i = ($loop_nbthreads - 1) ; $i < $self->{NETDISCOVERY}->{PARAM}->[0]->{THREADS_DISCOVERY} ; $i++) {
#                                 $ThreadAction{$i} = "3";
#                              }

                           ## Start + end working threads (faire fonction) ##
                              for($i = 0 ; $i < $loop_nbthreads ; $i++) {
                                 $ThreadAction{$i} = "2";
                                 #$ThreadState{$i} = "1";
                              }
                           ## Fonction etat des working threads (s'ils sont arretes) ##
                              $count = 0;
                              $loopthread = 0;

                              while ($loopthread ne "1") {
                                 for($i = 0 ; $i < $loop_nbthreads ; $i++) {
                                    if ($ThreadState{$i} eq "2") {
                                       $count++;
                                    }
                                 }
                                 if ($count eq $loop_nbthreads) {
                                    $loopthread = 1;
                                 } else {
                                    $count = 0;
                                 }
                                 sleep 1;
                              }
                              $exit = 1;
                              return;
                              
                        } elsif (($loop_action eq "1") && ($exit eq "2")) {
                           ## Start + pause working Threads (faire fonction) ##
                              for($i = 0 ; $i < $loop_nbthreads ; $i++) {
                                 $ThreadAction{$i} = "1";
                                 #$ThreadState{$i} = "1";
                              }
                           sleep 1;

                           ## Fonction etat des working threads (s'il sont tous en pause) ##
                           $count = 0;
                           $loopthread = 0;

                           while ($loopthread ne "1") {
                              for($i = 0 ; $i < $loop_nbthreads ; $i++) {
                                 #print "ThreadState ".$i." = ".$ThreadState{$i}."\n";
                                 if ($ThreadState{$i} eq "0") {
                                    $count++;
                                 }
                              }
                              if ($count eq $loop_nbthreads) {
                                 $loopthread = 1;
                              } else {
                                 $count = 0;
                              }
                              sleep 1;
                           }
                           $exit = 1;
                           $loop_action = "2";
                        }
                        
                        sleep 1;
                     }

                     return;
                  },
                  $self
               )->detach();
            ### END Threads Creation
         }

         my $network = $self->{network} = new FusionInventory::Agent::Network ({

                  logger => $self->{logger},
                  config => $self->{config},
                  target => $self->{target},

              });

         # Send infos to server :
         if ($sendstart eq "0") {
            my $xml_thread = {};
            $xml_thread->{AGENT}->{START} = '1';
            $xml_thread->{AGENT}->{AGENTVERSION} = $self->{config}->{VERSION};
            $xml_thread->{MODULEVERSION} = $VERSION;
            $xml_thread->{PROCESSNUMBER} = $self->{NETDISCOVERY}->{PARAM}->[0]->{PID};
            $self->SendInformations({
               data => $xml_thread
               });
            undef($xml_thread);
            $sendstart = 1;
         }

         # Send NB ips to server :
         $xml_thread = {};
         $xml_thread->{AGENT}->{NBIP} = $nbip;
         $xml_thread->{PROCESSNUMBER} = $self->{NETDISCOVERY}->{PARAM}->[0]->{PID};
         {
            lock $sendbylwp;
            $self->SendInformations({
               data => $xml_thread
               });
         }
         undef($xml_thread);

         
        while($exit ne "1") {
           sleep 2;
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

      } 
     if ($nb_core_discovery > 1) {
         $pm->finish;
      }
   }
   if ($nb_core_discovery > 1) {
      $pm->wait_all_children;
   }
   # Send infos to server :
   undef($xml_thread);
   $xml_thread->{AGENT}->{END} = '1';
   $xml_thread->{MODULEVERSION} = $VERSION;
   $xml_thread->{PROCESSNUMBER} = $self->{NETDISCOVERY}->{PARAM}->[0]->{PID};
   sleep 1; # Wait for threads be terminated
   $self->SendInformations({
      data => $xml_thread
      });
   undef($xml_thread);

   return;
}


sub SendInformations{
   my ($self, $message) = @_;

   my $config = $self->{config};

   my $xmlMsg = FusionInventory::Agent::XML::Query::SimpleMessage->new(
       {
           config => $self->{config},
           logger => $self->{logger},
           target => $self->{target},
           msg    => {
               QUERY => 'NETDISCOVERY',
               CONTENT   => $message->{data},
           },
       });
   $self->{network}->send({message => $xmlMsg});
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



sub discovery_ip_threaded {
   my ($self, $params) = @_;

   my $datadevice = {};

   if (!defined($params->{ip})) {
      $self->{logger}->debug("ip address empty...");
      return $datadevice;
   }
   if ($params->{ip} !~ m/^(\d\d?\d?)\.(\d\d?\d?)\.(\d\d?\d?)\.(\d\d?\d?)/ ) {
      $self->{logger}->debug("Invalid ip address...");
      return $datadevice;
   }

   #** Nmap discovery
   if ($params->{ModuleNmapParser} eq "1") {
      my $scan = new Nmap::Parser;
      if (eval {$scan->parsescan('nmap','-sP --system-dns --max-retries 1 --max-rtt-timeout 1000 ', $params->{ip})}) {
         if (exists($scan->{HOSTS}->{$params->{ip}}->{addrs}->{mac}->{addr})) {
            $datadevice->{MAC} = special_char($scan->{HOSTS}->{$params->{ip}}->{addrs}->{mac}->{addr});
         }
         if (exists($scan->{HOSTS}->{$params->{ip}}->{addrs}->{mac}->{vendor})) {
            $datadevice->{NETPORTVENDOR} = special_char($scan->{HOSTS}->{$params->{ip}}->{addrs}->{mac}->{vendor});
         }

         if (exists($scan->{HOSTS}->{$params->{ip}}->{hostnames}->[0])) {
            $datadevice->{DNSHOSTNAME} = special_char($scan->{HOSTS}->{$params->{ip}}->{hostnames}->[0]);
         }
      }
   } elsif ($params->{ModuleNmapScanner} eq "1") {
      my $scan = new Nmap::Scanner;
      my $results_nmap = $scan->scan('-sP --system-dns --max-retries 1 --max-rtt-timeout 1000 '.$params->{ip});

      my $xml_nmap = new XML::Simple;
      my $macaddress = q{}; # Empty string
      my $hostname = q{}; # Empty string
      my $netportvendor = q{}; # Empty string

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
   if ($params->{ModuleNetNBName} eq "1") {
      my $nb = Net::NBName->new;

      my $domain = q{}; # Empty string
      my $user = q{}; # Empty string
      my $machine = q{}; # Empty string
      my $type = 0;

      my $ns = $nb->node_status($params->{ip});
      if ($ns) {
         for my $rr ($ns->names) {
             if ($rr->suffix eq "0" && $rr->G eq "GROUP") {
               $datadevice->{WORKGROUP} = special_char($rr->name);
             }
             if ($rr->suffix eq "3" && $rr->G eq "UNIQUE") {
               $datadevice->{USERSESSION} = special_char($rr->name);
             }
             if ($rr->suffix eq "0" && $rr->G eq "UNIQUE") {
                 $machine = $rr->name unless $rr->name =~ /^IS~/;
                 $datadevice->{NETBIOSNAME} = special_char($machine);
                 $type = 1;
             }
         }
         if (not exists($datadevice->{MAC})) {
            my $NetbiosMac = $ns->mac_address;
            $NetbiosMac =~ tr/-/:/;
            $datadevice->{MAC} = $NetbiosMac;
         } elsif ($datadevice->{MAC} !~ /^([0-9a-f]{2}([:]|$)){6}$/i) {
            my $NetbiosMac = $ns->mac_address;
            $NetbiosMac =~ tr/-/:/;
            $datadevice->{MAC} = $NetbiosMac;
         }
      }
   }


   if ($params->{ModuleNetSNMP} eq "1") {
      my $i = "4";
      my $snmpv;
      while ($i ne "1") {
         $i--;
         $snmpv = $i;
         if ($i eq "2") {
            $snmpv = "2c";
         }
         for my $key ( keys %{$params->{authlist}} ) {
            if ($params->{authlist}->{$key}->{VERSION} eq $snmpv) {
               my $session = new FusionInventory::Agent::SNMP ({

                  version      => $params->{authlist}->{$key}->{VERSION},
                  hostname     => $params->{ip},
                  community    => $params->{authlist}->{$key}->{COMMUNITY},
                  username     => $params->{authlist}->{$key}->{USERNAME},
                  authpassword => $params->{authlist}->{$key}->{AUTHPASSWORD},
                  authprotocol => $params->{authlist}->{$key}->{AUTHPROTOCOL},
                  privpassword => $params->{authlist}->{$key}->{PRIVPASSWORD},
                  privprotocol => $params->{authlist}->{$key}->{PRIVPROTOCOL},
                  translate    => 1,

               });

               if (!defined($session->{SNMPSession}->{session})) {
                  #print("SNMP ERROR: %s.\n", $error);
   #               print "[".$params->{ip}."] GNERROR ()".$authlist->{$key}->{VERSION}."\n";
               } else {

               #print "[".$params->{ip}."] GNE () \n";
                  my $description = $session->snmpGet({
                        oid => '1.3.6.1.2.1.1.1.0',
                        up  => 1,
                     });
                  if ($description =~ m/No response from remote host/) {
                     #print "[".$params->{ip}."][NO][".$authlist->{$key}->{VERSION}."][".$authlist->{$key}->{COMMUNITY}."]\n";
                     #$session->close;
                  } elsif ($description =~ m/No buffer space available/) {
                     #print "[".$params->{ip}."][NO][".$authlist->{$key}->{VERSION}."][".$authlist->{$key}->{COMMUNITY}."]\n";
                     #$session->close;
                  } elsif ($description ne "null") {
                     #print "[".$params->{ip}."][YES][".$authlist->{$key}->{VERSION}."][".$authlist->{$key}->{COMMUNITY}."]\n";

                     # ***** manufacturer specifications
                     for my $m ( keys %{$self->{modules}} ) {
                        $description = $m->discovery($description, $session,$description);
                     }

                     $datadevice->{DESCRIPTION} = $description;

                     my $name = $session->snmpGet({
                           oid => '.1.3.6.1.2.1.1.5.0',
                           up  => 1,
                        });
                     if ($name eq "null") {
                        $name = q{}; # Empty string
                     }
                     # Serial Number
                     my ($serial, $type, $model, $mac) = verifySerial($description, $session, $params->{dico});
                     if ($serial eq "Received noSuchName(2) error-status at error-index 1") {
                        $serial = q{}; # Empty string
                     }
                     if ($serial eq "noSuchInstance") {
                        $serial = q{}; # Empty string
                     }
                     if ($serial eq "noSuchObject") {
                        $serial = q{}; # Empty string
                     }
                     if ($serial eq "No response from remote host") {
                        $serial = q{}; # Empty string
                     }
                     $serial =~ s/^\s+//;
                     $serial =~ s/\s+$//;
                     $serial =~ s/(\.{2,})*//g;
                     $datadevice->{SERIAL} = $serial;
                     $datadevice->{MODELSNMP} = $model;
                     $datadevice->{AUTHSNMP} = $key;
                     $datadevice->{TYPE} = $type;
                     $datadevice->{SNMPHOSTNAME} = $name;
                     $datadevice->{IP} = $params->{ip};
                     if (exists($datadevice->{MAC})) {
                        if ($datadevice->{MAC} !~ /^([0-9a-f]{2}([:]|$)){6}$/i) {
                           $datadevice->{MAC} = $mac;
                        }
                     } else {
                        $datadevice->{MAC} = $mac;
                     }
                     $datadevice->{ENTITY} = $params->{entity};
                     $self->{logger}->debug("[$params->{ip}] ".Dumper($datadevice));
                     #$session->close;
                     return $datadevice;
                  } else {
                     #debug($log,"[".$params->{ip}."][NO][".$$authSNMP_discovery{$key}{'version'}."][".$$authSNMP_discovery{$key}{'community'}."] ".$session->error, "",$PID,$Bin);
                     $session->close;
                  }
               }
            }
         }
      }
   }

   if (exists($datadevice->{MAC})) {
      $datadevice->{MAC} =~ tr/A-F/a-f/;
   }
   if ((exists($datadevice->{MAC})) || (exists($datadevice->{DNSHOSTNAME})) || (exists($datadevice->{NETBIOSNAME}))) {
      $datadevice->{IP} = $params->{ip};
      $datadevice->{ENTITY} = $params->{entity};
      $self->{logger}->debug("[$params->{ip}] ".Dumper($datadevice));
   } else {
      $self->{logger}->debug("[$params->{ip}] Not found !");
   }
   return $datadevice;
}



sub special_char {
   my $variable = shift;
   if (defined($variable)) {
      if ($variable =~ /0x$/) {
         return "";
      }
      $variable =~ s/([\x80-\xFF])//;
      return $variable;
   } else {
      return "";
   }
}



sub verifySerial {
   my $description = shift;
   my $session     = shift;
   my $dico    = shift;

   my $oid;
   my $macreturn = q{}; # Empty string
   my $modelreturn = q{}; # Empty string
   my $serial;
   my $serialreturn = q{}; # Empty string

   $description =~ s/\n//g;
   $description =~ s/\r//g;

   foreach my $num (@{$dico->{DEVICE}}) {
      if ($num->{SYSDESCR} eq $description) {
         
         if (defined($num->{SERIAL})) {
            $oid = $num->{SERIAL};
				$serial = $session->snmpGet({
                     oid => $oid,
                     up  => 1,
                  });
         }

         if (defined($serial)) {
            $serial =~ s/\n//g;
            $serial =~ s/\r//g;
            $serialreturn = $serial;
         }
         my $typereturn  = $num->{TYPE};
         if (defined($num->{MODELSNMP})) {
            $modelreturn = $num->{MODELSNMP};
         }
         if (defined($num->{MAC})) {
            $oid = $num->{MAC};
            $macreturn  = $session->snmpGet({
                        oid => $oid,
                        up  => 0,
                     });

         }
        
         $oid = $num->{MACDYN};
         my $Arraymacreturn = {};
         $Arraymacreturn  = $session->snmpWalk({
                     oid_start => $oid
                  });
         while ( (undef,my $macadress) = each (%{$Arraymacreturn}) ) {
            if (($macadress ne '') && ($macadress ne '0:0:0:0:0:0') && ($macadress ne '00:00:00:00:00:00')) {
               if ($macreturn !~ /^([0-9a-f]{2}([:]|$)){6}$/i) {
                  $macreturn = $macadress;
               }
            }
         }

         # Mac of switchs
         if ($macreturn !~ /^([0-9a-f]{2}([:]|$)){6}$/i) {
            $oid = ".1.3.6.1.2.1.17.1.1.0";
            $macreturn  = $session->snmpGet({
                        oid => $oid,
                        up  => 0,
                     });
         }
         if ($macreturn !~ /^([0-9a-f]{2}([:]|$)){6}$/i) {
            $oid = ".1.3.6.1.2.1.2.2.1.6";
            my $Arraymacreturn = {};
            $Arraymacreturn  = $session->snmpWalk({
                        oid_start => $oid
                     });
            while ( (undef,my $macadress) = each (%{$Arraymacreturn}) ) {
               if (($macadress ne '') && ($macadress ne '0:0:0:0:0:0') && ($macadress ne '00:00:00:00:00:00')) {
                  if ($macreturn !~ /^([0-9a-f]{2}([:]|$)){6}$/i) {
                     $macreturn = $macadress;
                  }
               }
            }
         }

         return ($serialreturn, $typereturn, $modelreturn, $macreturn);
      }
   }

   # Mac of switchs
   if ($macreturn !~ /^([0-9a-f]{2}([:]|$)){6}$/i) {
      $oid = ".1.3.6.1.2.1.17.1.1.0";
      $macreturn  = $session->snmpGet({
                  oid => $oid,
                  up  => 0,
               });
   }
   if ($macreturn !~ /^([0-9a-f]{2}([:]|$)){6}$/i) {
      $oid = ".1.3.6.1.2.1.2.2.1.6";
      my $Arraymacreturn = {};
      $Arraymacreturn  = $session->snmpWalk({
                  oid_start => $oid
               });
      while ( (undef,my $macadress) = each (%{$Arraymacreturn}) ) {
         if (($macadress ne '') && ($macadress ne '0:0:0:0:0:0') && ($macadress ne '00:00:00:00:00:00')) {
            if ($macreturn !~ /^([0-9a-f]{2}([:]|$)){6}$/i) {
               $macreturn = $macadress;
            }
         }
      }
   }

	return ("", 0, "", "");
}


sub printXML {
  my ($self, $args) = @_;

  print $self->getContent();
}


sub writeXML {
  my ($self, $message) = @_;

  my $logger = $self->{logger};
  my $config = $self->{config};
  my $target = $self->{target};

  if ($target->{path} =~ /^$/) {
    $logger->fault ('local path unititalised!');
  }

   my $dir = $self->{NETDISCOVERY}->{PARAM}->[0]->{PID};
  $dir =~ s/\//-/;

  my $localfile = $config->{local}."/".$target->{deviceid}.'.'.$dir.'-'.$self->{countxml}.'.xml';
  $localfile =~ s!(//){1,}!/!;

  $self->{countxml} = $self->{countxml} + 1;

  # Convert perl data structure into xml strings

   my $xmlMsg = FusionInventory::Agent::XML::Query::SimpleMessage->new(
        {
            config => $self->{config},
            logger => $self->{logger},
            target => $self->{target},
            msg    => {
                QUERY => 'NETDISCOVERY',
                CONTENT   => $message->{data},
            },
        });

  if (open OUT, ">$localfile") {
    print OUT $xmlMsg;

    close OUT or warn;
    $logger->info("Inventory saved in $localfile");
  } else {
    warn "Can't open `$localfile': $!"
  }
}

sub initModList {
   my $self = shift;

   my $logger = $self->{logger};
   my $config = $self->{config};

   my @dirToScan;
   my @installed_mods;
   my @installed_files;

   if ($config->{devlib}) {
      # devlib enable, I only search for backend module in ./lib
      push (@dirToScan, './lib');
   } else {
      foreach (@INC) {
         next if ! -d || (-l && -d readlink) || /^(\.|lib)$/;
         next if ! -d $_.'/FusionInventory/Agent/Task/NetDiscovery/Manufacturer';
         push @dirToScan, $_;
      }
   }
   if (@dirToScan) {
      eval {require File::Find};
      if ($@) {
         $logger->debug("Failed to load File::Find");
      } else {
         # here I need to use $d to avoid a bug with AIX 5.2's perl 5.8.0. It
         # changes the @INC content if i use $_ directly
         # thanks to @rgs on irc.perl.org
         File::Find::find(
           {
             wanted => sub {
               push @installed_files, $File::Find::name if $File::Find::name =~
               /FusionInventory\/Agent\/Task\/NetDiscovery\/Manufacturer\/.*\.pm$/;
             },
             follow => 1,
             follow_skip => 2
           }
           , @dirToScan);
      }
   }
   foreach my $file (@installed_files) {
      my $t = $file;
      next unless $t =~ s!.*?(FusionInventory/Agent/Task/NetDiscovery/Manufacturer/)(.*?)\.pm$!$1$2!;
      my $m = join ('::', split /\//, $t);
      eval "use $m;";
      if ($@) {
         $logger->debug ("Failed to load $m: $@");
         next;
      } else {
         $logger->debug ($m." loaded");
         $self->{modules}->{$m} = 1;
      }
   }
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetDiscovery - SNMP support for FusionInventory Agent

=head1 DESCRIPTION

This module scans your networks to get informations from devices with SNMP protocol

=over 4

=item *
networking devices discovery within an IP range

=item *
network switche, printer and router analyse

=item *
relation between computer / printer / switch port

=item *
identify unknown MAC addresses

=item *
report printer cartridge and ounter status

=item *
support management of SNMP versions v1, v2, v3

=back

The plugin depends on FusionInventory for GLPI.

=head1 AUTHORS

The maintainer is David DURIEUX <d.durieux@siprossii.com>

Please read the AUTHORS, Changes and THANKS files to see who is behind
FusionInventory.

=head1 SEE ALSO

=over 4

=item *
FusionInventory website: L<http://www.FusionInventory.org/>

=item *
LaunchPad project page: L<http://launchpad.net/fusioninventory-agent-task-netdiscovery>

=item *
the Mailing lists and IRC

=back

=head1 BUGS

Please, use the mailing lists as much as possible. You can open your own bug
tickets. Patches are welcome. You can also use LaunchPad bugtracker or
push your Bazaar branch on LaunchPad and do a merge request.

=head1 COPYRIGHT

=over 4

=item *

Copyright (C) 2009 David Durieux

=item *

=back

Copyright (C) 2010 FusionInventory Team

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

=cut
