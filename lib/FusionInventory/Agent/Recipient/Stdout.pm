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

    return if $params{control} and !$self->{verbose};

    print $params{message}->getContent();
}

1;
