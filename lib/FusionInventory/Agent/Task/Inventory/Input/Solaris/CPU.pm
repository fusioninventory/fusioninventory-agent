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

    my $info = getPrtconfInfos(file => shift);

    # extract cpu-specific nodes from prtconf output
    # there is one such node foreach of cpu count * core count * thread count
    my $root_node_key = first { /0x/ } keys %$info;
    my $root_node = $info->{$root_node_key};
    my @cpu_nodes = find_cpu_nodes($root_node);

    # all nodes are equals
    my $type = $cpu_nodes[0]->{compatible};
    $type = $type->[0] if ref $type eq 'ARRAY';
    $type =~ s/[A-Z]+,//;
    my $speed  = int(hex($cpu_nodes[0]->{frequency}) / 10000 + 0.5);

    # get physical cpu count from prsinfo
    my $cpus = getFirstLine(command => '/usr/sbin/psrinfo -p') || 1;

    # deduce core and thread count from cpu type and nodes count
    my $cores   = 1;
    my $threads = 1;

    if ($type =~ /MB86907/) {
        $type = "TurboSPARC-II $type";
    } elsif ($type =~ /MB86904|390S10/) {
        $type = ($speed > 70) ? "microSPARC-II $type" : "microSPARC $type";
    } elsif ($type =~ /,RT62[56]/) {
        $type = "hyperSPARC $type";
    } elsif ($type =~ /UltraSPARC-IV/) {
        # Dual-Core US-IV & US-IV+
        $cores = 2;
    } elsif ($type =~ /UltraSPARC-T1\b/) {
        # 4-Thread (4, 6, or 8 Core) Niagara
        $threads = 4;
        $cores = (scalar @cpu_nodes) / $cpus / $threads;
    } elsif ($type =~ /UltraSPARC-T2\+/) {
        # 8-Thread (4, 6, or 8 Core) Victoria Falls
        $threads = 8;
        $cores = (scalar @cpu_nodes) / $cpus / $threads;
    } elsif ($type =~ /UltraSPARC-T2\b/) {
        # 8-Thread (4 or 8 Core) Niagara-II
        $threads = 8;
        $cores = (scalar @cpu_nodes) / $cpus / $threads;
    } elsif ($type =~ /SPARC-T3\b/) {
        # 8-Thread (8 or 16 Core) Rainbow Falls
        $threads = 8;
        $cores = (scalar @cpu_nodes) / $cpus / $threads;
    } elsif ($type =~ /SPARC64-VI\b/) {
        # Dual-Core Dual-Thread Olympus-C SPARC64-VI
        $cores = 2;
        $threads = 2;
        # $cpus = (scalar @cpu_nodes) / $cores / $threads;
    } elsif ($type =~ /SPARC64-VII\+\+\b/) {
        # Quad-Core Dual-Thread Jupiter++ SPARC64-VII++
        $cores = 4;
        $threads = 2;
        # $cpus = (scalar @cpu_nodes) / $cores / $threads;
    } elsif ($type =~ /SPARC64-VII\+\b/) {
        # Quad-Core Dual-Thread Jupiter+ SPARC64-VII+
        $cores = 4;
        $threads = 2;
        # $cpus = (scalar @cpu_nodes) / $cores / $threads;
    } elsif ($type =~ /SPARC64-VII\b/) {
        # Quad-Core Dual-Thread Jupiter SPARC64-VII
        $cores = 4;
        $threads = 2;
        # $cpus = (scalar @cpu_nodes) / $cores / $threads;
    } elsif ($type eq "SPARC64-VIII") {
        # 8-Core Dual-Thread Venus SPARC64-VIII
        $cores = 8;
        $threads = 2;
        # $cpus = (scalar @cpu_nodes) / $cores / $threads;
    }

    while ($cpus--) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => {
                MANUFACTURER => 'SPARC',
                NAME         => $type,
                SPEED        => getCanonicalSpeed($speed),
                CORE         => $cores,
                THREAD       => $threads
            }
        );
    }
}

sub _find_cpu_nodes {
    my ($node) = @_;

    my @cpu_nodes;

    # recurse
    foreach my $key (grep { /0x/ } keys %$node) {
        push @cpu_nodes, _find_cpu_nodes($node->{$key});
    }

    return unless $node->{device_type};
    return unless $node->{device_type} eq 'cpu';

    push @cpu_nodes, {
        compatible => $node->{'compatible'},
        frequency  => $node->{'clock-frequency'}
    };

    return @cpu_nodes;
}

1;
