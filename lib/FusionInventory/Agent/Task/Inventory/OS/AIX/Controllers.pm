package FusionInventory::Agent::Task::Inventory::OS::AIX::Controllers;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return unless can_run('lsdev');
    my @lsdev = `lsdev -Cc adapter -F 'name:type:description'`; 
    return 1 if @lsdev;
    0
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    my $name;
    my $type;
    my $manufacturer;

    foreach (`lsdev -Cc adapter -F 'name:type:description'`){
        chomp($_);
        /^(.+):(.+):(.+)/;
        my $name = $1;
        my $type = $2;
        my $manufacturer = $3;
        $inventory->addEntry({
            section => 'CONTROLLERS',
            entry   => {
                NAME         => $name,
                TYPE         => $type,
                MANUFACTURER => $manufacturer,
            }
        });
    }
}

1;
