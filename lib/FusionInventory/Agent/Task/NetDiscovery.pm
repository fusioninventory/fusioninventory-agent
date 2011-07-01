package FusionInventory::Agent::Task::NetDiscovery;

use strict;
use warnings;
use threads;
use threads::shared;
if ($threads::VERSION > 1.32){
   threads->set_stack_size(20*8192);
}
use base 'FusionInventory::Agent::Task';

use constant ADDRESS_PER_THREAD => 25;
use constant DEVICE_PER_MESSAGE => 4;

use constant DELETE => 3;
use constant STOP   => 2;
use constant RUN    => 1;
use constant PAUSE  => 0;

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

    my $pid =
        sprintf("%04d", localtime->yday()) . 
        sprintf("%02d", localtime->hour()) .
        sprintf("%02d", localtime->min());

    $self->_initModList();

    my $params  = $options->{PARAM}->[0];
    my $storage = $self->{target}->getStorage();

    # take care of models dictionnary
    my $dico = $self->_getDictionnary($options, $storage, $pid);
    return unless $dico;

    # check discovery methods available
    my $nmap_parameters;
    if (canRun('nmap')) {
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
        $self->{logger}->error(
            "Can't load Net::NBName. Netbios detection can't be used!"
        );
    }

    FusionInventory::Agent::SNMP->require();
    if ($EVAL_ERROR) {
        $self->{logger}->error(
            "Can't load FusionInventory::Agent::SNMP. SNMP detection can't " .
            "be used!"
        );
    }

    # retrieve SNMP authentication credentials
    my $credentials = $options->{AUTHENTICATION};

    # manage discovery
    my $maxIdx : shared = 0;
    my $sendstart = 0;

    my $exit : shared = 0;

    my $loop_nbthreads : shared;
    my $sendbylwp : shared;

    # convert given IP ranges into a flat list of IP addresses
    my @addresses :shared;
    foreach my $range (@{$options->{RANGEIP}}) {
        next unless $range->{IPSTART};
        next unless $range->{IPEND};

        my $ip = Net::IP->new($range->{IPSTART}.' - '.$range->{IPEND});
        do {
            push @addresses, {
                IP     => $ip->ip(),
                ENTITY => $range->{ENTITY}
            };
        } while (++$ip);
    }

    # process this list by blocks of fixed size
    my @addresses_block :shared;
    my $block_size = $params->{THREADS_DISCOVERY} * ADDRESS_PER_THREAD;

    # start threads before entering the loop
    my @threads : shared;
    for (my $j = 0; $j < $params->{THREADS_DISCOVERY}; $j++) {
        $threads[$j] = {
            state  => PAUSE,
            action => PAUSE
        };

        threads->create(
            '_handleIPRange',
            $self,
            $j,
            $credentials,
            $threads[$j],
            \@addresses_block,
            $nmap_parameters,
            $dico,
            $maxIdx,
            $pid
        )->detach();

        # sleep one second every 4 threads
        sleep 1 unless $j % 4;
    }

    threads->create(
        '_manageThreads',
        $self,
        \@addresses,
        $exit,
        $loop_nbthreads,
        \@threads
    )->detach();

    while (@addresses) {
        @addresses_block = splice @addresses, 0, $block_size;

        $loop_nbthreads = $params->{THREADS_DISCOVERY};

        $exit = 2;

        # Send infos to server :
        if ($sendstart == 0) {
            $self->_sendInformations({
                AGENT => {
                    START        => '1',
                    AGENTVERSION => $FusionInventory::Agent::VERSION,
                },
                MODULEVERSION => $VERSION,
                PROCESSNUMBER => $pid
            });
            $sendstart = 1;
        }

        # Send NB ips to server :
        {
            lock $sendbylwp;
            $self->_sendInformations({
                AGENT => {
                    NBIP => scalar @addresses_block
                },
                PROCESSNUMBER => $pid
            });
        }

        my $sentxml;

        while ($exit != 1) {
            sleep 2;
            foreach my $idx (1..$maxIdx) {
                next if defined $sentxml->[$idx];

                my $data = $storage->restore(
                    idx => $idx
                );
                $self->_sendInformations($data);
                $storage->remove(
                    idx => $idx
                );

                $sentxml->[$idx] = 1;
                sleep 1;
            }
        }

        foreach my $idx (1..$maxIdx) {
            next if defined $sentxml->[$idx];

            my $data = $storage->restore(
                idx => $idx
            );
            $self->_sendInformations($data);
            $storage->remove(
                idx => $idx
            );

            $sentxml->[$idx] = 1;
            sleep 1;
        }
    }

    # Wait for threads be terminated
    sleep 1;

    # Send infos to server

    $self->_sendInformations({
        AGENT => {
            END => '1',
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $pid
    });

}

sub _getDictionnary {
    my ($self, $options, $storage, $pid) = @_;

    my ($dictionnary, $hash);

    if ($options->{DICO}) {
        # the server message contains a dictionnary, use it
        # and save it for later use
        $dictionnary = $options->{DICO};
        $hash        = $options->{DICOHASH};

        $storage->save(
            idx  => 999999,
            data => {
                dictionnary => $dictionnary,
                hash        => $hash
            }
        );
    } else {
        # no dictionnary in server message, retrieve last saved one
        my $data = $storage->restore(idx => 999999);
        $dictionnary = $data->{dictionnary};
        $hash        = $data->{hash};
    }

    # fallback on builtin dictionnary
    if (!$dictionnary || ref $dictionnary ne "HASH") {
        $dictionnary = FusionInventory::Agent::Task::NetDiscovery::Dico->new();
        $hash        = md5_hex($dictionnary);
    }

    if ($options->{DICOHASH}) {
        if ($hash eq $options->{DICOHASH}) {
            $self->{logger}->debug("Dictionnary is up to date.");
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
            $self->{logger}->debug(
                "Dictionnary is too old ($hash vs $options->{DICOHASH}), exiting"
            );
            return;
        }
    }

    $self->{logger}->debug("Dictionnary loaded.");

    return $dictionnary;
}

