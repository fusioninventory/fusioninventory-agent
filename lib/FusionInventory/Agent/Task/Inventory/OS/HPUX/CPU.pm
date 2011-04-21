package FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;


###                                                                                                
# Version 1.1                                                                                      
# Correction of Bug n 522774                                                                       
#                                                                                                  
# thanks to Marty Riedling for this correction                                                     
#                                                                                                  
###

sub isInventoryEnabled  { 
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    if (-f '/opt/propplus/bin/cprop' && (`hpvminfo 2>&1` !~ /HPVM/)) {
        my $cpus = _parseCprop(
            command => '/opt/propplus/bin/cprop -summary -c Processors',
            logger  => $logger
        );
        $inventory->addCPU($cpus);
        return;
    }

    my $CPUinfo;
    if (can_run('/usr/contrib/bin/machinfo')) {
        $CPUinfo = _parseMachinInfo(
            command => '/usr/contrib/bin/machinfo',
            logger  => $logger
        );
    } else {
        # old HpUX without machinfo
        my %cpuInfos = (
            "D200" => { TYPE => "7100LC", SPEED => 75  },
            "D210" => { TYPE => "7100LC", SPEED => 100 },
            "D220" => { TYPE => "7300LC", SPEED => 132 },
            "D230" => { TYPE => "7300LC", SPEED => 160 },
            "D250" => { TYPE => "7200",   SPEED => 100 },
            "D260" => { TYPE => "7200",   SPEED => 120 },
            "D270" => { TYPE => "8000",   SPEED => 160 },
            "D280" => { TYPE => "8000",   SPEED => 180 },
            "D310" => { TYPE => "7100LC", SPEED => 100 },
            "D320" => { TYPE => "7300LC", SPEED => 132 },
            "D330" => { TYPE => "7300LC", SPEED => 160 },
            "D350" => { TYPE => "7200",   SPEED => 100 },
            "D360" => { TYPE => "7200",   SPEED => 120 },
            "D370" => { TYPE => "8000",   SPEED => 160 },
            "D380" => { TYPE => "8000",   SPEED => 180 },
            "D390" => { TYPE => "8200",   SPEED => 240 },
            "K360" => { TYPE => "8000",   SPEED => 180 },
            "K370" => { TYPE => "8200",   SPEED => 200 },
            "K380" => { TYPE => "8200",   SPEED => 240 },
            "K400" => { TYPE => "7200",   SPEED => 140 },
            "K410" => { TYPE => "7200",   SPEED => 120 },
            "K420" => { TYPE => "7200",   SPEED => 120 },
            "K460" => { TYPE => "8000",   SPEED => 180 },
            "K570" => { TYPE => "8200",   SPEED => 200 },
            "K580" => { TYPE => "8200",   SPEED => 240 },
            "L1000-36" => { TYPE => "8500", SPEED => 360 },
            "L1500-7x" => { TYPE => "8700", SPEED => 750 },
            "L3000-7x" => { TYPE => "8700", SPEED => 750 },
            "N4000-44" => { TYPE => "8500", SPEED => 440 },
            "ia64 hp server rx1620" => { TYPE => "itanium", SPEED => 1600 }
        );

        my $device = getFirstLine(command => 'model |cut -f 3- -d/');
        if ($cpuInfos{$device}) {
            $CPUinfo = $cpuInfos{$device};
        } else {
            foreach ( `echo 'sc product cpu;il' | /usr/sbin/cstm` ) {
                next unless /CPU Module/;
                if ( /(\S+)\s+CPU\s+Module/ ) {
                    $CPUinfo->{TYPE} = $1;
                }
            }
            foreach ( `echo 'itick_per_usec/D' | adb -k /stand/vmunix /dev/kmem` ) {
                if ( /tick_per_usec:\s+(\d+)/ ) {
                    $CPUinfo->{SPEED} = $1;
                }
            }
        }
        # NBR CPU
        $CPUinfo->{CPUcount} = getFirstLine(command => 'ioscan -Fk -C processor | wc -l');
    }

    my $serie = getFirstLine(command => 'uname -m');
    if ( $CPUinfo->{TYPE} eq 'unknow' and $serie =~ /ia64/) {
        $CPUinfo->{TYPE} = "Itanium"
    }
    if ( $serie =~ /9000/) {
        $CPUinfo->{TYPE} = "PA" . $CPUinfo->{TYPE};
    }

    foreach ( 1..$CPUinfo->{CPUcount} ) { $inventory->addCPU($CPUinfo) }
}

sub _parseMachinInfo {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my $ret = {};

    while (my $line = <$handle>) {
        $line =~ s/\s+/ /g;
        if ($line =~ /Number of CPUs = (\d+)/) {
            $ret->{CPUcount} = $1;
        } elsif ($line =~ /processor model: \d+ (.+)$/) {
            $ret->{NAME} = $1;
        } elsif ($line =~ /Clock speed = (\d+) MHz/) {
            $ret->{SPEED} = $1;
        } elsif ($line =~ /vendor information =\W+(\w+)/) {
            $ret->{MANUFACTURER} = $1;
            $ret->{MANUFACTURER} =~ s/GenuineIntel/Intel/;
        } elsif ($line =~ /Cache info:/) {
# last; #Not tested on versions other that B11.23
        }
# Added for HPUX 11.31
#        if ( /Intel\(R\) Itanium 2 9000 series processor \((\d+\.\d+)/ ) {
#            $ret->{CPUinfo}->{SPEED} = $1*1000;
#        }
        if ($line =~ /((\d+) |)(Intel)\(R\) Itanium( 2|\(R\))( \d+ series|) processor(s| 9350s|) \((\d+\.\d+)/i ) {
            $ret->{CPUcount} = $2 || 1;
            $ret->{MANUFACTURER} = $3;
            $ret->{SPEED} = $7*1000;
        }
        if ($line =~ /(\d+) logical processors/ ) {
            $ret->{CORE} = $1 / ($ret->{CPUcount} || 1);
        }
        if ($line =~ /Itanium/i) {
            $ret->{NAME} = 'Itanium';
        }
# end HPUX 11.31
    }

    return $ret;
}

sub _parseCprop {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my $cpus;
    my $instance;

    while (my $line = <$handle>) {
        if ($line =~ /^\[Instance\]: \d+/) {
            # new block
            $instance = {};
            next;
        }

        if ($line =~ /^ \s+ \[ ([^\]]+) \]: \s (.+)/x) {
            $instance->{$1} = $2;
            next;
        }

        if ($line =~ /^\*+/) {
            next unless keys %$instance;

            my $name = $instance->{'Processor Type'} =~ /Itanium/ ?
                'Itanium' : undef;
            my $manufacturer = $instance->{'Processor Type'} =~ /Intel/ ?
                'Intel' : undef;
            my $cpu = {
                SPEED        => $instance->{'Processor Speed'},
                ID           => $instance->{'Tag'},
                NAME         => $name,
                MANUFACTURER => $manufacturer
            };

            if ($instance->{'Location'} =~ /Cell Slot Number (\d+)\b/i) {
                my $slotId = $1;
                if ($cpus->[$slotId]) {
                    $cpus->[$slotId]{CORE}++;
                } else {
                    $cpus->[$slotId] = $cpu;
                    $cpus->[$slotId]{CORE}=1;
                }
            } else {
                push @$cpus, $cpu;
            }
        }
    }
    close $handle;

    my @realCpus; # without empty entry
    foreach (@$cpus) {
        push @realCpus, $_ if $_;
    }

    return \@realCpus;
}
1;
