package FusionInventory::Agent::Task::Inventory::OS::Linux::Inputs;
# Had never been tested.
#use FusionInventory::Agent::Task::Inventory::OS::Linux;
use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};
    my @inputs;
    my $device;
    my $in;

    my $handle;
    if (!open $handle, '<', '/proc/bus/input/devices') {
         $logger->debug("Can't open /proc/bus/input/devices: $ERRNO");
         return;
    }

    while (my $line = <$handle>) {
        if ($line =~ /^I: Bus=.*Vendor=(.*) Prod/) {
            $in = 1;
            $device->{vendor}=$1;
        } elsif ($line =~ /^$/) {
            $in = 0;
            if ($device->{phys} && $device->{phys} =~ "input") {
                push @inputs, {
                    DESCRIPTION => $device->{name},
                    CAPTION => $device->{name},
                    TYPE=> $device->{type},
                };
            }
    
            $device = {};
        } elsif ($in) {
            if ($line =~ /^P: Phys=.*(button).*/i) {
                $device->{phys}="nodev";
            } elsif ($line =~ /^P: Phys=.*(input).*/i) {
                $device->{phys}="input";
            }
            if ($line =~ /^N: Name=\"(.*)\"/i) {
                $device->{name}=$1;
            }
            if ($line =~ /^H: Handlers=(\w+)/i) {
		if ($1 =~ ".*kbd.*") {
                    $device->{type}="Keyboard";
                } elsif ($1 =~ ".*mouse.*") {
                    $device->{type}="Pointing";
                } else {
                    # Keyboard ou Pointing
                    $device->{type}=$1;
                }
            }
        }
    }
    close $handle;

#    push @inputs, {
#        DESCRIPTION => $device->{name},
#        TYPE=> $device->{type},
#    };
    foreach (@inputs) {
        $inventory->addInput($_);
    }
 
}


1;
