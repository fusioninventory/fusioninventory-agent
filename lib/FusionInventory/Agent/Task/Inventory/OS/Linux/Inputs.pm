package FusionInventory::Agent::Task::Inventory::OS::Linux::Inputs;
# Had never been tested.
#use FusionInventory::Agent::Task::Inventory::OS::Linux;
use strict;
use warnings;

sub isInventoryEnabled { can_run("cat") }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};
    my @inputs;
    my $device;
    my $in;
    while (`cat /proc/bus/input/devices`) {
        if (/^I: Bus=.*Vendor=(.*) Prod/) {
            $in = 1;
            $device->{vendor}=$1;
        } elsif (/^$/) {
            $in = 0;
            if ($device->{phys} =~ "input") {
                push @inputs, {
                    DESCRIPTION => $device->{name},
                    CAPTION => $device->{name},
                    TYPE=> $device->{type},
                };
            }
    
            $device = {};
        } elsif ($in) {
            if (/^P: Phys=.*(button).*/i) {
                $device->{phys}="nodev";
            } elsif (/^P: Phys=.*(input).*/i) {
                $device->{phys}="input";
            }
            if (/^N: Name=\"(.*)\"/i) {
                $device->{name}=$1;
            }
            if (/^H: Handlers=(\w+)/i) {
		if ( $1 =~ ".*kbd.*") {
                    $device->{type}="Keyboard";
                } elsif ( $1 =~ ".*mouse.*") {
                    $device->{type}="Pointing";
                } else {
                    # Keyboard ou Pointing
                    $device->{type}=$1;
                }
            }
        }
    }
#    push @inputs, {
#        DESCRIPTION => $device->{name},
#        TYPE=> $device->{type},
#    };
    foreach (@inputs) {
        $inventory->addInput($_);
    }
 
}


1;
