package FusionInventory::Agent::Task::Inventory::OS::Solaris::Memory;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isInventoryEnabled {
    return can_run('memconf');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $class = getClass();

    if (!$class) {
        $logger->debug("sorry, unknown model, could not detect memory configuration");
        return;
    }

    my @memories =
        $class == 1 ? _getMemories1() :
        $class == 2 ? _getMemories2() :
        $class == 3 ? _getMemories3() :
        $class == 4 ? _getMemories4() :
        $class == 5 ? _getMemories5() :
        $class == 6 ? _getMemories6() :
        $class == 7 ? _getMemories7() :
                      ()              ;

    foreach my $memory (@memories) {
        $inventory->addMemory($memory);
    }
}

sub _getMemories1 {
    my @memories;

    my $flag = 0;
    my $flag_mt = 0;
    my $banksize;

    my $capacity;
    my $description;
    my $caption;
    my $speed;
    my $type;
    my $numslots;

    foreach(`memconf 2>&1`) {
        # if we find "empty groups:", we have reached the end and indicate that by setting flag = 0
        if (/^empty \w+:\s(\S+)/) {
            $flag = 0;
        }
        # grep the type of memory modules from heading
        if ($flag_mt && /^\s*\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) {$flag_mt=0; $description = $1;}

        # only grap for information if flag = 1
        if ($flag && /^\s*(\S+)\s+(\S+)/) { $caption = "Board " . $1 . " MemCtl " . $2; }
        if ($flag && /^\s*\S+\s+\S+\s+(\S+)/) { $numslots = $1; }
        if ($flag && /^\s*\S+\s+\S+\s+\S+\s+(\d+)/) { $banksize = $1; }
        if ($flag && /^\s*\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+)/) { $capacity = $1; }
        if ($flag) {
            foreach (1 .. ($banksize / $capacity)) {
                push @memories, {
                    CAPACITY => $capacity,
                    DESCRIPTION => $description,
                    CAPTION => $caption,
                    SPEED => $speed,
                    TYPE => $type,
                    NUMSLOTS => $numslots
                };
            }
        }
        # this is the caption line
        if (/^\s+Logical  Logical  Logical/) { $flag_mt = 1; }
        # if we find "---", we set flag = 1, and in next line, we start to look for information
        if (/^-+/){ $flag = 1; }
    }

    return @memories;
}

sub _getMemories2 {
    my @memories;

    my $flag=0;
    my $flag_mt=0;

    my $capacity;
    my $description;
    my $caption;
    my $speed;
    my $type;
    my $numslots;

    foreach(`memconf 2>&1`) {
        # if we find "empty sockets:", we have reached the end and indicate that by resetting flag = 0
        # emtpy sockets is follow by a list of emtpy slots, where we extract the slot names
        if (/^empty sockets:\s*(\S+)/) {
            $flag = 0;
            # cut of first 15 char containing the string empty sockets:
            substr ($_,0,15) = "";
            $capacity = "empty";
            $numslots = 0;
            foreach my $caption (split) {
                if ($caption eq "None") {
                    # no empty slots -> exit loop
                    last;
                }
                push @memories, {
                    CAPACITY => $capacity,
#                            DESCRIPTION => $description,
                    CAPTION => $caption,
                    SPEED => $speed,
                    TYPE => $type,
                    NUMSLOTS => $numslots
                };
            }
        }
        if (/.*Memory Module Groups.*/) {
            $flag = 0;
            $flag_mt = 0;
        }
        # we only grap for information if flag = 1
        if ($flag && /^\s*\S+\s+\S+\s+(\S+)/){ $caption = $1; }
        if ($flag && /^\s*(\S+)/){ $numslots = $1; }
        if ($flag && /^\s*\S+\s+\S+\s+\S+\s+(\d+)/){ $capacity = $1; }
        if ($flag) {
            push @memories, {
                CAPACITY => $capacity,
#                        DESCRIPTION => "DIMM",
                CAPTION => "Ram slot ".$numslots,
                SPEED => $speed,
                TYPE => $type,
                NUMSLOTS => $numslots
            };
        }
        # this is the caption line
#            if (/^ID       ControllerID/) { $description = $1;}
        # if we find "---", we set flag = 1, and in next line, we start to look for information
        if (/^-+/) {
            $flag = 1;
        }
    }

    return @memories;
}

sub _getMemories3 {
    my @memories;

    foreach(`memconf 2>&1`) {
        if (/^empty sockets:\s*(\S+)/) {
            # cut of first 15 char containing the string empty sockets:
            substr ($_,0,15) = "";
            foreach my $caption (split) {
                if ($caption eq "None") {
                    # no empty slots -> exit loop
                    last;
                }
                my $memory = {
                    CAPACITY    => "empty",
                    NUMSLOTS    => 0,
                    CAPTION     => $caption
                };
                push @memories, $memory;
            }
        }
        if (/^socket\s+(\S+) has a (\d+)MB\s+\(\S+\)\s+(\S+)/) {
            my $memory = {
                CAPTION     => $1,
                DESCRIPTION => $3,
                CAPACITY    => $2,
                TYPE        => $3,
                NUMSLOTS    => 0,
            };
            push @memories, $memory;
        }
    }

    return @memories;
}

