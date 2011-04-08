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

    foreach my $line (`lsdev -Cc adapter -F 'name:type:description'`){
        next unless $line =~ /^(.+):(.+):(.+)/;
        $inventory->addEntry({
            section => 'CONTROLLERS',
            entry   => {
                NAME         => $1,
                TYPE         => $2,
                MANUFACTURER => $3,
            }
        });
    }
}

1;
