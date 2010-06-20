package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::Deb;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run("dpkg");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

# use dpkg-query --show --showformat='${Package}|||${Version}\n'
    foreach(`dpkg-query --show --showformat='\${Package}---\${Version}---\${Installed-Size}---\${Description}\n'`) {
        if (/^(\S+)---(\S+)---(\S+)---(.*)/) {     	     	
            $inventory->addSoftware ({
                'NAME'          => $1,
                'VERSION'       => $2,
                'FILESIZE'      => $3,
                'COMMENTS'      => $4,
                'FROM'          => 'deb'
            });
        }
    }
}

1;
