package FusionInventory::Agent::Task::Inventory::OS::MacOS;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return $OSNAME eq 'darwin';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my ($OSName, $OSVersion);

    # if we can load the system profiler, gather the information from that
    if (can_load("Mac::SysProfile")) {
        my $profile = Mac::SysProfile->new();
        my $h = $profile->gettype('SPSoftwareDataType');
        return(undef) unless(ref($h) eq 'HASH');

        $h = $h->{'System Software Overview'};

        my $SystemVersion = $h->{'System Version'};
        if ($SystemVersion =~ /^(.*?)\s+(\d+.*)/) {
            $OSName=$1;
            $OSVersion=$2;
        } else {
            # Default values
            $OSName="Mac OS X";
            $OSVersion="Unknown";
        }

    } else {
        # we can't load the system profiler, use the basic BSD stype information
        # Operating system informations
        $OSName = getFirstLine(command => 'uname -s');
        $OSVersion = getFirstLine(command => 'uname -r');
    }

    # add the uname -v as the comment, not really needed, but extra info
    # never hurt
    my $OSComment = getFirstLine(command => 'uname -v');
    $inventory->setHardware({
        OSNAME     => $OSName,
        OSCOMMENTS => $OSComment,
        OSVERSION  => $OSVersion,
    });
}

1;
