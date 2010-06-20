package FusionInventory::Agent::Task::Inventory::OS::AIX::Slots;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run("lsdev");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $description;
    my $designation;
    my $name;
    my $status;  
    my @slot;
    my $flag=0;

    @slot=`lsdev -Cc bus -F 'name:description'`;
    for(@slot){	
        /^(.+):(.+)/;	
        $name = $1;
        $status = 'available';
        $designation = $2;	
        $flag=0;
        my @lsvpd = `lsvpd`;
        s/^\*// for (@lsvpd);
        for (@lsvpd){
            if ((/^AX $name/) ) {$flag=1}
            if ((/^YL (.+)/) && ($flag)){	  
                $description = $2;
            }
            if ((/^FC .+/) && $flag) {$flag=0;last}
        }	 	 
        $inventory->addSlot({
            DESCRIPTION =>  $description,
            DESIGNATION =>  $designation,
            NAME 		  =>  $name,
            STATUS	  =>  $status,
        });
    }
}

1;
