package FusionInventory::Agent::Recipient::Stdout;

use strict;
use warnings;

sub new {
    my ($class, %params) = @_;

    return bless {
        deviceid => $params{deviceid},
        verbose  => $params{verbose}
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
