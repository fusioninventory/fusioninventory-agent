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
                user         => $params{config}->{http}->{user},
                password     => $params{config}->{http}->{password},
                proxy        => $params{config}->{http}->{proxy},
                timeout      => $params{config}->{http}->{timeout},
                ca_cert_file => $params{config}->{http}->{'ca-cert-file'},
                ca_cert_dir  => $params{config}->{http}->{'ca-cert-dir'},
                no_ssl_check => $params{config}->{http}->{'no-ssl-check'},
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
