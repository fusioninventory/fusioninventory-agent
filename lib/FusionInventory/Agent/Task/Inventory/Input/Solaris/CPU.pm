package FusionInventory::Agent::Task::Inventory::Input::Solaris::CPU;

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

    foreach my $cpu (_getCPUs()) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => $cpu
        );
    }

}

sub _getCPUs {
    my (%params) = @_;

    # get virtual cpus from psrinfo -v
    my @vcpus = _getVirtualCPUs(logger => $params{logger});

    # get physical cpus from psrinfo -vp
    my @pcpus = _getPhysicalCPUs(logger => $params{logger});

    # consider all cpus as identical
    my $type  = $pcpus[0]->{type}  || $vcpus[0]->{type};
    my $speed = $pcpus[0]->{speed} || $vcpus[0]->{speed};
    my $manufacturer =
        $type =~ /SPARC/ ? 'SPARC' :
        $type =~ /Xeon/  ? 'Intel' :
                           undef   ;
    my $cpus  = scalar @pcpus;

    my ($cores, $threads) =
        $type eq 'UltraSPARC-IV'  ? (2,     1) : # US-IV & US-IV+
        $type eq 'UltraSPARC-T1'  ? (undef, 4) : # Niagara
        $type eq 'UltraSPARC-T2'  ? (undef, 8) : # Niagara-II
        $type eq 'UltraSPARC-T2+' ? (undef, 8) : # Victoria Falls
        $type eq 'SPARC-T3'       ? (undef, 8) : # Rainbow Falls
        $type eq 'SPARC64-VI'     ? (2,     2) : # Olympus-C SPARC64-VI
        $type eq 'SPARC64-VII'    ? (4,     2) : # Jupiter SPARC64-VII
        $type eq 'SPARC64-VII+'   ? (4,     2) : # Jupiter+ SPARC64-VII+
        $type eq 'SPARC64-VII++'  ? (4,     2) : # Jupiter++ SPARC64-VII++
        $type eq 'SPARC64-VIII'   ? (8,     2) : # Venus SPARC64-VIII
                                    (1,     1) ;

    if ($type =~ /MB86907/) {
        $type = "TurboSPARC-II $type";
    } elsif ($type =~ /MB86904|390S10/) {
        $type = ($speed > 70) ? "microSPARC-II $type" : "microSPARC $type";
    } elsif ($type =~ /,RT62[56]/) {
        $type = "hyperSPARC $type";
    }

    # deduce core numbers from number of virtual cpus if needed
    if (!$cores) {
        # cores may be < 1 in case of virtualisation
        $cores = (scalar @vcpus) / $threads / $cpus;
    }

    return
        map { 
            {
                MANUFACTURER => $manufacturer,
                NAME         => $type,
                SPEED        => $speed,
                CORE         => $cores,
                THREAD       => $threads
            }
        } 1 .. $cpus;
}

sub _getVirtualCPUs {
    my %params = (
        command => '/usr/sbin/psrinfo -v',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @cpus;
    while (my $line = <$handle>) {
        if ($line =~ /The (\S+) processor operates at (\d+) MHz/) {
            push @cpus, {
                type  => $1,
                speed => $2,
            };
            next;
        }
    }
    close $handle;

    return @cpus;
}

sub _getPhysicalCPUs {
    my %params = (
        command => '/usr/sbin/psrinfo -vp',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @cpus;
    while (my $line = <$handle>) {

        if ($line =~ /^The physical processor has (\d+) virtual/) {
            push @cpus, {
                count => $1
            };
            next;
        }

        if ($line =~ /^The (\S+) physical processor has (\d+) virtual/) {
            push @cpus, {
                type  => $1,
                count => $2
            };
            next;
        }

        if ($line =~ /(\S+) \(.* clock (\d+) MHz\)/) {
            my $cpu = $cpus[-1];
            $cpu->{type} = $1;
            $cpu->{speed} = $2;
            next;
        }

        if ($line =~ /Intel\(r\) Xeon\(r\) CPU +(\S+)/) {
            my $cpu = $cpus[-1];
            $cpu->{type} = "Xeon $1";
        }
    }
    close $handle;

    return @cpus;
}

1;
