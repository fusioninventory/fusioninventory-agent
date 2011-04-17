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
    my $logger    = $params->{logger};

    my ($memories, $memorySize, $swapSize);

    # HPUX 11.31: http://forge.fusioninventory.org/issues/754
    if (-f '/opt/propplus/bin/cprop' && (`hpvminfo 2>&1` !~ /HPVM/i)) {
        ($memories, $memorySize) = _parseCprop(
            command => '/opt/propplus/bin/cprop -summary -c Memory',
            logger  => $logger
        );
    } else {
        my $arch = getFirstLine(command => 'uname -m');

        if ($arch =~ /ia64/ ) {
            # enable infolog
            system("echo 'sc product  IPF_MEMORY;info' | /usr/sbin/cstm");
            ($memories, $memorySize) = _parseCstm64(
                command => "echo 'sc product IPF_MEMORY;il' | /usr/sbin/cstm",
                logger  => $logger
            );
        } else {
            ($memories, $memorySize) = _parseCstm(
                command => "echo 'sc product mem;il'| /usr/sbin/cstm",
                logger  => $logger
            );
        }
    }

    $swapSize = `swapinfo -dt | tail -n1`;
    $swapSize =~ s/^total\s+(\d+)\s+\d+\s+\d+\s+\d+%\s+\-\s+\d+\s+\-/$1/i;

    foreach my $memory (@$memories) {
        $inventory->addEntry({
            section => 'MEMORIES',
            entry   => $memory
        });
    }

    $inventory->setHardware({
        SWAP   => sprintf("%i", $swapSize/1024),
        MEMORY => $memorySize
    });
}

sub _parseCprop {
    my $handle = getFileHandle(@_);

    return unless $handle;

    my $size = 0;
    my @memories;
    my $memory;

    while (my $line = <$handle>) {
        if ($line =~ /\[Instance\]: \d+/) {
            next;
        }

        if ($line =~ /^\s*\[([^\]]*)\]:\s+(\S+.*)/) {
            my $k = $1;
            my $v = $2;
            $v =~ s/\s+\*+//;
            $memory->{$k} = $v;
        }

        if ($line =~ /\*\*\*\*/) {
            if ($memory->{Size}) {
                $size += getCanonicalSize($memory->{Size}) || 0;
                push @memories, {
                    CAPACITY => $size,
                    DESCRIPTION => $memory->{'Part Number'},
                    SERIALNUMBER => $memory->{'Serial Number'},
                    TYPE => $memory->{'Module Type'},
                };
            }
            undef $memory;
        }
    }
    close $handle;

    return (\@memories, $size);
}

sub _parseCstm {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my (@memories, $size);

    my %capacities;
    my $capacity = 0;
    my $caption; 
    my $description;
    my $numslot = 1;
    my $subnumslot;
    my $serialnumber = 'No Serial Number available!';
    my $type;
    my $ok=0;

    while (my $line = <$handle>) {

        if ($line =~ /FRU\sSource\s+=\s+\S+\s+\(memory/ ) {
            $ok=0;
        }
        if ($line =~ /Source\s+Detail\s+=\s4/ ) {
            $ok=1;
        }
        if ($line =~ /\s+(\d+)\s+(\d+)/ ) {
            $capacities{$1} = $2;
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
                    $capacity = $capacities{$numslot};
                }
                push @memories, {
                    CAPACITY     => $capacity,
                    DESCRIPTION  => "Part Number $description",
                    CAPTION      => "Ext $subnumslot Slot $numslot",
                    TYPE         => $type,
                    NUMSLOTS     => '1',
                    SERIALNUMBER => $serialnumber,
                };
                $ok=0;
                $capacity=0;
            } # $ok eq 1
        } # /Serial\s+Number\.*:\s*(\S+)\s+/ 

        if ($line =~ /Total Configured Memory\s*:\s(\d+)\sMB/i) {
            $size = $1;
        }
    }
    close $handle;

    return (\@memories, $size);
}

sub _parseCstm64 {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my (@memories, $size);

    while (my $line = <$handle>) {

        if ($line =~ /
            (\w+IMM)\s+(\w+)\s+(\d+|\-+) # first column
            \s+
            (\w+IMM)\s+(\w+)\s+(\d+|\-+) # second column
            /x
        ) {
            push @memories, 
                {
                    CAPACITY     => $3,
                    DESCRIPTION  => $1,
                    CAPTION      => $1 . ' ' . $2,
                    TYPE         => $1,
                    NUMSLOTS     => $2,
                },
                {
                    CAPACITY     => $6,
                    DESCRIPTION  => $4,
                    CAPTION      => $4 . ' ' . $5,
                    TYPE         => $4,
                    NUMSLOTS     => $5,
                };
        }

        if ($line =~ /Total Configured Memory\s*:\s(\d+)\sMB/i) {
            $size = $1;
        }
    }
    close $handle;

    return (\@memories, $size);
}

1;
