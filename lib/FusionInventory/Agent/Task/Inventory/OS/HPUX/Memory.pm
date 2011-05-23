package FusionInventory::Agent::Task::Inventory::OS::HPUX::Memory;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled { 
    return $OSNAME =~ /hpux/;
}

sub getSizeInMB {
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
                my $size = getSizeInMB($instance->{Size}) || 0;
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



sub _parseMemory {
    my @list_mem = @{$_[0]};

    my $ret;
    foreach (@list_mem) {
        if (/Total Configured Memory\s*:\s(\d+)\sMB/i) {
            return $1;
        }
    }

    return;
}

sub doInventory { 
    my $params = shift;
    my $inventory = $params->{inventory};


    # HPUX 11.31: http://forge.fusioninventory.org/issues/754
    if (-f '/opt/propplus/bin/cprop' && (`hpvminfo 2>&1` !~ /HPVM guest/)) {
        my ($memories, $totalMem) = _parseCpropMemory('/opt/propplus/bin/cprop -summary -c Memory', '-|');
        $inventory->setHardware({ MEMORY => $totalMem });
        $inventory->addMemory($memories);
        return;
    }

    my @list_mem;
    if ( `uname -m` =~ /ia64/ ) {
        `echo 'sc product  IPF_MEMORY;info' | /usr/sbin/cstm`;    # enable infolog
        @list_mem=`echo 'sc product IPF_MEMORY;il' | /usr/sbin/cstm`;
        for ( @list_mem ) {
            if ( /\w+IMM\s+Location/ ) {
                next
            } elsif ( /(\w+IMM)\s+(\w+)\s+(\d+|\-+)\s+(\w+IMM)\s+(\w+)\s+(\d+|\-+)/ ) {
                $inventory->addMemory({
                        CAPACITY => $3,
                        DESCRIPTION => $1,
                        CAPTION => $1 . ' ' . $2,
                        SPEED => 'No Speed data vailable!',
                        TYPE => $1,
                        NUMSLOTS => $2,
                        SERIALNUMBER => 'No Serial Number available!',
                    });
                $inventory->addMemory({
                        CAPACITY => $6,
                        DESCRIPTION => $4,
                        CAPTION => $4 . ' ' . $5,
                        SPEED => 'No Speed data vailable!',
                        TYPE => $4,
                        NUMSLOTS => $5,
                        SERIALNUMBER => 'No Serial Number available!',
                    }); 

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

        @list_mem=`echo 'sc product mem;il'| /usr/sbin/cstm`;

        for ( @list_mem ) {

            if ( /FRU\sSource\s+=\s+\S+\s+\(memory/ ) {
                $ok=0;
                #print "FRU Source memory\n";
            }
            if ( /Source\s+Detail\s+=\s4/ ) {
                $ok=1;
                #print "Source Detail IMM\n";
            }
            if ( /Extender\s+Location\s+=\s+(\S+)/ ) {
                $subnumslot=$1;
                #print "Extended sub $subnumslot\n";
            };
            if ( /DIMMS\s+Rank\s+=\s+(\S+)/ ) {
                $numslot=sprintf("%02x",$1);
                #print "Num slot $numslot\n";
            }

            if ( /FRU\s+Name\.*:\s+(\S+)/ ) {
                if ( /(\S+)_(\S+)/ ) {
                    $type=$1;
                    $capacity=$2;
                    #print "Type $type capa $capacity\n";
                } elsif ( /(\wIMM)(\S+)/ ) {
                    $ok=1;
                    $type=$1;
                    $numslot=$2;
                    #print "Type $type numslot $numslot\n";
                }
            }
            if ( /Part\s+Number\.*:\s*(\S+)\s+/ ) {
                $description=$1;
                #print "ref $description\n";
            }
            if ( /Serial\s+Number\.*:\s*(\S+)\s+/ ) {
                $serialnumber=$1;
                if ( $ok eq 1 ) {
                    if ( $capacity eq 0 ) {
                        foreach ( @list_mem ) {
                            if ( /\s+$numslot\s+(\d+)/ ) {
                                $capacity=$1;
                                #print "Capacity $capacity\n";
                            }
                        }
                    }
                    $inventory->addMemory({
                        CAPACITY => $capacity,
                        DESCRIPTION => "Part Number $description",
                        CAPTION => "Ext $subnumslot Slot $numslot",
                        SPEED => 'No Speed data vailable!',
                        TYPE => $type,
                        NUMSLOTS => '1',
                        SERIALNUMBER => $serialnumber,
                    });
                    $ok=0;
                    $capacity=0;
                } # $ok eq 1
            } # /Serial\s+Number\.*:\s*(\S+)\s+/ 
        } # echo 'sc product system;il' | /usr/sbin/cstm
    }

    my $TotalSwapSize = `swapinfo -dt | tail -n1`;
    $TotalSwapSize =~ s/^total\s+(\d+)\s+\d+\s+\d+\s+\d+%\s+\-\s+\d+\s+\-/$1/i;
    $inventory->setHardware({ SWAP =>    sprintf("%i", $TotalSwapSize/1024) });
    $inventory->setHardware({ MEMORY => _parseMemory(\@list_mem) });

}

1;
