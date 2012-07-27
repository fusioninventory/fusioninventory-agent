package FusionInventory::Agent::Task::Inventory::Input::Solaris::CPU;

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

    my $class = getClass();

    my ($count, $cpu) =
        $class == SOLARIS_CONTAINER ?
            _getCPUFromPrtcl(logger => $logger)  :
            _getCPUFromMemconf(logger => $logger);

    # fallback on generic method
    ($count, $cpu) = _getCPUFromPsrinfo(logger => $logger) if !$count;

    $cpu->{MANUFACTURER} = "SPARC";

    while ($count--) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => $cpu
        );
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
# Sun Microsystems, Inc. Sun Fire V20z (Solaris x86 machine) (2 X Dual Core AMD Opteron(tm) Processor 270 1993MHz)

sub _getCPUFromMemconf {
    my $spec = getFirstMatch(
        command => 'memconf',
        pattern => qr/^((?:Sun|Fujitsu|Intel) .* \d+ [GM]Hz\))/x,
        @_
    );
    return _parseSpec($spec);
}

sub _parseCoreString {
    my ($v) = @_;

    return
        $v =~ /dual/i     ? 2  :
        $v =~ /quad/i     ? 4  :
        $v =~ /(\d+)-\w+/ ? $1 :
        $v;
}

sub _parseSpec {
    my ($spec) = @_;

    my $manufacturer;
    if ($spec =~ /(AMD|Fujitsu|Intel)\s/g) {
        $manufacturer = $1;
    } elsif ($spec =~ /Sun/) {
        $manufacturer = 'Sun Microsystems';
    }

    # 4 X UltraSPARC-III 750MHz
    if ($spec =~ /(\d+) \s X \s (\S+) \s (\d+ \s* .Hz)/x) {
        return $1, {
            MANUFACTURER => $manufacturer,
            NAME         => $2,
            SPEED        => getCanonicalSpeed($3),
            CORE         => 1,
        };
    }

    # 2 X dual-thread UltraSPARC-IV 1350MHz
    if ($spec =~ /(\d+) \s X \s (\S+) \s (\S+) \s (\d+) MHz/x) {
        return $1, {
            MANUFACTURER => $manufacturer,
            NAME         => $3 . " (" . $2 . ")",
            SPEED        => $4,
            CORE         => _parseCoreString($1),
            THREAD       => _parseCoreString($2)
        };
    }

    # 8-core quad-thread UltraSPARC-T1 1000MHz
    # 8-core 8-thread UltraSPARC-T2 1165MHz
    # 16-Core 8-Thread SPARC-T3 1649MHz
    if ($spec =~ /(\d+ -[cC]ore) \s (\S+) \s (\S+) \s (\d+) MHz/x) {
        return 1, {
            MANUFACTURER => $manufacturer,
            NAME         => $3 . " (" . $1 . " " . $2 . ")",
            SPEED        => $4,
            CORE         => _parseCoreString($1),
            THREAD       => _parseCoreString($2)
        };
    }

    # 6 X dual-core dual-thread SPARC64-VI 2150MHz
    if ($spec =~ /(\d+) \s X \s (\S+) \s (\S+) \s (\S+) \s (\d+) MHz/x) {
        return $1, {
            MANUFACTURER => $manufacturer,
            NAME         => $4 . " (" . $2 . " " . $3 . ")",
            SPEED        => $5,
            CORE         => _parseCoreString($2),
            THREAD       => _parseCoreString($3)
        };
    }

    # 2 X Dual Core AMD Opteron(tm) Processor 270 1993MHz
    if ($spec =~ /(\d+) \s X \s (\S+) \s Core \s AMD \s (Opteron\(tm\) \s Processor \s \S+) \s ([\.\d]+ \s* .Hz)/x) {
        return $1, {
            MANUFACTURER => $manufacturer,
            NAME         => $3,
            SPEED        => getCanonicalSpeed($4),
            CORE         => _parseCoreString($2),
        };
    }

    # 2 X Quad-Core Intel(R) Xeon(R) E7320 @ 2.13GHz
    if ($spec =~ /(\d+) \s X \s (\S+) \s Intel\(R\) \s (Xeon\(R\) \s E\d+) \s @ \s ([\d\.]+\s*.Hz)/x) {
        return $1, {
            MANUFACTURER => $manufacturer,
            NAME         => $3,
            SPEED        => getCanonicalSpeed($4),
            CORE         => _parseCoreString($2),
        };
    }

    # UltraSPARC-IIi 270MHz
    # UltraSPARC-III 750MHz
    if ($spec =~ /([^()\s]\S+) \s (\d+ \s* .Hz)/x) {
        return 1, {
            MANUFACTURER => $manufacturer,
            NAME         => $1,
            SPEED        => getCanonicalSpeed($2),
            CORE         => 1,
        };
    }

}

sub _getCPUFromPsrinfo {
    my (%params) = (
        command => 'psrinfo -v',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my $count = 0;
    my $cpu;
    while (my $line = <$handle>) {
        next unless $line =~ 
            /^\s+The\s(\w+)\sprocessor\soperates\sat\s(\d+)\sMHz,/;

        $cpu->{NAME}  = $1;
        $cpu->{SPEED} = $2;
        $count++;
    }
    close $handle;

    return ($count, $cpu);
}

sub _getCPUFromPrtcl {
    my (%params) = (
        command => "prctl -n zone.cpu-shares $PID",
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my ($count, $cpu);
    while (my $line = <$handle>) {
        $cpu->{NAME} = $1 if $line =~ /^zone.(\S+)$/;
        $cpu->{NAME} .= " " . $1 if $line =~ /^\s*privileged+\s*(\d+)/;
        #$count = 1 if /^\s*privileged+\s*(\d+)/;
        foreach (`memconf 2>&1`) {
            if(/\s+\((\d+).*\s+(\d+)MHz/) {
                $count = $1;
                $cpu->{SPEED} = $2;
            }
        }
    }
    close $handle;

    return ($count, $cpu);
}

1;
