package FusionInventory::Agent::Task::Inventory::OS::Solaris::Controllers;
use strict;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('cfgadm');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger = $params{logger};

    my $handle = getFileHandle(
        command => 'cfgadm -s cols=ap_id:type:info',
        logger  => $logger,
    );

    return unless $handle;

    my $name;
    my $type;
    my $manufacturer;

    while (<$handle>) {
        next if (/^Ap_Id/);
        if(/^(\S+)\s+/){
            $name = $1;
        }
        if(/^\S+\s+(\S+)/){
            $type = $1;
        }
#No manufacturer, but informations about controller
        if(/^\S+\s+\S+\s+(\S+)/){
            $manufacturer = $1;
        }
        $inventory->addController({
            'NAME'          => $name,
            'MANUFACTURER'  => $manufacturer,
            'TYPE'          => $type,
        });
    }

    close $handle;
}

1
