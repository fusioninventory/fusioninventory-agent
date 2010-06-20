package FusionInventory::Agent::Task::Inventory::OS::BSD;

use strict;
use warnings;

use English qw(-no_match_vars);

our $runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];

sub isInventoryEnabled {
    return $OSNAME =~ /freebsd|openbsd|netbsd|gnukfreebsd|gnuknetbsd/;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $OSComment;
    my $OSVersion;
    my $OSLevel;
    my $OSArchi;

    # Operating system informations
    chomp($OSVersion=`uname -r`);
    chomp($OSArchi=`uname -p`);

    # Retrieve the origin of the kernel configuration file
    my ($date, $origin, $kernconf);
    for (`sysctl -n kern.version`) {
        $date = $1 if /^\S.*\#\d+:\s*(.*)/;
        ($origin,$kernconf) = ($1,$2) if /^\s+(.+):(.+)$/;
    }
    $kernconf =~ s/\/.*\///; # remove the path
    $OSComment = $kernconf." (".$date.")\n".$origin;
    # if there is a problem use uname -v
    chomp($OSComment=`uname -v`) unless $OSComment; 

    $inventory->setHardware({
        OSNAME => $OSNAME,
        OSCOMMENTS => $OSComment,
        OSVERSION => $OSVersion,
    });
}
1;
