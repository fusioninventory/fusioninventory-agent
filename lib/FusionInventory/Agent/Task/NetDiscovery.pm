package FusionInventory::Agent::Task::NetDiscovery;

use strict;
use warnings;
use threads;
use threads::shared;
if ($threads::VERSION > 1.32){
   threads->set_stack_size(20*8192);
}
use base 'FusionInventory::Agent::Task';

use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use English qw(-no_match_vars);
use Net::IP;
use Time::localtime;
use UNIVERSAL::require;
use XML::TreePP;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Regexp;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::NetDiscovery::Dico;
use FusionInventory::Agent::XML::Query;

our $VERSION = '1.5';

sub run {
    my ($self) = @_;

    if (!$self->{target}->isa('FusionInventory::Agent::Target::Server')) {
        $self->{logger}->debug("No server. Exiting...");
        return;
    }

    my $response = $self->{prologresp};
    if (!$response) {
        $self->{logger}->debug("No server response. Exiting...");
        return;
    }

    my $options = $response->getOptionsInfoByName('NETDISCOVERY');
    if (!$options) {
        $self->{logger}->debug(
            "No wake on lan requested in the prolog, exiting"
        );
        return;
    }

    $self->{logger}->debug("FusionInventory NetDiscovery module ".$VERSION);

   $self->{PID} =
       sprintf("%04d", localtime->yday()) . 
       sprintf("%02d", localtime->hour()) .
       sprintf("%02d", localtime->min());

   $self->_initModList();

   my $params  = $options->{PARAM}->[0];
   my $storage = $self->{target}->getStorage();

   # take care of models dictionnary
   my $dico = $self->_getDictionnary($options, $storage, $params->{PID});

   # check discovery methods available
   my $nmap_parameters;
   if (can_run('nmap')) {
       my ($major, $minor) = getFirstMatch(
           command => 'nmap -V',
           pattern => qr/Nmap version (\d+)\.(\d+)/
       );
       $nmap_parameters = compareVersion($major, $minor, 5, 29) ?
           "-sP -PP --system-dns --max-retries 1 --max-rtt-timeout 1000ms " :
           "-sP --system-dns --max-retries 1 --max-rtt-timeout 1000 "       ;
   }

   Net::NBName->require();
   if ($EVAL_ERROR) {
      $self->{logger}->error("Can't load Net::NBName. Netbios detection can't be used!");
   }

   FusionInventory::Agent::SNMP->require();
   if ($EVAL_ERROR) {
      $self->{logger}->error("Can't load FusionInventory::Agent::SNMP. SNMP detection can't be used!");
   }

   # retrieve SNMP authentication credentials
   my $credentials = $options->{AUTHENTICATION};

   # manage discovery

   my $iplist = {};
   my $iplist2 = &share({});
   my $maxIdx : shared = 0;
   my $sendstart = 0;
   my $startIP = q{}; # Empty string
   my $nbip = 0;
   my $countnb;
   my $nb_ip_per_thread = 25;
   my $limitip = $params->{THREADS_DISCOVERY} * $nb_ip_per_thread;
   my $ip;

   my $manager;
   if ($params->{CORE_DISCOVERY} > 1) {
       Parallel::ForkManager->require();
       if ($EVAL_ERROR) {
         $self->{logger}->debug("Parallel::ForkManager not installed, so only 1 core will be used...");
         $params->{CORE_DISCOVERY} = 1;
      } else {
          $manager = Parallel::ForkManager->new($params->{CORE_DISCOVERY});
      }
   }

   my @Thread;
   for(my $p = 0; $p < $params->{CORE_DISCOVERY}; $p++) {
      if ($manager) {
         my $pid = $manager->start();
         next if $pid;
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

         if ($threads_run == 0) {
            $iplist2 = &share({});
            $iplist = &share({});
         }


         if (ref($options->{RANGEIP}) eq "HASH"){
            if ($options->{RANGEIP}->{IPSTART} eq $options->{RANGEIP}->{IPEND}) {
               if ($threads_run == 0) {
                  $iplist->{$countnb} = &share({});
               }
               $iplist->{$countnb}->{IP} = $options->{RANGEIP}->{IPSTART};
               $iplist->{$countnb}->{ENTITY} = $options->{RANGEIP}->{ENTITY};
               $iplist2->{$countnb} = $countnb;
               $countnb++;
               $nbip++;
            } else {
               $ip = Net::IP->new($options->{RANGEIP}->{IPSTART}.' - '.$options->{RANGEIP}->{IPEND});
               do {
                  if ($threads_run == 0) {
                     $iplist->{$countnb} = &share({});
                  }
                  $iplist->{$countnb}->{IP} = $ip->ip();
                  $iplist->{$countnb}->{ENTITY} = $options->{RANGEIP}->{ENTITY};
                  $iplist2->{$countnb} = $countnb;
                  $countnb++;
                  $nbip++;
                  if ($nbip eq $limitip) {
                     if ($ip->ip() ne $options->{RANGEIP}->{IPEND}) {
                        ++$ip;
                        $options->{RANGEIP}->{IPSTART} = $ip->ip();
                        $loop_action = 1;
                        goto CONTINUE;
                     }
                  }
               } while (++$ip);
               undef $options->{RANGEIP};
            }
         } else {
            foreach my $num (@{$options->{RANGEIP}}) {
               if ($num->{IPSTART} eq $num->{IPEND}) {
                  if ($threads_run == 0) {
                     $iplist->{$countnb} = &share({});
                  }
                  $iplist->{$countnb}->{IP} = $num->{IPSTART};
                  $iplist->{$countnb}->{ENTITY} = $num->{ENTITY};
                  $iplist2->{$countnb} = $countnb;
                  $countnb++;
                  $nbip++;
               } else {
                  if ($num->{IPSTART} ne "") {
                     $ip = Net::IP->new($num->{IPSTART}.' - '.$num->{IPEND});
                     do {
                        if ($threads_run == 0) {
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

         CONTINUE:
         $loop_nbthreads = $params->{THREADS_DISCOVERY};


         for(my $j = 0 ; $j < $params->{THREADS_DISCOVERY} ; $j++) {
            $ThreadState{$j} = "0";
            $ThreadAction{$j} = "0";
         }
         #===================================
         # Create Thread management others threads
         #===================================
         $exit = 2;
         if ($threads_run == 0) {
            #===================================
            # Create all Threads
            #===================================
            my $k = 0;
            for(my $j = 0; $j < $params->{THREADS_DISCOVERY}; $j++) {
               $threads_run = 1;
               $k++;
               $Thread[$p][$j] = threads->create(
                   '_handleIPRange',
                   $self,
                   $p,
                   $j,
                   $credentials,
                   \%ThreadAction,
                   \%ThreadState,
                   $iplist,
                   $iplist2,
                   $nmap_parameters,
                   $dico,
                   $maxIdx,
                   $params->{PID}
               )->detach();

               if ($k == 4) {
                  sleep 1;
                  $k = 0;
               }
            }
            ##### Start Thread Management #####
               my $Threadmanagement = threads->create(
                   '_manageThreads',
                   $self,
                   $loop_action,
                   $exit,
                   $loop_nbthreads,
                   \%ThreadAction,
                   \%ThreadState,
               )->detach();
            ### END Threads Creation
         }

         # Send infos to server :
         if ($sendstart == 0) {
            $self->_sendInformations({
                AGENT => {
                    START        => '1',
                    AGENTVERSION => $FusionInventory::Agent::VERSION,
                },
                MODULEVERSION => $VERSION,
                PROCESSNUMBER => $params->{PID},
            });
            $sendstart = 1;
         }

         # Send NB ips to server :
         {
            lock $sendbylwp;
            $self->_sendInformations({
                AGENT => {
                    NBIP => $nbip
                },
                PROCESSNUMBER => $params->{PID}
            });
         }


        while($exit != 1) {
           sleep 2;
            foreach my $idx (1..$maxIdx) {
               next if defined $sentxml->{$idx};

               my $data = $storage->restore(
                   idx => $idx
               );

               $self->_sendInformations($data);
               $sentxml->{$idx} = 1;
               $storage->remove(
                   idx => $idx
               );
               sleep 1;
            }
        }

      foreach my $idx (1..$maxIdx) {
         next if defined $sentxml->{$idx};

         my $data = $storage->restore(
             idx => $idx
         );

         $self->_sendInformations($data);
         $sentxml->{$idx} = 1;
         sleep 1;
      }

      }
      $manager->finish() if $manager;
   }

   # Wait for threads be terminated
   $manager->wait_all_children() if $manager;
   sleep 1;

   # Send infos to server

   $self->_sendInformations({
       AGENT => {
           END => '1',
       },
       MODULEVERSION => $VERSION,
       PROCESSNUMBER => $params->{PID},
   });

}

sub _getDictionnary {
    my ($self, $options, $storage, $pid) = @_;

    my $dico;
    my $dicohash;

    if (defined($options->{DICO})) {
        $storage->save(
            idx  => 999998,
            data => XMLin($options->{DICO})
        );
        $dicohash->{HASH} = $options->{DICOHASH};
        $storage->save(
            idx  => 999999,
            data => $dicohash
        );
    }

    $dico = $storage->restore(
        idx => 999998
    );
    $dicohash = $storage->restore(
        idx => 999999
    );

    if ( (!defined($dico)) || (ref($dico) ne "HASH")) {
        $dico = FusionInventory::Agent::Task::NetDiscovery::Dico::loadDico();
        $storage->save(
            idx => 999998,
            data => $dico
        );
        $dicohash->{HASH} = md5_hex($dico);
        $storage->save(
            idx  => 999999,
            data => $dicohash
        );
    }

    if (defined($options->{DICOHASH})) {
        if ($dicohash->{HASH} eq $options->{DICOHASH}) {
            $self->{logger}->debug("Dico is up to date.");
        } else {
            # Send Dico request to plugin for next time :
            $self->_sendInformations({
                AGENT => {
                    END => '1'
                },
                MODULEVERSION => $VERSION,
                PROCESSNUMBER => $pid,
                DICO          => "REQUEST",
            });
            $self->{logger}->debug("Dico is to old (".$dicohash->{HASH}." vs ".$options->{DICOHASH}."). Exiting...");
            return;
        }
    }
    $self->{logger}->debug("Dico loaded.");

    return $dico;
}

sub _handleIPRange {
    my ($self, $p, $t, $credentials, $ThreadAction, $ThreadState, $iplist2, $iplist, $nmap_parameters, $dico, $maxIdx, $pid) = @_;
    my $loopthread = 0;
    my $loopbigthread = 0;
    my $count = 0;
    my $device_id;
    my $data;

    $self->{logger}->debug("Core $p - Thread $t created");
    while ($loopbigthread != 1) {
        ##### WAIT ACTION #####
        $loopthread = 0;
        while ($loopthread != 1) {
           if ($ThreadAction->{$t} == 3) { # STOP
              $ThreadState->{$t} = "2";
              $self->{logger}->debug("Core $p - Thread $t deleted");
              return;
           } elsif ($ThreadAction->{$t} != 0) { # RUN
              $ThreadState->{$t} = "1";
              $loopthread  = 1;
           }
           sleep 1;
        }
        ##### RUN ACTION #####
        $loopthread = 0;
        while ($loopthread != 1) {
           $device_id = q{}; # Empty string
           {
              lock $iplist2;
              if (keys %{$iplist2} != 0) {
                 my @keys = sort keys %{$iplist2};
                 $device_id = pop @keys;
                 delete $iplist2->{$device_id};
              } else {
                 $loopthread = 1;
              }
           }
           if ($loopthread != 1) {
              my $datadevice = $self->_discovery_ip_threaded({
                    ip                  => $iplist->{$device_id}->{IP},
                    entity              => $iplist->{$device_id}->{ENTITY},
                    credentials         => $credentials,
                    nmap_parameters     => $nmap_parameters,
                    dico                => $dico
                 });
              undef $iplist->{$device_id}->{IP};
              undef $iplist->{$device_id}->{ENTITY};

              if (keys %{$datadevice}) {
                 $data->{DEVICE}->[$count] = $datadevice;
                 $data->{MODULEVERSION} = $VERSION;
                 $data->{PROCESSNUMBER} = $pid;
                 $count++;
              }
           }
           if (($count == 4) || (($loopthread == 1) && ($count > 0))) {
              $maxIdx++;
              $self->{storage}->save(
                  idx  => $maxIdx,
                  data => $data
              );

              $count = 0;
           }
        }
        ##### CHANGE STATE #####
        if ($ThreadAction->{$t} == 2) { # STOP
           $ThreadState->{$t} = 2;
           $ThreadAction->{$t} = 0;
           $self->{logger}->debug("Core $p - Thread $t deleted");
           return;
        } elsif ($ThreadAction->{$t} == 1) { # PAUSE
           $ThreadState->{$t} = 0;
           $ThreadAction->{$t} = 0;
        }
    }
}

sub _manageThreads {
    my ($self, $loop_action, $exit, $loop_nbthreads, $ThreadAction, $ThreadState) = @_;

     my $count;
     my $i;
     my $loopthread;

     while (1) {
        if (($loop_action == 0) && ($exit == 2)) {
           ## Kill threads who do nothing partial ##

           ## Start + end working threads (do a function) ##
              for($i = 0 ; $i < $loop_nbthreads ; $i++) {
                 $ThreadAction->{$i} = "2";
              }
           ## Function state of working threads (if they are stopped) ##
              $count = 0;
              $loopthread = 0;

              while ($loopthread != 1) {
                 for($i = 0 ; $i < $loop_nbthreads ; $i++) {
                    if ($ThreadState->{$i} == 2) {
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

        } elsif (($loop_action == 1) && ($exit == 2)) {
           ## Start + pause working Threads (do a function) ##
              for($i = 0 ; $i < $loop_nbthreads ; $i++) {
                 $ThreadAction->{$i} = "1";
              }
           sleep 1;

           ## Function state of working threads (if they are paused) ##
           $count = 0;
           $loopthread = 0;

           while ($loopthread != 1) {
              for($i = 0 ; $i < $loop_nbthreads ; $i++) {
                 if ($ThreadState->{$i} == 0) {
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
}

sub _sendInformations{
   my ($self, $informations) = @_;

   my $config = $self->{config};

   my $message = FusionInventory::Agent::XML::Query->new(
       config => $self->{config},
       logger => $self->{logger},
       target => $self->{target},
       msg    => {
           QUERY   => 'NETDISCOVERY',
           CONTENT => $informations
       },
   );
   $self->{client}->send(message => $message);
}

sub _discovery_ip_threaded {
   my ($self, $params) = @_;

   if (!defined($params->{ip})) {
      $self->{logger}->debug("ip address empty...");
      return;
   }

   if ($params->{ip} !~ /^$ip_address_pattern$/ ) {
      $self->{logger}->debug("Invalid ip address...");
      return;
   }

   my $device;

   if ($params->{nmap_parameters}) {
      $self->_discoverByNmap($device, $params->{ip}, $params->{nmap_parameters});
   }

   if ($INC{'Net/NBName.pm'}) {
       $self->_discoverByNmap($device, $params->{ip})
   }

   if ($INC{'FusionInventory/Agent/SNMP.pm'}) {
       $self->_discoverBySNMP($device, $params->{ip}, $params->{credentials}, $params->{dico}, $params->{entity});
   }

   if ($device->{MAC}) {
      $device->{MAC} =~ tr/A-F/a-f/;
   }

   if ($device->{MAC} || $device->{DNSHOSTNAME} || $device->{NETBIOSNAME}) {
      $device->{IP}     = $params->{ip};
      $device->{ENTITY} = $params->{entity};
      $self->{logger}->debug("[$params->{ip}] ".Dumper($device));
   } else {
      $self->{logger}->debug("[$params->{ip}] Not found");
   }

   return $device;
}

sub _discoverByNmap {
    my ($self, $device, $ip, $parameters) = @_;

    my $nmapCmd = "nmap $parameters $ip -oX -";
    my $xml = `$nmapCmd`;
    $device = _parseNmap($xml);
}

sub _discoverByNetbios {
    my ($self, $device, $ip) = @_;

    $self->{logger}->debug("[$ip] : Netbios discovery");

    my $nb = Net::NBName->new();

    my $ns = $nb->node_status($ip);
    return unless $ns;

    foreach my $rr ($ns->names()) {
        if ($rr->suffix() == 0 && $rr->G() eq "GROUP") {
            $device->{WORKGROUP} = getSanitizedString($rr->name);
        }
        if ($rr->suffix() == 3 && $rr->G() eq "UNIQUE") {
            $device->{USERSESSION} = getSanitizedString($rr->name);
        }
        if ($rr->suffix() == 0 && $rr->G() eq "UNIQUE") {
            my $machine = $rr->name() unless $rr->name() =~ /^IS~/;
            $device->{NETBIOSNAME} = getSanitizedString($machine);
        }
    }

    if (!$device->{MAC} || $device->{MAC} !~ /^$mac_address_pattern$/) {
        $device->{MAC} = $ns->mac_address();
        $device->{MAC} =~ tr/-/:/; 
    }
}

sub _discoverBySNMP {
    my ($self, $device, $ip, $credentials, $dico, $entity) = @_;

    $self->{logger}->debug("[ip] : SNMP discovery");

    foreach my $credential (@{$credentials}) {

        my $snmp;
        eval {
            $snmp = FusionInventory::Agent::SNMP->new(
                version      => $credential->{VERSION},
                hostname     => $ip,
                community    => $credential->{COMMUNITY},
                username     => $credential->{USERNAME},
                authpassword => $credential->{AUTHPASSWORD},
                authprotocol => $credential->{AUTHPROTOCOL},
                privpassword => $credential->{PRIVPASSWORD},
                privprotocol => $credential->{PRIVPROTOCOL},
                translate    => 1,
            );
        };
        if ($EVAL_ERROR) {
            $self->{logger}->error("Unable to create SNMP session for $ip: $EVAL_ERROR");
            return;
        }

        my $description = $snmp->get('1.3.6.1.2.1.1.1.0');
        return unless $description;

        # ***** manufacturer specifications
        foreach my $m (@{$self->{modules}}) {
            $description = $m->discovery($description, $snmp,$description);
        }

        $device->{DESCRIPTION} = $description;

        # get first model in dictionnary matching description
        $description =~ s/\n//g;
        $description =~ s/\r//g;
        my $model = first { $_->{SYSDESCR} eq $description } @{$dico->{DEVICE}};

        $device->{SERIAL}    = _getSerial($snmp, $model);
        $device->{MAC}       = _getMacAddress($snmp, $model) || _getMacAddress($snmp);
        $device->{MODELSNMP} = $model->{MODELSNMP};
        $device->{TYPE}      = $model->{TYPE};

        $device->{AUTHSNMP} = $credential->{ID};
        $device->{SNMPHOSTNAME} = $snmp->get('.1.3.6.1.2.1.1.5.0');
        $device->{IP} = $ip;
        $device->{ENTITY} = $entity;
        $self->{logger}->debug("[$ip] ".Dumper($device));
        $snmp->close();
    }
}

sub _getSerial {
    my ($snmp, $model) = @_;

    # the model is mandatory for the serial number
    return unless $model;
    return unless $model->{SERIAL};

    my $serial = $snmp->get($model->{SERIAL});
    if (defined($serial)) {
        $serial =~ s/\n//g;
        $serial =~ s/\r//g;
        $serial =~ s/^\s+//;
        $serial =~ s/\s+$//;
        $serial =~ s/(\.{2,})*//g;
    }

    return $serial;
}

sub _getMacAddress {
    my ($snmp, $model) = @_;

    my $macAddress;

    if ($model) {
        # use model-specific oids

        if ($model->{MAC}) {
            $macAddress = $snmp->get($model->{MAC});
        }

        if (!$macAddress || $macAddress !~ /^$mac_address_pattern$/) {
            my $macs = $snmp->walk($model->{MACDYN});
            foreach my $value (values %{$macs}) {
                next if !$value;
                next if $value eq '0:0:0:0:0:0';
                next if $value eq '00:00:00:00:00:00';
                $macAddress = $value;
            }
        }
    } else {
        # use default oids

        $macAddress = $snmp->get(".1.3.6.1.2.1.17.1.1.0");

        if (!$macAddress || $macAddress !~ /^$mac_address_pattern$/) {
            my $macs = $snmp->walk(".1.3.6.1.2.1.2.2.1.6");
            foreach my $value (values %{$macs}) {
                next if !$value;
                next if $value eq '0:0:0:0:0:0';
                next if $value eq '00:00:00:00:00:00';
                $macAddress = $value;
            }
        }
    }

    return $macAddress;
}

sub _initModList {
    my ($self) = @_;

    my @modules = __PACKAGE__->getModules();
    die "no inventory module found" if !@modules;

    foreach my $module (@modules) {
        if ($module->require()) {
            push @{$self->{modules}}, $module;
        } else {
            $self->{logger}->info("failed to load $module");
        }
    }
}

sub _parseNmap {
    my ($xml) = @_;

    my $ret = {};

    return $ret unless $xml;

    my $tpp;
    eval {
        $tpp = XML::TreePP->new(force_array => '*');
    };
    return $ret unless $tpp;
    my $h = $tpp->parse($xml);
    return $ret unless $h;

    foreach my $host (@{$h->{nmaprun}[0]{host}}) {
        foreach (@{$host->{address}}) {
            if ($_->{'-addrtype'} eq 'mac') {
                $ret->{MAC} = $_->{'-addr'} unless $ret->{MAC};
                $ret->{NETPORTVENDOR} = $_->{'-vendor'} unless $ret->{NETPORTVENDOR};
            }
        }
        foreach (@{$host->{hostnames}}) {
            my $name = eval {$_->{hostname}[0]{'-name'}};
            next unless $name;
            $ret->{DNSHOSTNAME} = $name;
        }
    }

    return $ret;
}


1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetDiscovery - SNMP support for FusionInventory Agent

=head1 DESCRIPTION

This module scans your networks to get informations from devices with the SNMP protocol

=over 4

=item *
networking devices discovery within an IP range

=item *
network switches, printers and routers analysis

=item *
relation between computers / printers / switchs ports

=item *
identify unknown MAC addresses

=item *
report printer cartridge and counter status

=item *
support management of SNMP versions v1, v2, v3

=back

This plugin depends on FusionInventory for GLPI.

=head1 AUTHORS

The maintainer is David DURIEUX <d.durieux@siprossii.com>

Please read the AUTHORS, Changes and THANKS files to see who is behind
FusionInventory.

=head1 SEE ALSO

=over 4

=item
FusionInventory website: L<http://www.FusionInventory.org/>

=item

project Forge: L<http://Forge.FusionInventory.org>

=item

The source code of the agent is available on:

=over

=item

Gitorious: L<http://gitorious.org/fusioninventory>

=item

Github: L<http://github.com/fusinv/fusioninventory-agent>

=back

=item

The mailing lists:

=over

=item

L<http://lists.alioth.debian.org/mailman/listinfo/fusioninventory-devel>

=item

L<http://lists.alioth.debian.org/mailman/listinfo/fusioninventory-user>

=back

=item

IRC: #FusionInventory on FreeNode IRC Network

=back

=head1 BUGS

Please, use the mailing lists as much as possible. You can open your own bug
tickets. Patches are welcome. You can also use the bugtracker on
http://forge.fusionInventory.org

=head1 COPYRIGHT

Copyright (C) 2009 David Durieux
Copyright (C) 2010-2011 FusionInventory Team

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