sub _handleIPRange {
    my ($self, $t, $credentials, $thread, $iplist, $nmap_parameters, $dico, $maxIdx, $pid) = @_;

    $self->{logger}->debug("Thread $t created");

    OUTER: while (1) {

        # wait for action
        WAIT: while (1) {
            if ($thread->{action} == DELETE) { # STOP
                $thread->{state} = STOP;
                last OUTER;
            } elsif ($thread->{action} != PAUSE) { # RUN
                $thread->{state} = RUN;
                last WAIT;
            }
            sleep 1;
        }

        # run
        my @devices;

        RUN: while (1) {
            my $item;
            {
                lock $iplist;
                $item = pop @{$iplist};
            }
            last RUN unless $item;

            my $device = $self->_probeAddress(
                ip              => $item->{IP},
                entity          => $item->{ENTITY},
                credentials     => $credentials,
                nmap_parameters => $nmap_parameters,
                dico            => $dico
            );
            push @devices, $device if $device;

            # save list each time the limit is reached
            if (@devices % DEVICE_PER_MESSAGE == 0) {
                $maxIdx++;
                $self->{storage}->save(
                    idx  => $maxIdx,
                    data => {
                        DEVICE        => \@devices,
                        MODULEVERSION => $VERSION,
                        PROCESSNUMBER => $pid,
                    }
                );
                undef @devices;
            }
        }

        # save last devices
        if (@devices) {
            $maxIdx++;
            $self->{storage}->save(
                idx  => $maxIdx,
                data => {
                    DEVICE        => \@devices,
                    MODULEVERSION => $VERSION,
                    PROCESSNUMBER => $pid,
                }
            );
        }

        # change state
        if ($thread->{action} == STOP) { # STOP
            $thread->{state}  = STOP;
            $thread->{action} = PAUSE;
            last OUTER;
        } elsif ($thread->{action} == RUN) { # PAUSE
            $thread->{state}  = PAUSE;
            $thread->{action} = PAUSE;
        }
    }

    $self->{logger}->debug("Thread $t deleted");
}

sub _manageThreads {
    my ($self, $addresses, $exit, $loop_nbthreads, $threads) = @_;

     my $count;
     my $i;
     my $loopthread;

     while (1) {
        if ((@$addresses == 0) && ($exit == 2)) {
           ## Kill threads who do nothing partial ##

           ## Start + end working threads (do a function) ##
              for($i = 0 ; $i < $loop_nbthreads ; $i++) {
                 $threads->[$i]->{action} = STOP;
              }
           ## Function state of working threads (if they are stopped) ##
              $count = 0;
              $loopthread = 0;

              while ($loopthread != 1) {
                 for($i = 0 ; $i < $loop_nbthreads ; $i++) {
                    if ($threads->[$i]->{state} == STOP) {
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

        } elsif ((@$addresses >= 0) && ($exit == 2)) {
           ## Start + pause working Threads (do a function) ##
              for($i = 0 ; $i < $loop_nbthreads ; $i++) {
                 $threads->[$i]->{action} = RUN;
              }
           sleep 1;

           ## Function state of working threads (if they are paused) ##
           $count = 0;
           $loopthread = 0;

           while ($loopthread != 1) {
              for($i = 0 ; $i < $loop_nbthreads ; $i++) {
                 if ($threads->[$i]->{state} == PAUSE) {
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

sub _probeAddress {
   my ($self, %params) = @_;

   if (!defined($params{ip})) {
      $self->{logger}->debug("ip address empty...");
      return;
   }

   if ($params{ip} !~ /^$ip_address_pattern$/ ) {
      $self->{logger}->debug("Invalid ip address...");
      return;
   }

   my $device;

   if ($params{nmap_parameters}) {
      $self->_probeAddressByNmap($device, $params{ip}, $params{nmap_parameters});
   }

   if ($INC{'Net/NBName.pm'}) {
       $self->_probeAddressByNmap($device, $params{ip})
   }

   if ($INC{'FusionInventory/Agent/SNMP.pm'}) {
       $self->_probeAddressBySNMP($device, $params{ip}, $params{credentials}, $params{dico});
   }

   if ($device->{MAC}) {
      $device->{MAC} =~ tr/A-F/a-f/;
   }

   if ($device->{MAC} || $device->{DNSHOSTNAME} || $device->{NETBIOSNAME}) {
      $device->{IP}     = $params{ip};
      $device->{ENTITY} = $params{entity};
      $self->{logger}->debug("[$params{ip}] ".Dumper($device));
   } else {
      $self->{logger}->debug("[$params{ip}] Not found");
   }

   return $device;
}

sub _probeAddressByNmap {
    my ($self, $device, $ip, $parameters) = @_;

    my $nmapCmd = "nmap $parameters $ip -oX -";
    my $xml = `$nmapCmd`;
    $device = _parseNmap($xml);
}

sub _probeAddressByNetbios {
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

sub _probeAddressBySNMP {
    my ($self, $device, $ip, $credentials, $dico) = @_;

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
            next;
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

        $device->{AUTHSNMP}     = $credential->{ID};
        $device->{SNMPHOSTNAME} = $snmp->get('.1.3.6.1.2.1.1.5.0');

        $snmp->close();

        last;
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

    my @modules = __PACKAGE__->getModules(prefix => 'Manufacturer');
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
