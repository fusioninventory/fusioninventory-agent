package FusionInventory::Agent::Task::Inventory::Virtualization::VmWareDesktop;
#
# initial version: Walid Nouh
#

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    return (can_run('/Library/Application\ Support/VMware\ Fusion/vmrun') || can_run('vmrun'));
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my $uuid;
    my $mem;
    my $status;
    my $name;
    my $i = 0;

    my $commande;
    my $subsystem;
    if (can_run('vmrun')) {
        $commande = "vmrun list";
        $subsystem = "VMware Desktop";
    } else {
        $commande = "/Library/Application\\ Support/VMware\\ Fusion\/vmrun list";
        $subsystem = "VMware Fusion";
    }
    foreach my $vmxpath ( `$commande` ) {
        chomp($vmxpath);
        next unless $i++ > 0; # Ignore the first line
        my $handle;
        if (!open $handle, '<', $vmxpath) {
            warn "Can't open $vmxpath: $ERRNO";
            $logger->debug("Can't open $vmxpath\n");
            next;
        }
        my @vminfos = <$handle>;
        close $handle;

        foreach my $line (@vminfos) {
            if ($line =~ m/^displayName =\s\"+(.*)\"/) {
                $name = $1;
            }
            elsif ($line =~ m/^memsize =\s\"+(.*)\"/) {
                $mem = $1;
            }
            elsif ($line =~ m/^uuid.bios =\s\"+(.*)\"/) {
                $uuid = $1;
            }
        }

        $inventory->addVirtualMachine ({
                NAME      => $name,
                VCPU      => 1,
                UUID      => $uuid,
                MEMORY    => $mem,
                STATUS    => "running",
                SUBSYSTEM => $subsystem,
                VMTYPE    => "VMware",
            });
    }
}

1;
