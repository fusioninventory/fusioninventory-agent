package FusionInventory::Agent::Output;

use strict;
use warnings;

use UNIVERSAL::require;

sub create {
    my ($class, %params) = @_;

    if ($params{target}) {
        FusionInventory::Agent::Output::Directory->require();
        return FusionInventory::Agent::Output::Directory->new(
            path    => $params{target},
            task    => $params{task},
            verbose => $params{verbose}
        );
    } else {
        FusionInventory::Agent::Output::Stdout->require();
        return FusionInventory::Agent::Output::Stdout->new(
            verbose => $params{verbose}
        );
    }
}

1;
