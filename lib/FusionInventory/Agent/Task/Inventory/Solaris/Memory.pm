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
    while (my $line = <$handle>) {
        next unless $line =~ /^=+ [\w\s]+ Memory [\w\s]+ =+$/x;
        last;
    }

    # parse headers
    my %headers;
    while (my $line = <$handle>) {

        # first header line
        next unless $line =~ /Bank/;
        while ($line =~ /(\S+)/g) {
            my $offset = $LAST_MATCH_START[0];
            $headers{$offset} = lc($1);
        }

        # second header line
        $line = <$handle>;
        while ($line =~ /(\S+)/g) {
            my $offset = $LAST_MATCH_START[0];
            $headers{$offset} = $headers{$offset} ?
                $headers{$offset} . '_' . lc($1) :
                lc($1);
        }

        # intermediate line
        $line = <$handle>;
        last;
    }

    # compute offset and length of interesting columns
    my @offsets = sort keys %headers;
    my %columns;
    foreach my $i (0 .. $#offsets) {
        my $offset = $offsets[$i];
        my $length = $offsets[$i + 1] ?
            $offsets[$i + 1] - $offsets[$i] :
            78               - $offsets[$i] ; # assume 78 chars output
        my $header = $headers{$offset};

        $columns{$header} = {
            offset => $offset,
            length => $length
        };
    }

    my $slot = 0;
    while (my $line = <$handle>) {
        last if $line =~ /^$/;

        my $capacity = substr(
            $line,
            $columns{bank_size}->{offset},
            $columns{bank_size}->{length}
        );

        $capacity =~ s/^\s+//;
        $capacity =~ s/\s+$//;

        $capacity = getCanonicalSize($capacity);

        push @memories, {
            NUMSLOTS => $slot++,
            CAPACITY => $capacity
        }
    }

    close $handle;

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
