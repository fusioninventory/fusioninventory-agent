package FusionInventory::Agent::Task::Deploy::CheckProcessor::DirectoryExists;

use strict;
use warnings;

use base "FusionInventory::Agent::Task::Deploy::CheckProcessor";

sub prepare {
    my ($self) = @_;

    $self->on_failure("missing directory");
    $self->on_success("directory exists");
}

sub success {
    my ($self) = @_;

    return -d $self->{path};
}

1;
