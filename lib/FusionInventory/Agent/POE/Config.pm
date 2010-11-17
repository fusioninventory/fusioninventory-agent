package FusionInventory::Agent::POE::Config;

use strict;
use warnings;

use POE;

use FusionInventory::Agent::Config;

sub new {
    my ($class, %params) = @_;

    my $self = {
        config => FusionInventory::Agent::Config->new(%params)
    };
    bless $self, $class;

    return $self;
}

sub createSession {
    my ($self) = @_;

    POE::Session->create(
        inline_states => {
            _start        => sub {
                $_[KERNEL]->alias_set('config');
            },
            get => sub {
                my ($kernel, $heap, $args) = @_[KERNEL, HEAP, ARG0, ARG1];
                my $key = $args->[0];
                my $rsvp = $args->[1];
                $kernel->call(IKC => post => $rsvp, $self->{config}->{$key});
            },
        }
    );

}

1;

