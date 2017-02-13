package FusionInventory::Agent::Task::Deploy::CheckProcessor::FreeSpaceGreater;

use strict;
use warnings;

use base "FusionInventory::Agent::Task::Deploy::CheckProcessor";

use FusionInventory::Agent::Task::Deploy::DiskFree;

sub prepare {
    my ($self) = @_;

    $self->on_success("free space is greater");
}

sub success {
    my ($self) = @_;
    $self->on_failure("No value provided to check free space again");
    my $lower = $self->{value};
    return 0 unless (defined($lower));

    $self->on_failure("free space not found");
    my $freespace = getFreeSpace(
        logger => $self->{logger},
        path   => $self->{path}
    );
    return 0 unless (defined($freespace));

    $self->on_failure("free space not greater: $freespace <= $lower");
    return ( $freespace > $lower );
}

1;
