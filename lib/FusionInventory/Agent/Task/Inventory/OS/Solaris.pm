package FusionInventory::Agent::Task::Inventory::OS::Solaris;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

our $runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];

sub isInventoryEnabled {
    return $OSNAME eq 'solaris';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # Operating system informations
    my $OSName = getSingleLine(command => 'uname -s');
    my $OSLevel = getSingleLine(command => 'uname -r');
    my $OSComment = getSingleLine(command => 'uname -v');

    my $OSVersion = getSingleLine(file => '/etc/release', logger => $logger);
    $OSVersion =~ s/^\s+//;

    if (!$OSVersion) {
        $OSVersion = $OSComment;
    }

    # Hardware informations
    my $karch = getSingleLine(command => 'arch -k');
    my $hostid = getSingleLine(command => 'hostid');
    my $proct = getSingleLine(command => 'uname -p');
    my $platform = getSingleLine(command => 'uname -i');
    my $HWDescription = "$platform($karch)/$proct HostID=$hostid";

    $inventory->setHardware(
        OSNAME      => "$OSName $OSLevel",
        OSCOMMENTS  => $OSComment,
        OSVERSION   => $OSVersion,
        DESCRIPTION => $HWDescription
    );
}

1;
