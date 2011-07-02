package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Dell;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $session) = @_;

    if ($description =~ m/^Ethernet Switch$/ ) {
        my $description_new = $session->snmpGet({
            oid => '.1.3.6.1.4.1.674.10895.3000.1.2.100.1.0',
            up  => 1,
        });
        if (($description_new ne "null") && ($description_new ne "No response from remote host")) {
            $description = $description_new;
        }
    }

    return $description;
}

1;
