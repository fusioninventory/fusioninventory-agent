package FusionInventory::Agent::Task::Inventory::OS::Linux::Uptime;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return -r '/proc/uptime';
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    # Uptime
    my $handle;
    if (!open $handle, '<', '/proc/uptime') {
        warn "Can't open /proc/uptime: $ERRNO";
        return;
    }

    my $uptime = <$handle>;
    $uptime =~ s/^(.+)\s+.+/$1/;
    close $handle;

    # ISO format string conversion
    $uptime = getFormatedGmTime($uptime);

    chomp(my $DeviceType =`uname -m`);
#  TODO$h->{'CONTENT'}{'HARDWARE'}{'DESCRIPTION'} = [ "$DeviceType/$uptime" ];
    $inventory->setHardware({ DESCRIPTION => "$DeviceType/$uptime" });
}

1;
