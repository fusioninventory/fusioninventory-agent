package FusionInventory::Agent::HTTP::Client::ArmaditoAV::Event;

use strict;
use warnings;

sub new {
    my ( $class, %params ) = @_;

    my $self = {
        event_type  => $params{jobj}->{event_type},
        end_polling => 0,
        jobj        => $params{jobj}
    };

    bless $self, $class;
    return $self;
}
1;

__END__

=head1 NAME

FusionInventory::Agent::HTTP::Client::ArmaditoAV::Event - ArmaditoAV api event class

=head1 DESCRIPTION

This is a base class for each Events used given by ArmaditoAV /api/event.

=head1 FUNCTIONS

=head2 new ( $class, %params )

Instanciate this class.

