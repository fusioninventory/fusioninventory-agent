package FusionInventory::Agent::Target::Server;

use strict;
use warnings;
use base qw(FusionInventory::Agent::Target);

use FusionInventory::Agent::HTTP::Client::OCS;
use FusionInventory::Agent::HTTP::Client::Fusion;

sub new {
    my ($class, %params) = @_;

    die "missing url parameter" unless $params{url};

    my $ocs = FusionInventory::Agent::HTTP::Client::OCS->new(
        logger       => $params{logger},
        user         => $params{user},
        password     => $params{password},
        proxy        => $params{proxy},
        ca_cert_file => $params{ca_cert_file},
        ca_cert_dir  => $params{ca_cert_dir},
        no_ssl_check => $params{no_ssl_check},
    );

    my $fusion = FusionInventory::Agent::HTTP::Client::Fusion->new(
        logger       => $params{logger},
        user         => $params{user},
        password     => $params{password},
        proxy        => $params{proxy},
        ca_cert_file => $params{ca_cert_file},
        ca_cert_dir  => $params{ca_cert_dir},
        no_ssl_check => $params{no_ssl_check},
    );

    return bless {
        url    => $params{url},
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
