package FusionInventory::Agent::Task::Inventory::Solaris;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

our $runAfter = ["FusionInventory::Agent::Task::Inventory::Generic"];

sub isEnabled {
    return $OSNAME eq 'solaris';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # Operating system informations
    my $info           = getReleaseInfo();
    my $kernel_arch    = getFirstLine(command => 'arch -k');
    my $kernel_version = getFirstLine(command => 'uname -v');
    my $proct          = getFirstLine(command => 'uname -p');
    my $platform       = getFirstLine(command => 'uname -i');
    my $hostid         = getFirstLine(command => 'hostid');
    my $description    = "$platform($kernel_arch)/$proct HostID=$hostid";

    $inventory->setHardware({
        OSNAME      => "Solaris",
        OSVERSION   => $info->{version},
        OSCOMMENTS  => $info->{subversion},
        DESCRIPTION => $description
    });

    $inventory->setOperatingSystem({
        NAME           => "Solaris",
        FULL_NAME      => $info->{fullname},
        VERSION        => $info->{version},
        SERVICE_PACK   => $info->{subversion},
        KERNEL_VERSION => $kernel_version
    });
}

1;
