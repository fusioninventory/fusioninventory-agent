package FusionInventory::Agent::HTTP::Client::ArmaditoAV::Event::StatusEvent;

use strict;
use warnings;
use base 'FusionInventory::Agent::HTTP::Client::ArmaditoAV::Event';

sub new {
    my ( $class, %params ) = @_;

    my $self = $class->SUPER::new(%params);

    return $self;
}

sub run {
    my ( $self, %params ) = @_;

    $self->{end_polling} = 1;

    return $self;
}
1;

__END__

=head1 NAME

FusionInventory::Agent::HTTP::Client::ArmaditoAV::Event::StatusEvent - ArmaditoAV StatusEvent class

=head1 DESCRIPTION

This is the class dedicated to StatusEvent of ArmaditoAV api.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run event related stuff. Send ArmaditoAV status to Armadito Plugin for GLPI.

=head2 new ( $class, %params )

Instanciate this class.
