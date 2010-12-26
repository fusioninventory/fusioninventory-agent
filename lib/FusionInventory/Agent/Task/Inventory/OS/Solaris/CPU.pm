package FusionInventory::Agent::Task::Inventory::OS::Solaris::CPU;

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
    my $logger = $params{logger};

    my ($spec) = getFirstMatch(
        command => 'memconf',
        logger  => $logger,
        pattern => qr/^
            (?:Sun Microsystems, Inc\.|Fujitsu)
            .*
            \(([^)]+MHz)\)
            $/x,
    );

    my $class = getClass();

    my ($count, $cpu) = 
        $class == 1 ? _getCPU1($spec) :
        $class == 2 ? _getCPU2($spec) :
        $class == 3 ? _getCPU3($spec) :
        $class == 4 ? _getCPU4($spec) :
        $class == 5 ? _getCPU5($spec) :
        $class == 7 ? _getCPU7($spec) :
                      _getCPU0($spec) ;

    $cpu->{MANUFACTURER} = "SPARC";

    while ($count--) {
        $inventory->addCPU($cpu);
    }
}

sub _getCPU0 {
    my ($spec) = @_;

    my ($count, $cpu);

    if ($spec =~ /^(\d+) \s+ X \s+ (.+) \s+ (\d+) MHz$/x) {
        $count = $1;
        $cpu = {
            NAME   => $2,
            SPEED  => $3,
            THREAD => 0
        };
    }

    # if our machine class is unknown, we use
    # psrinfo a generic methode
    if (!$count) {
        foreach (`psrinfo -v`) {
            if (/^\s+The\s(\w+)\sprocessor\soperates\sat\s(\d+)\sMHz,/) {
                $cpu->{NAME}  = $1;
                $cpu->{SPEED} = $2;
                $count++;
            }
        }
    }

    return ($count, $cpu);
}

# Sun Microsystems, Inc. Sun Fire 880 (4 X UltraSPARC-III 750MHz)
sub _getCPU1 {
    my ($spec) = @_;

    my ($count, $cpu);

    if ($spec =~ /^(\d+) \s+ X \s+ (\S+) \s+ (\d+) MHz$/x) {
        $count = $1;
        $cpu = {
            NAME   => $2,
            SPEED  => $3,
            CORE   => 1,
            THREAD => 0
        };
    } elsif ($spec =~ /^(\S+) \s+ (\d+) MHz$/x) {
        $count = 1;
        $cpu = {
            NAME   => $1,
            SPEED  => $2,
            CORE   => 1,
            THREAD => 0
        };
    }

    return ($count, $cpu);
}

# Sun Microsystems, Inc. Sun Fire V490 (2 X dual-thread UltraSPARC-IV 1350MHz)
# Sun Microsystems, Inc. Sun Fire V240 (UltraSPARC-IIIi 1002MHz)
sub _getCPU2 {
    my ($spec) = @_;

    my ($count, $cpu);

    if ($spec =~ /^(\d+) \s+ X \s+ (\S+) \s+ (\S+) \s+ (\d+) MHz$/x) {
        $count = $1;
        $cpu = {
            NAME   => $3 . " (" . $2 . ")",
            SPEED  => $4,
            CORE   => $1,
            THREAD => $2
        };
    } elsif ($spec =~ /^(\d+) \s+ X \s+ (\S+) \s+ (\d+) (\S+) MHz$/x) {
        $count = $1;
        $cpu = {
            NAME   => $2 . " (" . $1 . ")",
            SPEED  => $3,
            CORE   => $1,
            THREAD => $2
        };
    } elsif ($spec =~ /^(\S+) \s+ (\d+) MHz/x) {
        $count = 1;
        $cpu = {
            NAME   => $1,
            SPEED  => $2,
            CORE   => 1,
            THREAD => 0
        };
    }

    return ($count, $cpu);
}

# Sun Microsystems, Inc. Sun-Fire-T200 (Sun Fire T2000) (8-core quad-thread UltraSPARC-T1 1000MHz)
# Sun Microsystems, Inc. Sun-Fire-T200 (Sun Fire T2000) (4-core quad-thread UltraSPARC-T1 1000MHz)
sub _getCPU3 {
    my ($spec) = @_;

    my ($count, $cpu);

    if ($spec =~ /^(\d+) .* \s+ (\S+) \s+ (\S+) \s+ (\d+) MHz/x) {
        # T2000 has only one cCPU
        $count = $1;
        $cpu = {
            NAME   => $3 . " (" . $1 . " " . $2 . ")",
            SPEED  => $4,
            CORE   => 1,
            THREAD => $2
        };
    }

    return ($count, $cpu);
}

# Sun Microsystems, Inc. SPARC Enterprise T5120 (8-core 8-thread UltraSPARC-T2 1165MHz)
# Sun Microsystems, Inc. SPARC Enterprise T5120 (4-core 8-thread UltraSPARC-T2 1165MHz)
sub _getCPU4 {
    my ($spec) = @_;

    my ($count, $cpu);

    if ($spec =~ /^(\d+)*  (\S+) \s+ (\d+)* (\S+) \s+ (\S+) \s+ (\d+) MHz$/x) {
        $count = $1;
        $cpu = {
            NAME   => $1 . " (" . $3 . "" . $4 . ")",
            SPEED  => $6,
            CORE   => 1,
            THREAD => $3
        };
    }

    return ($count, $cpu);
}

# Sun Microsystems, Inc. Sun SPARC Enterprise M5000 Server (6 X dual-core dual-thread SPARC64-VI 2150MHz)
# Fujitsu SPARC Enterprise M4000 Server (4 X dual-core dual-thread SPARC64-VI 2150MHz)
sub _getCPU5 {
    my ($spec) = @_;

    my ($count, $cpu);

    if ($spec =~ /^(\d+) \s+ X \s+ (\S+) \s+ (\S+) \s+ (\S+) \s+ (\d+) MHz$/x) {
        $count = $1;
        $cpu = {
            NAME   => $3 . " (" . $1 . " " . $2 . ")",
            SPEED  => $5,
            CORE   => $1 . " " . $2,
            THREAD => $3
        };
    }

    return ($count, $cpu);
}

sub _getCPU7 {
    my ($spec) = @_;

    my ($count, $cpu);

    foreach (`prctl -n zone.cpu-shares $$`) {
        $cpu->{NAME} = $1 if /^zone.(\S+)$/;
        $cpu->{NAME} .= " " . $1 if /^\s*privileged+\s*(\d+)/;
        #$count = 1 if /^\s*privileged+\s*(\d+)/;
        foreach (`memconf 2>&1`) {
            if(/\s+\((\d+).*\s+(\d+)MHz/) {
                $count = $1;
                $cpu->{SPEED} = $2;
            }
        }
    }

    return ($count, $cpu);
}

1;
