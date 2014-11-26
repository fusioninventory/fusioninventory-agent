package FusionInventory::Agent::Target::Stdout;

use strict;
use warnings;
use base qw(FusionInventory::Agent::Target);

use JSON;

sub new {
    my ($class, %params) = @_;

    return bless {
    }, $class;
}

sub send {
    my ($self, %params) = @_;

    return unless $params{message};
    return unless $params{filename};

    if (ref $params{message} eq 'HASH') {
        print to_json($params{message}, { ascii => 1, pretty => 1 } );
    } else {
        print $params{message}->getContent();
    }
    print "\n";
}

1;
