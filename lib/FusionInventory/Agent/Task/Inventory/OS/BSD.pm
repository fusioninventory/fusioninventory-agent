package FusionInventory::Agent::Task::Inventory::OS::BSD;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

our $runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];

sub isInventoryEnabled {
    return $OSNAME =~ /freebsd|openbsd|netbsd|gnukfreebsd|gnuknetbsd|dragonfly/;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    # Basic operating system informations
    my $OSVersion = getFirstLine(command => 'uname -r');
    my $OSArchi = getFirstLine(command => 'uname -p');
    my $OSComment = getFirstLine(command => 'uname -v');

    # Get more information from the kernel configuration file
    my $date;
    foreach my $line (`sysctl -n kern.version`) {
        if ($line =~ /^\S.*\#\d+:\s*(.*)/) {
            $date = $1;
            next;
        }

        if ($line =~ /^\s+(.+):(.+)$/) {
            my $origin = $1;
            my $kernconf = $2;
            $kernconf =~ s/\/.*\///; # remove the path
            $OSComment = $kernconf . " (" . $date . ")\n" . $origin;
        }
    }

    if (can_run('lsb_release')) {
        foreach (`lsb_release -d`) {
            $OSNAME = $1 if /Description:\s+(.+)/;
        }
    }

    $inventory->setHardware({
        OSNAME     => $OSNAME,
        OSCOMMENTS => $OSComment,
        OSVERSION  => $OSVersion,
    });
}

1;
