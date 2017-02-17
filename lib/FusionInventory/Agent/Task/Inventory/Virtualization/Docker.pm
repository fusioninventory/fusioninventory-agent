package FusionInventory::Agent::Task::Inventory::Virtualization::Docker;

use strict;
use warnings;

use JSON::PP;

use FusionInventory::Agent::Task::Inventory::Virtualization;
use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('docker');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $container (_getContainers(
        logger => $logger,
        command => 'docker ps -a'
    )) {
        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $container
        );
    }
}

sub  _getContainers {
    my (%params) = @_;

    my $handle = getFileHandle(%params);

    return unless $handle;

    my $header = <$handle>;
    chomp $header;
    my @header = split /  +/, $header;
    # find PORTS index in header
    # it's the only one value that can be empty
    my $portsIndex;
    my $j = 0;
    my %header = map { $_ => $j++ } @header;
    if (defined $header{PORTS}) {
        $portsIndex = $header{PORTS};
    }

    my @containers;
    while (my $line = <$handle>) {
        chomp $line;
#        my @info = $line =~ /^(\w+)\s+(\w+)\s+"([^"]+)"   (\w+.+)   +(\w+.+)   +(\w+.+)$/;
        my @info = $line =~ /^(\S+)\s+(\S+)\s+"([^"]+)"   +(\w+.+)   +(\w+.+)   +(\w+.+)$/;
        # remove ending spaces
        @info = map { my $temp = $_ ; $temp =~ s/ +$//g; $temp } @info;

        my @split = split '   ', $info[5];
        if (scalar(@split) == 2) {
            $info[6] = $split[1];
            $info[5] = $split[0];
        } else {
            $info[6] = $info[5];
            $info[5] = '';
        }

        my $status = '';

        if ($params{command}) {
            $status = _getStatus(
                command => 'docker inspect '.$info[$header{'CONTAINER ID'}],
            );
        }
        my $container = {
            VMTYPE     => 'docker',
            UUID       => $info[$header{'CONTAINER ID'}],
            IMAGE    => $info[$header{IMAGE}],
#            COMMAND  => $info[$header{COMMAND}],
#            CREATED  => $info[$header{CREATED}],
#            PORTS    => $info[$header{PORTS}],
            NAME     => $info[$header{NAMES}],
            STATUS   => $status
        };

        push @containers, $container;

    }
    close $handle;

    return @containers;
}

sub _getStatus {
    my (%params) = @_;


    my $lines = getAllLines(%params);
    my $status = '';
    eval {
        my $coder = JSON::PP->new;
        my $containerData = $coder->decode($lines);
        $status =
            ((ref $containerData eq 'ARRAY' && $containerData->[0]->{State}->{Running})
                    || (ref $containerData eq 'HASH' && $containerData->{State}->{Running})) ?
            FusionInventory::Agent::Task::Inventory::Virtualization::STATUS_RUNNING :
            FusionInventory::Agent::Task::Inventory::Virtualization::STATUS_OFF;
    };

    return $status;
}

1;
