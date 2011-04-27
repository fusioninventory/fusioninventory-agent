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

    my $OSName = $OSNAME;
    if (can_run('lsb_release')) {
        $OSName = getFirstMatch(
            command => 'lsb_release -d',
            pattern => /Description:\s+(.+)/
        );
    }

    $inventory->setHardware({
        OSNAME     => $OSName,
        OSVERSION  => $OSVersion,
        OSCOMMENTS => $OSComment,
    });
}

1;
