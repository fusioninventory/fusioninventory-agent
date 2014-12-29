package FusionInventory::Agent::Target;

use strict;
use warnings;

use UNIVERSAL::require;

sub create {
    my ($class, %params) = @_;

    if ($params{url}) {
        require FusionInventory::Agent::Target::Server;
        require FusionInventory::Agent::HTTP::Client::Fusion;
        return FusionInventory::Agent::Target::Server->new(
            url   => $params{url},
            agent => FusionInventory::Agent::HTTP::Client::Fusion->new(
                logger       => $params{logger},
                user         => $params{user},
                password     => $params{password},
                proxy        => $params{proxy},
                ca_cert_file => $params{ca_cert_file},
                ca_cert_dir  => $params{ca_cert_dir},
                no_ssl_check => $params{no_ssl_check},
            )
        );
    }

    if ($params{path}) {
        require FusionInventory::Agent::Target::Directory;
        return FusionInventory::Agent::Target::Directory->new(
            path => $params{path}
        );
    }

    require FusionInventory::Agent::Target::Stdout;
    return FusionInventory::Agent::Target::Stdout->new();

}

1;
