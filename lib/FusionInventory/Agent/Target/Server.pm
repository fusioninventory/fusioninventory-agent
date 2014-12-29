package FusionInventory::Agent::Target::Server;

use strict;
use warnings;
use base qw(FusionInventory::Agent::Target);

sub new {
    my ($class, %params) = @_;

    die "missing url parameter" unless $params{url};
    die "missing client parameter" unless $params{client};

    return bless {
        url    => $params{url},
        client => $params{client}
    }, $class;
}

sub send {
    my ($self, %params) = @_;

    return unless $params{message};

    if (ref $params{message} eq 'HASH') {
        $self->{client}->sendJSON(
            url  => $params{url},
            args => $params{message}
        );
    } else {
        $self->{client}->sendXML(
            url     => $self->{url},
            message => $params{message}
        );
    }
}

1;
