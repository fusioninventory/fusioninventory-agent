package FusionInventory::Agent::Output;

use strict;
use warnings;

use UNIVERSAL::require;

sub create {
    my ($class, %params) = @_;

    if ($params{target} && $params{target} =~ m{^https?://}) {
        FusionInventory::Agent::Output::Server->require();
        return FusionInventory::Agent::Output::Server->new(%params);
    } elsif ($params{target}) {
        FusionInventory::Agent::Output::Directory->require();
        return FusionInventory::Agent::Output::Directory->new(%params);
    } else {
        FusionInventory::Agent::Output::Stdout->require();
        return FusionInventory::Agent::Output::Stdout->new(%params);
    }
}

1;
