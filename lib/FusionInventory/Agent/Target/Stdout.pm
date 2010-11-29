package FusionInventory::Agent::Target::Stdout;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

my $count = 0;

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->_init(
        id     => 'stdout' . $count++,
        vardir => $params{basevardir} . '/__STDOUT__'
    );

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

=head2 getDescriptionString)

Return a string to display to user in a 'target' field.

