package FusionInventory::Agent::Task::Inventory::OS::Solaris;

use strict;
use warnings;

use English qw(-no_match_vars);

our $runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];

sub isInventoryEnabled {
    return $OSNAME eq 'solaris';
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    # Operating system informations
    my $OSName = `uname -s`;
    chomp $OSName;
    my $OSLevel = `uname -r`;
    chomp $OSLevel;
    my $OSComment = `uname -v`;
    chomp $OSComment;

    my $OSVersion;
    if (open my $handle, '<', '/etc/release') {
        $OSVersion = <$handle>;
        close $handle;
        chomp $OSVersion;
        $OSVersion =~ s/^\s+//;
    } else {
        $logger->error("Can't open /etc/release: $ERRNO");
    }

    if (!$OSVersion) {
        $OSVersion = $OSComment;
    }

    # Hardware informations
    my $karch = `arch -k`;
    chomp $karch;
    my $hostid = `hostid`;
    chomp $hostid;
    my $proct = `uname -p`;
    chomp $proct;
    my $platform = `uname -i`;
    chomp $platform;
    my $HWDescription = "$platform($karch)/$proct HostID=$hostid";

    $inventory->setHardware({
        OSNAME => "$OSName $OSLevel",
        OSCOMMENTS => $OSComment,
        OSVERSION => $OSVersion,
        DESCRIPTION => $HWDescription
    });
}

1;
