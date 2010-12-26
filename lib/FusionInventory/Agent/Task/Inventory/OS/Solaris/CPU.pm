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

    my $class = getClass();

    my ($count, $cpu) = 
        $class == 7 ? _getCPUFromPrtcl($logger)  :
                      _getCPUFromMemconf($logger);

    # fallback on generic method
    if (!$count) {
        foreach (`psrinfo -v`) {
            if (/^\s+The\s(\w+)\sprocessor\soperates\sat\s(\d+)\sMHz,/) {
                $cpu->{NAME}  = $1;
                $cpu->{SPEED} = $2;
                $count++;
            }
        }
    }

    $cpu->{MANUFACTURER} = "SPARC";

    while ($count--) {
        $inventory->addCPU($cpu);
    }
}


# Sun Microsystems, Inc. Sun Fire 880 (4 X UltraSPARC-III 750MHz)
# Sun Microsystems, Inc. Sun Fire V490 (2 X dual-thread UltraSPARC-IV 1350MHz)
# Sun Microsystems, Inc. Sun Fire V240 (UltraSPARC-IIIi 1002MHz)
# Sun Microsystems, Inc. Sun-Fire-T200 (Sun Fire T2000) (8-core quad-thread UltraSPARC-T1 1000MHz)
# Sun Microsystems, Inc. Sun-Fire-T200 (Sun Fire T2000) (4-core quad-thread UltraSPARC-T1 1000MHz)
# Sun Microsystems, Inc. SPARC Enterprise T5120 (8-core 8-thread UltraSPARC-T2 1165MHz)
# Sun Microsystems, Inc. SPARC Enterprise T5120 (4-core 8-thread UltraSPARC-T2 1165MHz)
# Sun Microsystems, Inc. Sun SPARC Enterprise M5000 Server (6 X dual-core dual-thread SPARC64-VI 2150MHz)
# Fujitsu SPARC Enterprise M4000 Server (4 X dual-core dual-thread SPARC64-VI 2150MHz)

sub _getCPUFromMemconf {
    my ($logger) = @_;

    my ($spec) = getFirstMatch(
        command => 'memconf',
        logger  => $logger,
        pattern => qr/^
            (?:Sun Microsystems, Inc\.|Fujitsu)
            .*
            \(([^)]+MHz)\)
            $/x,
    );
    return _parseSpec($spec);
}

sub _parseSpec {
    my ($spec) = @_;

    # UltraSPARC-III 750MHz
    if ($spec =~ /^(\S+) \s (\d+) MHz$/x) {
        return 1,  {
            NAME   => $1,
            SPEED  => $2,
            CORE   => 1,
            THREAD => 0
        };
    }

    # 4 X UltraSPARC-III 750MHz
    if ($spec =~ /^(\d+) \s X \s (\S+) \s (\d+) MHz$/x) {
        return $1, {
            NAME   => $2,
            SPEED  => $3,
            CORE   => 1,
            THREAD => 0
        };
    }

    # 2 X dual-thread UltraSPARC-IV 1350MHz
    if ($spec =~ /^(\d+) \s X \s (\S+) \s (\S+) \s (\d+) MHz$/x) {
        return $1, {
            NAME   => $3 . " (" . $2 . ")",
            SPEED  => $4,
            CORE   => $1,
            THREAD => $2
        };
    }

    # 8-core quad-thread UltraSPARC-T1 1000MHz
    # 8-core 8-thread UltraSPARC-T2 1165MHz
    if ($spec =~ /^(\d+) -core \s (\S+) \s (\S+) \s (\d+) MHz/x) {
        return $1, {
            NAME   => $3 . " (" . $1 . " " . $2 . ")",
            SPEED  => $4,
            CORE   => 1,
            THREAD => $2
        };
    }

    # 6 X dual-core dual-thread SPARC64-VI 2150MHz
    if ($spec =~ /^(\d+) \s X \s (\S+) \s (\S+) \s (\S+) \s (\d+) MHz/x) {
        return $1, {
            NAME   => $4 . " (" . $2 . " " . $3 . ")",
            SPEED  => $5,
            CORE   => $1 . " " . $2,
            THREAD => $3
        };
    }

}

sub _getCPUFromPrtcl {
    my ($logger) = @_;

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
