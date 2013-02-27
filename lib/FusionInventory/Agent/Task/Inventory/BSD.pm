package FusionInventory::Agent::Task::Inventory::BSD;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

our $runAfter = ["FusionInventory::Agent::Task::Inventory::Generic"];

sub isEnabled {
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
    my $handle = getFileHandle(command => "sysctl -n kern.version");
    while (my $line = <$handle>) {
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
    close $handle;

    my $boottime = getFirstMatch(command => "sysctl -n kern.boottime", pattern => qr/sec = (\d+)/);

    my $OSName = $OSNAME;
    if (canRun('lsb_release')) {
        $OSName = getFirstMatch(
            command => 'lsb_release -d',
            pattern => qr/Description:\s+(.+)/
        );
    }

    $inventory->setHardware({
        OSNAME     => $OSName,
        OSVERSION  => $OSVersion,
        OSCOMMENTS => $OSComment,
    });

    $inventory->setOperatingSystem({
        NAME                 => $OSName,
        VERSION              => $OSVersion,
        KERNEL_VERSION       => $OSVersion,
        FULL_NAME            => $OSNAME,
        BOOT_TIME            => getFormatedLocalTime($boottime)
    });
}

1;
