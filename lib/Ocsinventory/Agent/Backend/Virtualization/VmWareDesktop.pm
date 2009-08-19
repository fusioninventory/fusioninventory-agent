package Ocsinventory::Agent::Backend::Virtualization::VmWareDesktop;
#
# initial version: Walid Nouh
#

use strict;

sub check { return can_run('/Library/Application\ Support/VMware\ Fusion/vmrun') }

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};
	
    my $uuid;
    my $mem;
    my $status;
    my $name;
    my $index = 0;

    my $commande = "/Library/Application\\ Support/VMware\\ Fusion\/vmrun list";
    foreach my $vmxpath ( `$commande` ) {
            if ($index>0) {
                    $vmxpath =~ s/ /\\\ /g;
                    my @vminfos = `cat $vmxpath`;
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
                        SUBSYSTEM => "VmWare Fusion",
                        VMTYPE    => "VmWare",
                    });
            }
            $index++;
    }
}

1;
