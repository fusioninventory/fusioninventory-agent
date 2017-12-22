package FusionInventory::Agent::Task::Inventory::Generic;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use English qw(-no_match_vars);
use Net::Domain qw(hostfqdn hostdomain);

sub isEnabled {
    return 1;
}

# Must be enabled to support few Generic sub-modules
sub isEnabledForRemote {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    $inventory->setOperatingSystem({
            KERNEL_NAME => $OSNAME,
            FQDN => hostfqdn(),
            DNS_DOMAIN => hostdomain()
    });
}

1;
