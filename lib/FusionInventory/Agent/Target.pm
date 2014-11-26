package FusionInventory::Agent::Target;

use strict;
use warnings;

use UNIVERSAL::require;

sub create {
    my ($class, %params) = @_;

    if ($params{url}) {
        require FusionInventory::Agent::Target::Server;
        return FusionInventory::Agent::Target::Server->new(%params);
    }

    if ($params{path}) {
        require FusionInventory::Agent::Target::Directory;
        return FusionInventory::Agent::Target::Directory->new(%params)
    }

    require FusionInventory::Agent::Target::Stdout;
    return FusionInventory::Agent::Target::Stdout->new(%params);

}

1;
