package FusionInventory::Agent::Task::Inventory::Input::Solaris::Memory;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isEnabled {
    return canRun('memconf');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $memorySize = getFirstMatch(
        command => 'prtconf',
        logger  => $logger,
        pattern => qr/^Memory\ssize:\s+(\S+)/
    );

    my $swapSize = getFirstMatch(
        command => 'swap -l',
        logger  => $logger,
        pattern => qr/\s+(\d+)$/
    );

    $inventory->setHardware({
        MEMORY => $memorySize,
        SWAP =>   $swapSize
    });

    my $class = getClass();

    if (!$class) {
        $logger->debug(
            "Unknown model, impossible to detect memory configuration"
        );
        return;
    }

    my @memories =
        $class == SOLARIS_FIRE         ? _getMemories1() :
        $class == SOLARIS_FIRE_V       ? _getMemories2() :
        $class == SOLARIS_FIRE_T       ? _getMemories3() :
        $class == SOLARIS_ENTERPRISE_T ? _getMemories4() :
        $class == SOLARIS_ENTERPRISE   ? _getMemories5() :
        $class == SOLARIS_I86PC        ? _getMemories6() :
        $class == SOLARIS_CONTAINER    ? _getMemories7() :
                                         ()              ;

    foreach my $memory (@memories) {
        $inventory->addEntry(
            section => 'MEMORIES',
            entry   => $memory
        );
    }
}

sub _getMemories1 {
    my $handle = getFileHandle(command => 'memconf', @_);
    my @memories;

    my $flag = 0;
    my $flag_mt = 0;
    my $description;

    while (my $line = <$handle>) {
        if ($line =~ /^empty \w+:\s(\S+)/) {
            # the end, we unset flag
            $flag = 0;
        }

        # caption line
        if ($line =~ /^\s+Logical  Logical  Logical/) {
            $flag_mt = 1;
        }

        if ($line =~ /^-+/) {
            # delimiter, we set flag
            $flag = 1;
            next;
        }

        if ($flag_mt && $line =~ /^\s*\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) {
            # grep the type of memory modules from heading
            $flag_mt = 0;
            $description = $1;
        }

        # only grap for information if flag is set
        next unless $flag;
        if ($line =~ /^
            \s  ([A-Z])
            \s+ (\d)
            \s+ (\d)
            \s+ (\d+)MB
            \s+ \S+
            \s+ (\d+)MB
        /x) {
            my $memory = {
                CAPTION     => "Board $1 MemCtl $2",
                CAPACITY    => $5,
                DESCRIPTION => $description,
                SPEED       => undef,
                TYPE        => undef,
                NUMSLOTS    => $3
            };
            my $banksize = $4;
            foreach (1 .. ($banksize / $memory->{CAPACITY})) {
                push @memories, $memory;
            }
        }
    }
    close $handle;

    return @memories;
}

sub _getMemories2 {
    my $handle = getFileHandle(command => 'memconf', @_);
    my @memories;

    my $flag    = 0;
    my $flag_mt = 0;

    my $capacity;
    my $caption;
    my $speed;
    my $type;
    my $numslots;

    while (my $line = <$handle>) {
        if ($line =~ /^empty sockets: (.+)/) {
            # a list of empty slots, from which we extract the slot names
            $capacity = "empty";
            $numslots = 0;
            foreach my $caption (split(/ /, $1)) {
                # no empty slots -> exit loop
                last if $caption eq "None";

                push @memories, {
                    CAPACITY => $capacity,
#                            DESCRIPTION => $description,
                    CAPTION => $caption,
                    SPEED => $speed,
                    TYPE => $type,
                    NUMSLOTS => $numslots
                };
            }
            # the end, we unset flag
            $flag = 0;
        }

        if ($line =~ /Memory Module Groups/) {
            $flag = 0;
            $flag_mt = 0;
        }

        if ($line =~ /^-+/) {
            # delimiter, we set flag
            $flag = 1;
        }

        # only grap for information if flag is set
        next unless $flag;

        if ($line =~ /^\s*\S+\s+\S+\s+(\S+)/) {
            $caption = $1;
        }
        if ($line =~ /^\s*(\S+)/) {
            $numslots = $1;
        }
        if ($line =~ /^\s*\S+\s+\S+\s+\S+\s+(\d+)/){
            $capacity = $1;
        }
        push @memories, {
            CAPACITY => $capacity,
#                        DESCRIPTION => "DIMM",
            CAPTION => "Ram slot ".$numslots,
            SPEED => $speed,
            TYPE => $type,
            NUMSLOTS => $numslots
        };
        # this is the caption line
#            if (/^ID       ControllerID/) { $description = $1;}
    }
    close $handle;

    return @memories;
}

