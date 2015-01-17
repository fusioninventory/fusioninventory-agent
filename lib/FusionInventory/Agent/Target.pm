package FusionInventory::Agent::Target;

use strict;
use warnings;

use UNIVERSAL::require;

sub create {
    my ($class, %params) = @_;

    my $spec = $params{spec};

    if ($spec && $spec =~ m{^https?://}) {
        # url specification
        FusionInventory::Agent::Target::Server->require();
        FusionInventory::Agent::HTTP::Client::GLPI->require();
        return FusionInventory::Agent::Target::Server->new(
            url   => $spec,
            agent => FusionInventory::Agent::HTTP::Client::GLPI->new(
                logger       => $params{logger},
                user         => $params{config}->{user},
                password     => $params{config}->{password},
                proxy        => $params{config}->{proxy},
                timeout      => $params{config}->{timeout},
                ca_cert_file => $params{config}->{'ca-cert-file'},
                ca_cert_dir  => $params{config}->{'ca-cert-dir'},
                no_ssl_check => $params{config}->{'no-ssl-check'},
            )
        );
    }

    if ($spec) {
        # path specification
        FusionInventory::Agent::Target::Directory->require();
        return FusionInventory::Agent::Target::Directory->new(
            path => $spec
        );
    }

    # no specification
    FusionInventory::Agent::Target::Stdout->require();
    return FusionInventory::Agent::Target::Stdout->new();
}

1;
