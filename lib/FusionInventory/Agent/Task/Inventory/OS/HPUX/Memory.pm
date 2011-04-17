package FusionInventory::Agent::Task::Inventory::OS::HPUX::Memory;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use English qw(-no_match_vars);

sub isInventoryEnabled { 
    return 1;
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    # HPUX 11.31: http://forge.fusioninventory.org/issues/754
    if (-f '/opt/propplus/bin/cprop' && (`hpvminfo 2>&1` !~ /HPVM/i)) {
        my ($memories, $totalMem) = _parseCpropMemory('/opt/propplus/bin/cprop -summary -c Memory', '-|');
        $inventory->setHardware({ MEMORY => $totalMem });
        $inventory->addMemory($memories);
        return;
    }

    my $arch = getFirstLine(command => 'uname -m');

    my $memory;

    if ($arch =~ /ia64/ ) {
        system("echo 'sc product  IPF_MEMORY;info' | /usr/sbin/cstm");    # enable infolog

        my @lines = getAllLines(
            command => "echo 'sc product IPF_MEMORY;il' | /usr/sbin/cstm"
        );

        foreach my $line (@lines) {
            if ($line =~ /\w+IMM\s+Location/ ) {
                next
            }

            if ($line =~ /(\w+IMM)\s+(\w+)\s+(\d+|\-+)\s+(\w+IMM)\s+(\w+)\s+(\d+|\-+)/ ) {
                $inventory->addEntry({
                    section => 'MEMORIES',
                    entry => {
                        CAPACITY     => $3,
                        DESCRIPTION  => $1,
                        CAPTION      => $1 . ' ' . $2,
                        TYPE         => $1,
                        NUMSLOTS     => $2,
                    }
                });
                $inventory->addEntry({
                    section => 'MEMORIES',
                    entry   => {
                        CAPACITY     => $6,
                        DESCRIPTION  => $4,
                        CAPTION      => $4 . ' ' . $5,
                        TYPE         => $4,
                        NUMSLOTS     => $5,
                    }
                }); 

            }

            if ($line =~ /Total Configured Memory\s*:\s(\d+)\sMB/i) {
                $memory = $1;
            }
        }
    } else {
        my $capacity = 0;
        my $caption; 
        my $description;
        my $numslot = 1;
        my $subnumslot;
        my $serialnumber = 'No Serial Number available!';
        my $type;
        my $ok=0;

        my @lines = getAllLines(
            command => "echo 'sc product mem;il'| /usr/sbin/cstm"
        );

        foreach my $line (@lines) {

            if ($line =~ /FRU\sSource\s+=\s+\S+\s+\(memory/ ) {
                $ok=0;
            }
            if ($line =~ /Source\s+Detail\s+=\s4/ ) {
                $ok=1;
            }
            if ($line =~ /Extender\s+Location\s+=\s+(\S+)/ ) {
                $subnumslot=$1;
            };
            if ($line =~ /DIMMS\s+Rank\s+=\s+(\S+)/ ) {
                $numslot=sprintf("%02x",$1);
            }

            if ($line =~ /FRU\s+Name\.*:\s+(\S+)/ ) {
                if ($line =~ /(\S+)_(\S+)/ ) {
                    $type=$1;
                    $capacity=$2;
                } elsif ($line =~ /(\wIMM)(\S+)/ ) {
                    $ok=1;
                    $type=$1;
                    $numslot=$2;
                }
            }
            if ($line =~ /Part\s+Number\.*:\s*(\S+)\s+/ ) {
                $description=$1;
            }
            if ($line =~ /Serial\s+Number\.*:\s*(\S+)\s+/ ) {
                $serialnumber=$1;
                if ( $ok eq 1 ) {
                    if ( $capacity eq 0 ) {
                        foreach ( @lines ) {
                            if ( /\s+$numslot\s+(\d+)/ ) {
                                $capacity=$1;
                                #print "Capacity $capacity\n";
                            }
                        }
                    }
                    $inventory->addEntry({
                        section => 'MEMORIES',
                        entry   => {
                            CAPACITY     => $capacity,
                            DESCRIPTION  => "Part Number $description",
                            CAPTION      => "Ext $subnumslot Slot $numslot",
                            TYPE         => $type,
                            NUMSLOTS     => '1',
                            SERIALNUMBER => $serialnumber,
                        }
                    });
                    $ok=0;
                    $capacity=0;
                } # $ok eq 1
            } # /Serial\s+Number\.*:\s*(\S+)\s+/ 

            if ($line =~ /Total Configured Memory\s*:\s(\d+)\sMB/i) {
                $memory = $1;
            }
        } # echo 'sc product system;il' | /usr/sbin/cstm
    }

    my $TotalSwapSize = `swapinfo -dt | tail -n1`;
    $TotalSwapSize =~ s/^total\s+(\d+)\s+\d+\s+\d+\s+\d+%\s+\-\s+\d+\s+\-/$1/i;
    $inventory->setHardware({ SWAP =>    sprintf("%i", $TotalSwapSize/1024) });
    $inventory->setHardware({ MEMORY => $memory });

}

sub _getSizeInMB {
    my ($data) = @_;

    return unless $data;

    my %convert = (
        TB => 1000 * 1000,
        GB => 1000,
        MB => 1
    );

    if ($data =~ /^(\d+)\s*(\S+)/) {
        return $1*$convert{$2};
    }

    return $data;
}

sub _parseCpropMemory {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my $totalMem = 0;
    my $memories = [];
    my $instance = {};
    foreach (<$handle>) {
        if (keys (%$instance) && /\[Instance\]: \d+/) {
            next;
        } elsif (/^\s*\[([^\]]*)\]:\s+(\S+.*)/) {
            my $k = $1;
            my $v = $2;
            $v =~ s/\s+\*+//;
            $instance->{$k} = $v;
        }

        if (keys (%$instance) && /\*\*\*\*/) {
            if ($instance->{Size}) {
                my $size = _getSizeInMB($instance->{Size}) || 0;
                $totalMem += $size;
                push @$memories, {
                    CAPACITY => $size,
                    DESCRIPTION => $instance->{'Part Number'},
                    SERIALNUMBER => $instance->{'Serial Number'},
                    TYPE => $instance->{'Module Type'},
                };
            }
            $instance = {};
        }
    }
    close $handle;

    return ($memories, $totalMem)
}

1;