sub _getMemories4 {
    my @memories;

    foreach(`memconf 2>&1`) {
        # if we find "empty sockets:", we have reached the end and indicate that by resetting flag = 0
        # emtpy sockets is follow by a list of emtpy slots, where we extract the slot names
        if (/^empty sockets:\s*(\S+)/) {
            # cut of first 15 char containing the string empty sockets:
            substr ($_,0,15) = "";
            foreach my $caption (split) {
                if ($caption eq "None") {
                    # no empty slots -> exit loop
                    last;
                }
                my $memory = {
                    CAPACITY    => "empty",
                    NUMSLOTS    => 0,
                    CAPTION     => $caption
                };
                push @memories, $memory;
            }
        }

        # we only grap for information if flag = 1
        # socket MB/CMP0/BR0/CH0/D0 has a Samsung 501-7953-01 Rev 05 2GB FB-DIMM
        if (/^socket\s+(\S+) has a (.+)\s+(\S+)GB\s+(\S+)$/i) {
            my $memory = {
                CAPTION     => $1,
                DESCRIPTION => $2,
                CAPACITY    => $3 * 1024,
                TYPE        => $4,
                NUMSLOTS    => 0,
            };
            push @memories, $memory;
        }
    }

    return @memories;
}

sub _getMemories5 {
    my @memories;

    my $flag = 0;
    my $flag_mt = 0;

    my $module_count = 0;
    my $banksize;

    my $capacity;
    my $description;
    my $caption;
    my $speed;
    my $type;
    my $numslots;

    foreach(`memconf 2>&1`) {
        if (/^total memory:\s*(\S+)/) { $flag = 0;}

        if ($flag_mt && /^\s+\S+\s+\S+\s+\S+\s+(\S+)/) {$flag_mt=0;  $description = $1;}

        if ($flag && /^\s(\S+)\s+(\S+)/) {
            $numslots = "LSB " . $1 . " Group " . $2;
            $caption  = "LSB " . $1 . " Group " . $2;
        }
        if ($flag && /^\s+\S+\s+\S\s+\S+\s+\S+\s+(\d+)/) { $capacity = $1; }
        if ($flag && /^\s+\S+\s+\S\s+(\d+)/) { $banksize = $1; }
        if ($flag && $capacity > 1 ) {
            foreach (1 .. ($banksize / $capacity)) {
                push @memories, {
                    CAPACITY => $capacity,
                    DESCRIPTION => $description,
                    CAPTION => $caption,
                    SPEED => $speed,
                    TYPE => $type,
                    NUMSLOTS => $module_count
                };
            }
            $module_count++;
        }
        #Caption Line
        if (/^Sun Microsystems/) {
            $flag_mt=1;
            $flag=1;
        }
    }

    return @memories;
}

sub _getMemories6 {

    my @memories;

    foreach(`memconf 2>&1`) {
        if (/^empty memory sockets:\s*(\S+)/) {
            # cut of first 22 char containing the string empty sockets:
            substr ($_,0,22) = "";
            foreach my $caption (split(/, /,$_)) {
                if ($caption eq "None") {
                    # no empty slots -> exit loop
                    last;
                }
                my $memory = {
                    DESCRIPTION => "empty",
                    SPEED       => 'n/a',
                    TYPE        => 'n/a',
                    CAPACITY    => 0,
                    NUMSLOTS    => 0,
                    caption     => $caption
                };
                push @memories, $memory;
            }
        }
        if (/^socket DIMM(\d+):\s+(\d+)MB\s(\S+)/) {
            my $memory = {
                CAPTION     => "DIMM$1",
                DESCRIPTION => "DIMM$1",
                NUMSLOTS    => $1,
                CAPACITY    => $2,
                TYPE        => $3
            };
            push @memories, $memory;
        }
    }

    return @memories;
}

sub _getMemories7 {

    my @memories;
    my $memory;

    foreach (`prctl -n project.max-shm-memory $$ 2>&1`) {
        $memory->{DESCRIPTION} = $1 if /^project.(\S+)$/;
        $memory->{CAPACITY} = $1 if /^\s*system+\s*(\d+)/;
        if ($memory->{DESCRIPTION} && $memory->{CAPACITY}){
            $memory->{CAPACITY} = $memory->{CAPACITY} * 1024;
            $memory->{NUMSLOTS} = 1 ;
            $memory->{DESCRIPTION} = "Memory Allocated";
            $memory->{CAPTION} = "Memory Share";
            push @memories, $memory;
            undef $memory;
        }
    }

    return @memories;
}

1;
