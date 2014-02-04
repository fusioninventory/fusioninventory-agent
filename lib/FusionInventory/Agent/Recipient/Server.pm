package FusionInventory::Agent::Recipient::Server;

use strict;
use warnings;

use FusionInventory::Agent::HTTP::Client::OCS;
use FusionInventory::Agent::HTTP::Client::Fusion;

sub new {
    my ($class, %params) = @_;

    die "missing target parameter" unless $params{target};

    my $ocs = FusionInventory::Agent::HTTP::Client::OCS->new(
        user         => $params{user},
        password     => $params{password},
        proxy        => $params{proxy},
        ca_cert_file => $params{ca_cert_file},
        ca_cert_dir  => $params{ca_cert_dir},
        no_ssl_check => $params{no_ssl_check},
    );

    my $fusion = FusionInventory::Agent::HTTP::Client::Fusion->new(
        user         => $params{user},
        password     => $params{password},
        proxy        => $params{proxy},
        ca_cert_file => $params{ca_cert_file},
        ca_cert_dir  => $params{ca_cert_dir},
        no_ssl_check => $params{no_ssl_check},
    );

    return bless {
        url    => $params{target},
        ocs    => $ocs,
        fusion => $fusion
    }, $class;
}

sub send {
    my ($self, %params) = @_;

    return unless $params{message};

    if (ref $params{message} eq 'HASH') {
        $self->{fusion}->send(
            url  => $params{url},
            args => $params{message}
        );
    } else {
        $self->{ocs}->send(
            url     => $self->{url},
            message => $params{message}
        );
    }
}

1;