sub _getMemories3 {
    my $handle = getFileHandle(command => 'memconf', @_);
    my @memories;

    while (my $line = <$handle>) {
        if ($line =~ /^empty sockets: (.+)/) {
            # a list of empty slots, from which we extract the slot names
            foreach my $caption (split(/ /, $1)) {
                # no empty slots -> exit loop
                last if $caption eq "None";

                my $memory = {
                    CAPACITY    => "empty",
                    NUMSLOTS    => 0,
                    CAPTION     => $caption
                };
                push @memories, $memory;
            }
        }
        if ($line =~ /^socket\s+(\S+) has a (\d+)MB\s+\(\S+\)\s+(\S+)/) {
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
    close $handle;

    return @memories;
}

sub _getMemories4 {
    my $handle = getFileHandle(command => 'memconf', @_);
    my @memories;

    while (my $line = <$handle>) {
        if ($line =~ /^empty sockets: (.+)/) {
            # a list of empty slots, from which we extract the slot names
            foreach my $caption (split(/ /, $1)) {
                # no empty slots -> exit loop
                last if $caption eq "None";
                
                my $memory = {
                    CAPACITY    => "empty",
                    NUMSLOTS    => 0,
                    CAPTION     => $caption
                };
                push @memories, $memory;
            }
        }

        # socket MB/CMP0/BR0/CH0/D0 has a Samsung 501-7953-01 Rev 05 2GB FB-DIMM
        if ($line =~ /^socket\s+(\S+) has a (.+)\s+(\S+)GB\s+(\S+)$/i) {
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
    close $handle;

    return @memories;
}

sub _getMemories5 {
    my $handle = getFileHandle(command => 'memconf', @_);
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

    while (my $line = <$handle>) {
        if ($line =~ /^total memory:\s*(\S+)/) {
            $flag = 0;
        }

        if ($line =~ $flag_mt && /^\s+\S+\s+\S+\s+\S+\s+(\S+)/) {
            $flag_mt  = 0;
            $description = $1;
        }

        # Caption Line
        if ($line =~ /^Sun Microsystems/) {
            $flag_mt  = 1;
            $flag = 1;
        }

        # only grap for information if flag is set
        next unless $flag;

        if ($line =~ /^\s(\S+)\s+(\S+)/) {
            $numslots = "LSB " . $1 . " Group " . $2;
            $caption  = "LSB " . $1 . " Group " . $2;
        }
        if ($line =~ /^\s+\S+\s+\S\s+\S+\s+\S+\s+(\d+)/) {
            $capacity = $1;
        }
        if ($line =~ /^\s+\S+\s+\S\s+(\d+)/) {
            $banksize = $1;
        }
        if ($capacity > 1 ) {
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

    }
    close $handle;

    return @memories;
}

sub _getMemories6 {
    my $handle = getFileHandle(command => 'memconf', @_);

    my @memories;

    while (my $line = <$handle>) {
        if ($line =~ /^empty memory sockets: (.+)/) {
            foreach my $caption (split(/, /, $1)) {
                if ($caption eq "None") {
                    # no empty slots -> exit loop
                    last;
                }
                my $memory = {
                    DESCRIPTION => "empty",
                    CAPACITY    => 0,
                    NUMSLOTS    => 0,
                    caption     => $caption
                };
                push @memories, $memory;
            }
        }
        if ($line =~ /^socket DIMM(\d+):\s+(\d+)MB\s(\S+)/) {
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
    close $handle;

    return @memories;
}

sub _getMemories7 {
    my $handle = getFileHandle(
        command => "prctl -n project.max-shm-memory $PID",
        @_
    );

    my @memories;
    my $memory;

    while (my $line = <$handle>) {
        $memory->{DESCRIPTION} = $1 if $line =~ /^project.(\S+)$/;
        $memory->{CAPACITY} = $1 if $line =~ /^\s*system+\s*(\d+)/;

        if ($memory->{DESCRIPTION} && $memory->{CAPACITY}){
            $memory->{CAPACITY} = $memory->{CAPACITY} * 1024;
            $memory->{NUMSLOTS} = 1 ;
            $memory->{DESCRIPTION} = "Memory Allocated";
            $memory->{CAPTION} = "Memory Share";
            push @memories, $memory;
            undef $memory;
        }
    }
    close $handle;

    return @memories;
}

1;
