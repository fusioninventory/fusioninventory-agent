package FusionInventory::Agent::Task::Inventory::OcsDeploy;

use strict;
use warnings;


use Data::Dumper;

sub doInventory {

    my $params = shift;
    my $inventory = $params->{inventory};
    my $storage   = $params->{storage};

    # Retrieve FusionInventory::Agent::Task::OcsDeploy informations
    my $ocsDeployData =
    $storage->restore({
            module => 'FusionInventory::Agent::Task::OcsDeploy'
        });

    # Record in the Inventory the commands already recieved by the agent
    foreach my $orderId ( keys %{ $ocsDeployData->{byId} } ) {
        $inventory->addSoftwareDeploymentPackage({ ORDERID => $orderId });
    }

}

1;

