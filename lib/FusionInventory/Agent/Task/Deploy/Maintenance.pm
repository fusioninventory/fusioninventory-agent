package FusionInventory::Agent::Task::Deploy::Maintenance;

use strict;
use warnings;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Task::Deploy::Datastore;

sub new {
    my ($class, %params) = @_;

    die 'no target parameter\n' unless $params{target};
    die 'no config parameter\n' unless $params{config};

    my $self = {
        logger       => $params{logger} ||
                        FusionInventory::Agent::Logger->new(),
        config       => $params{config},
        target       => $params{target},
    };
    bless $self, $class;

    return $self;
}

sub doMaintenance {
    my ($self) = @_;

    my $folder = $self->{target}->getStorage()->getDirectory();
    my $datastore = FusionInventory::Agent::Task::Deploy::Datastore->new(
        config => $self->{config},
        path   => $folder.'/deploy',
        logger => $self->{logger}
    );

    $datastore->cleanUp( force => $datastore->diskIsFull() );
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::Deploy::Maintenance - Maintenance for Deploy task

=head1 DESCRIPTION

This module provides the Maintenance run function to cleanup Deploy environment.

=head1 FUNCTIONS

=head2 doMaintenance ( $class,  %params )

Cleanup the deploy datastore associated with the target.
