package FusionInventory::Agent::Recipient::Stdout;

use strict;
use warnings;

use JSON;

sub new {
    my ($class, %params) = @_;

    return bless {
        verbose  => $params{verbose}
    }, $class;
}

sub send {
    my ($self, %params) = @_;

    return unless $params{message};
    return if $params{control} and !$self->{verbose};

    if (ref $params{message} eq 'HASH') {
        print to_json($params{message}, { ascii => 1, pretty => 1 } );
    } else {
        print $params{message}->getContent();
    }
    print "\n";
}

1;
