package FusionInventory::Agent::Broker::Server;

use strict;
use warnings;

use FusionInventory::Agent::HTTP::Client::OCS;

sub new {
    my ($class, %params) = @_;

    die "missing target parameter" unless $params{target};

    my $client = FusionInventory::Agent::HTTP::Client::OCS->new(
        user         => $params{user},
        password     => $params{password},
        proxy        => $params{proxy},
        ca_cert_file => $params{ca_cert_file},
        ca_cert_dir  => $params{ca_cert_dir},
        no_ssl_check => $params{no_ssl_check},
    );

    return bless {
        deviceid => $params{deviceid},
        url      => $params{target},
        client   => $client
    }, $class;
}

sub send {
    my ($self, %params) = @_;

    $self->{client}->send(
        url     => $self->{url},
        message => $params{message}
    );
}

1;
