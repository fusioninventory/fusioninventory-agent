package FusionInventory::Agent::Task::Inventory::OS::MacOS::Uptime;

use strict;
use warnings;

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
    chomp (my $currenttime = `date +%s`);
    my $uptime = $currenttime - $boottime;

    # Uptime conversion
    my ($UYEAR, $UMONTH , $UDAY, $UHOUR, $UMIN, $USEC) = (gmtime ($uptime))[5,4,3,2,1,0];

    # Write in ISO format
    $uptime=sprintf "%02d-%02d-%02d %02d:%02d:%02d", ($UYEAR-70), $UMONTH, ($UDAY-1), $UHOUR, $UMIN, $USEC;

    chomp(my $DeviceType =`uname -m`);
    $inventory->setHardware({ DESCRIPTION => "$DeviceType/$uptime" });
}
1;
