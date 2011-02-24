package FusionInventory::Agent::Task::Deploy::Datastore;

use strict;
use warnings;

sub new {
    my (undef, $params) = @_;

    my $self = {
        path => $params->{path},
    };

    bless $self;
}

sub getPathBySha512 {
    my ($self, $sha512) = @_;

    my $filePath = $self->{path}.'/'.$sha512;

    return $filePath;
}

1;
