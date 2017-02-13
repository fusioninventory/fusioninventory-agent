package FusionInventory::Agent::Task::Deploy::CheckProcessor::FileMissing;

use strict;
use warnings;

use base "FusionInventory::Agent::Task::Deploy::CheckProcessor";

sub prepare {
    my ($self) = @_;

    $self->on_failure("file exists");
    $self->on_success("missing file");
}

sub success {
    my ($self) = @_;

    return ! -f $self->{path};
}

1;
