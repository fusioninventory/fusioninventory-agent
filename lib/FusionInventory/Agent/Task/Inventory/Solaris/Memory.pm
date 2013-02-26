package FusionInventory::Agent::Task::Inventory::Solaris::Memory;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isEnabled {
    return 1;
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
        $class == SOLARIS_CONTAINER ? _getMemoriesPrctl()   :
                                      _getMemoriesPrtdiag() ;

    foreach my $memory (@memories) {
        $inventory->addEntry(
            section => 'MEMORIES',
            entry   => $memory
        );
    }
}

sub _getMemoriesPrtdiag {
    my $handle = getFileHandle(command => 'prtdiag', @_);
    my @memories;

    # reach memory section
    my $section;
    while (my $line = <$handle>) {
        next unless $line =~ /^=+ \s ([\w\s]+) \s =+$/x;
        $section = $1;
        last if $section =~ /Memory/;
    }

    SWITCH: {
        if ($section eq 'Physical Memory Configuration') {
            @memories = _parsePhysicalMemoryConfiguration($handle);
            last;
        }

        if ($section eq 'Memory Configuration') {
            @memories = _parseMemoryConfiguration($handle);
            last;
        }

        if ($section eq 'Memory Device Sockets') {
            @memories = _parseMemoryDeviceSockets($handle);
            last;
        }
    }

    close $handle;

    return @memories;
}

sub _parsePhysicalMemoryConfiguration {
    my ($handle) = @_;

    # skip headers
    foreach my $i (1 .. 5) {
        <$handle>;
    }

    # parse content
    my @memories;
    my $slot = 0;
    while (my $line = <$handle>) {
        last if $line !~ /
            (\d+ \s [MG]B) \s+
            \S+
        $/x;

        my $capacity = getCanonicalSize($1);

        push @memories, {
            NUMSLOTS => $slot++,
            CAPACITY => $capacity
        }
    }

    return @memories;
}

sub _parseMemoryConfiguration {
    my ($handle) = @_;

    my @memories;

    # skip headers
    foreach my $i (1 .. 5) {
        <$handle>;
    }

    # parse content
    my $slot = 0;
    while (my $line = <$handle>) {
        last if $line !~ /
            (\d+ [MG]B) \s+
            \S+         \s+
            (\d+ [MG]B) \s+
            \S+         \s+
            \d
        $/x;

        my $capacity = getCanonicalSize($1);

        push @memories, {
            NUMSLOTS => $slot++,
            CAPACITY => $capacity
        }
    }

    return @memories;
}

sub _parseMemoryDeviceSockets {
    my ($handle) = @_;
    
     # skip headers
    foreach my $i (0 .. 2) {
        <$handle>;
    }

    # parse content
    my $slot = 0;
    my @memories;
    while (my $line = <$handle>) {
        last if $line !~ /^
        (\w+)             \s+
        (empty|in \s use) \s+
        \d                \s+
        \w+ (?:\s \w+)*
        /x;
        next if $2 eq 'empty';

        push @memories, {
            NUMSLOTS => $slot++,
            TYPE     => $1
        }
    }


    return @memories;
}

sub _getMemoriesPrctl {
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
