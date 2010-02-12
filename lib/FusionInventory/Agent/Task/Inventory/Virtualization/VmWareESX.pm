package FusionInventory::Agent::Task::Inventory::Virtualization::VmWareESX;

use strict;


sub isInventoryEnabled { can_run('vmware-cmd') }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};


    foreach my $vmx (`vmware-cmd -l`) {
        chomp $vmx;
        next unless -f $vmx;

        my %machineInfo;

        open VMX, "<$vmx" or warn;
        foreach (<VMX>) {
            if (/^(\S+)\s*=\s*(\S+.*)/) {
                my $key = $1;
                my $value = $2;
                $value =~ s/(^"|"$)//g;
                $machineInfo{$key} = $value;
            }
        }
        close VMX;

        my $status = 'unknow';
        if ( `vmware-cmd "$vmx" getstate` =~ /=\ (\w+)/ ) {
            # off 
            $status = $1;
        }

        my $memory = $machineInfo{'memsize'};
        my $name = $machineInfo{'displayName'};
        my $uuid = $machineInfo{'uuid.bios'};
        
        # correct uuid format
        $uuid =~ s/\s+//g;	# delete space
        $uuid =~ s!^(........)(....)(....)-(....)(.+)$!\1-\2-\3-\4-\5!; # add dashs

        my $machine = {

            MEMORY => $memory,
            NAME => $name,
            UUID => $uuid,
            STATUS => $status,
            SUBSYSTEM => "VmWareESX",
            VMTYPE => "VmWare",

        };

        $inventory->addVirtualMachine($machine);


    }
}

1;
