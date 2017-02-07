package FusionInventory::Agent::Task::Inventory::Virtualization::Docker;

use strict;
use warnings;

use JSON::PP;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('docker');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $container (_getContainers(logger => $logger)) {
        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $container
        );
    }
}

sub  _getContainers {
    my (%params) = (
        command => 'docker ps -a',
        @_
    );

    my $handle = getFileHandle(%params);

    return unless $handle;

    my $entete = <$handle>;
    chomp $entete;
    my @entete = split /  +/, $entete;
    # find PORTS index in header
    # it's the only one value that can be empty
    my $portsIndex;
    my $j = 0;
    my %entete = map { $_ => $j++ } @entete;
    if (defined $entete{PORTS}) {
        $portsIndex = $entete{PORTS};
    }

    my @containers;
    while (my $line = <$handle>) {
        chomp $line;
        my @info = split(/  +/, $line);
        @info = map { s/^"//; $_ } @info;
        @info = map { s/"$//; $_ } @info;

        if ( (scalar @info) < (scalar @entete) ) {
            $info[scalar @info] = '';
            @info = _rightTranslation(\@info, $portsIndex);
        }

        my $command = 'docker inspect ' . $info[$entete{'CONTAINER ID'}];
        my $lines = getAllLines(command => $command);
        my $coder = JSON::PP->new;
        my $containerData = $coder->decode($lines);
        my $status = $containerData->[0]->{State}->{Running} ?
            $FusionInventory::Agent::Task::Inventory::Virtualization::STATUS_RUNNING :
            $FusionInventory::Agent::Task::Inventory::Virtualization::STATUS_OFF;

        my $container = {
            VMTYPE     => 'docker',
            UUID       => $info[$entete{'CONTAINER ID'}],
            IMAGE    => $info[$entete{IMAGE}],
#            COMMAND  => $info[$entete{COMMAND}],
#            CREATED  => $info[$entete{CREATED}],
#            PORTS    => $info[$entete{PORTS}],
            NAME     => $info[$entete{NAMES}],
            STATUS   => $status
        };

        push @containers, $container;

    }
    close $handle;

    return @containers;
}

sub _rightTranslation {
    my ($list, $index) = @_;

    # what is last index ?
    my $i = scalar @$list - 1;
    # decrement indexes until we reach the index $index given in argument
    # it's the index that can be empty, so when reached, we set it as empty string
    while ($i > 0 && $i > $index) {
        $list->[$i] = $list->[$i - 1];

        $i--;
    }
    $list->[$index] = '';

    return @$list;
}

1;
