package FusionInventory::Agent::Target::Stdout;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    # target-specific storage object
    $self->_initStorage($params{basevardir} . '/__STDOUT__');

    # restore previous state
    $self->_loadState();

    return $self;
}

sub getDescription {
    my ($self) = @_;

    my $description = $self->SUPER::getDescription();

    $description->{type}        = 'stdout';
    $description->{destination} = 'STDOUT';

    return $description;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Target::Stdout - Stdout target

=head1 DESCRIPTION

This is a target for displaying execution result on standard output.
