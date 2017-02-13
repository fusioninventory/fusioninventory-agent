package FusionInventory::Agent::Task::Deploy::CheckProcessor::DirectoryMissing;

use strict;
use warnings;

use base "FusionInventory::Agent::Task::Deploy::CheckProcessor";

sub prepare {
    my ($self) = @_;

    $self->on_failure("directory exists");
    $self->on_success("missing directory");
}

sub success {
    my ($self) = @_;

    return ! -d $self->{path};
}

1;
