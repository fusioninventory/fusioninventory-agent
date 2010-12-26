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

    while (my $line =~ <$handle>) {
        next if $line =~  /^Ap_Id/;
        next unless $line =~ /^(\S+)\s+(\S+)\s+(\S+)/;
        $name = $1;
        $type = $2;
        $manufacturer = $3;
        $inventory->addController({
            'NAME'          => $name,
            'MANUFACTURER'  => $manufacturer,
            'TYPE'          => $type,
        });
    }

    close $handle;
}

1;
