package FusionInventory::Agent::Task::Inventory::OS::MacOS::Uptime;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    my $boottime = `sysctl -n kern.boottime 2>/dev/null`; # straight from the BSD module ;-)
    return 1 if $boottime;
    return;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    # stolen code from bsd.
    chomp (my $boottime = `sysctl -n kern.boottime`);
    $boottime = $1 if $boottime =~ /sec\s*=\s*(\d+)/;
    my $currenttime = time();
    my $uptime = $currenttime - $boottime;

    # Uptime conversion
    my ($uyear, $umonth , $uday, $uhour, $umin, $usec) =
        (gmtime ($uptime))[5,4,3,2,1,0];

    # Write in ISO format
    $uptime = getFormatedDate(
        ($uyear - 70), $umonth, ($uday - 1), $uhour, $umin, $usec
    );

    chomp(my $DeviceType =`uname -m`);
    $inventory->setHardware({ DESCRIPTION => "$DeviceType/$uptime" });
}

1;
