package FusionInventory::Agent::Task::Deploy::CheckProcessor::FileExists;

use strict;
use warnings;

use base "FusionInventory::Agent::Task::Deploy::CheckProcessor";

sub prepare {
    my ($self) = @_;

    $self->on_failure("missing file");
    $self->on_success("file exists");
}

sub success {
    my ($self) = @_;

    return -f $self->{path};
}

1;
