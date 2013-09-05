package FusionInventory::Agent::Broker::Stdout;

use strict;
use warnings;

sub new {
    my ($class, %params) = @_;

    return bless {
        verbose => $params{verbose}
    }, $class;
}

sub send {
    my ($self, %params) = @_;

    # don't display control message by default
    return unless $self->{verbose}
        or $params{message}->{h}->{CONTENT}->{DEVICE};

    print $params{message}->getContent();
}

1;
