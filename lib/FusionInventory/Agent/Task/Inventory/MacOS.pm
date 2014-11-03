package FusionInventory::Agent::Task::Inventory::MacOS;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    return $OSNAME eq 'darwin';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $infos = getSystemProfilerInfos(logger => $logger);
    my $SystemVersion =
        $infos->{'Software'}->{'System Software Overview'}->{'System Version'};

    my ($OSName, $OSVersion);
    if ($SystemVersion =~ /^(.*?)\s+(\d+.*)/) {
        $OSName = $1;
        $OSVersion = $2;
    } else {
        # Default values
        $OSName = "Mac OS X";
    }

    # add the uname -v as the comment, not really needed, but extra info
    # never hurt
    my $OSComment     = getFirstLine(command => 'uname -v');
    my $KernelVersion = getFirstLine(command => 'uname -r');
    my $boottime      = getFirstMatch(
        command => "sysctl -n kern.boottime",
        pattern => qr/sec = (\d+)/
    );

    $inventory->setHardware({
        OSNAME     => $OSName,
        OSVERSION  => $OSVersion,
        OSCOMMENTS => $OSComment,
    });

    $inventory->setOperatingSystem({
        NAME           => "MacOSX",
        FULL_NAME      => $OSName,
        VERSION        => $OSVersion,
        KERNEL_VERSION => $KernelVersion,
        BOOT_TIME      => getFormatedLocalTime($boottime)
    });
}

1;
