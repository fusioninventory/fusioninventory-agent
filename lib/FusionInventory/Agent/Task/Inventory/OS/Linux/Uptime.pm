package FusionInventory::Agent::Task::Inventory::OS::Linux::Uptime;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled { can_read("/proc/uptime") }

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

    # Uptime conversion
    my ($uyear, $umonth , $uday, $uhour, $umin, $usec) =
        (gmtime ($uptime))[5,4,3,2,1,0];

    # Write in ISO format
    $uptime = getFormatedDate(
        ($uyear-70), $umonth, ($uday-1), $uhour, $umin, $usec
    );

    chomp(my $DeviceType =`uname -m`);
#  TODO$h->{'CONTENT'}{'HARDWARE'}{'DESCRIPTION'} = [ "$DeviceType/$uptime" ];
    $inventory->setHardware({ DESCRIPTION => "$DeviceType/$uptime" });
}

1;
