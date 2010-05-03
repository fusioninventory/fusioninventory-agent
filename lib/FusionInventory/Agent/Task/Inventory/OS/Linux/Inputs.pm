package FusionInventory::Agent::Task::Inventory::OS::Linux::Inputs;
# Had never been tested.
#use FusionInventory::Agent::Task::Inventory::OS::Linux;
use strict;

sub isInventoryEnabled { can_run("cat") }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};
    my @inputs;
    my $device;
    my $in;
    foreach (`cat /proc/bus/input/devices`)
    {
        if (/^I: Bus=.*Vendor=(.*) Prod/) {
            $in = 1;
            $device->{vendor}=$1;
        } elsif (/^$/) {
            $in =0;
            if ( $device->{phys} =~ "input" )
            {
                $logger->debug("ca match ! phys=$device->{phys}");
                push @inputs, {
                    DESCRIPTION => $device->{name},
                    CAPTION => $device->{name},
                    TYPE=> $device->{type},
                };
            }
    
            $device = {};
        } elsif ($in) {
            if (/^P: Phys=.*(button).*/i) {
                $logger->debug("dans le phys nodev $1");
                $device->{phys}="nodev";
            }
            elsif (/^P: Phys=.*(input).*/i) {
                $logger->debug("dans le phys input $1");
                $device->{phys}="input";
            }
            if (/^N: Name=\"(.*)\"/i) {
                $logger->debug("dans le name $1");
                $device->{name}=$1;
            }
            if (/^H: Handlers=(\w+)/i) {
                $logger->debug("dans le type $1");
                # Keyboard ou Pointing
                $device->{type}=$1;
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
