package FusionInventory::Agent::Task::Maintenance;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task';

use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Task::Deploy::Datastore;
use FusionInventory::Agent::Task::Maintenance::Version;

our $VERSION = FusionInventory::Agent::Task::Maintenance::Version::VERSION;

sub isEnabled {
    my ($self) = @_;

    if (!$self->{target}->isa('FusionInventory::Agent::Target::Scheduler')) {
        $self->{logger}->debug("Maintenance task only compatible with Scheduler target");
        return;
    }

    return 1;
}

sub run {
    my ($self, %params) = @_;

    my $logger = $self->{logger};
    my $folder = $self->{target}->getStorage()->getDirectory();
    my $datastore = FusionInventory::Agent::Task::Deploy::Datastore->new(
        config => $self->{config},
        path   => $folder.'/deploy',
        logger => $logger
    );
    $datastore->cleanUp( force => $datastore->diskIsFull() );
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::Maintenance - Maintenance for FusionInventory Agent environment

=head1 DESCRIPTION

With this module, F<FusionInventory> will maintain its environment clean
and safe.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.
