package FusionInventory::Agent::Task::Inventory::Virtualization::Qemu;
# With Qemu 0.10.X, some option will be added to get more and easly information (UUID, memory, ...)

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return 
        can_run('qemu') ||
        can_run('kvm')  ||
        can_run('qemu-kvm');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $process (getProcessesFromPs(
        logger => $logger, command => 'ps -ef'
    )) {
        # match only if an qemu instance
        next unless $process->{CMD} =~ /(qemu|kvm|(qemu-kvm)).*\-([fh]d[a-d]|cdrom).*/;
            
        my $name;
        my $mem = 0;
        my $uuid;
        my $vmtype = $1;
                    
        my @options = split (/\-/, $process->{CMD});
        foreach my $option (@options) {
            if ($option =~ m/^([fh]d[a-d]|cdrom) (\S+)/) {
                $name = $2 if !$name;
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
