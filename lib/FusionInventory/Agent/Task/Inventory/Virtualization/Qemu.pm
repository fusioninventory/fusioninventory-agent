package FusionInventory::Agent::Task::Inventory::Virtualization::Qemu;
# With Qemu 0.10.X, some option will be added to get more and easly information (UUID, memory, ...)

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 
        can_run('qemu') ||
        can_run('kvm')  ||
        can_run('qemu-kvm');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach ( `ps -ef` ) {
        # match only if an qemu instance
        next unless /^.*((qemu|kvm|(qemu-kvm)).*\-([fh]d[a-d]|cdrom).*)$/;
            
        my $name = "N/A";
        my $mem = 0;
        my $uuid;
        my $vmtype = $2;
                    
        my @process = split (/\-/, $1);     #separate options
        
        foreach my $option ( @process ) {
            if ($name eq "N/A" and $option =~ m/^([fh]d[a-d]|cdrom) (\S+)/) {
                $name = $2;
            } elsif ($option =~ m/^name (\S+)/) {
                $name = $1;
            } elsif ($option =~ m/^m (\S+)/) {
                $mem = $1;
            } elsif ($option =~ m/^uuid (\S+)/) {
                $uuid = $1;
            }
        }
        
        if ($mem == 0 ) {
            # Default value
            $mem = 128;
        }
        
        $inventory->addVirtualMachine ({
            NAME      => $name,
            UUID      => $uuid,
            VCPU      => 1,
            MEMORY    => $mem,
            STATUS    => "running",
            SUBSYSTEM => $vmtype,
            VMTYPE    => $vmtype,
        });
    }
}

1;
