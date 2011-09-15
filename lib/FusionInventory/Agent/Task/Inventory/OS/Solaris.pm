package FusionInventory::Agent::Task::Inventory::OS::Solaris;

use strict;
use warnings;

use English qw(-no_match_vars);

our $runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];

sub isInventoryEnabled {
    return $OSNAME =~ /^solaris$/;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $OSName;
    my $OSComment;
    my $OSVersion;
    my $OSLevel;
    my $HWDescription;
    my ( $karch, $hostid, $proct, $platform);

    #Operating system informations
    chomp($OSName=`uname -s`);
    chomp($OSLevel=`uname -r`);
    chomp($OSComment=`uname -v`);

    if (open my $handle, '<', '/etc/release') {
        $OSVersion = <$handle>;
        close $handle;
        chomp $OSVersion;
        $OSVersion =~ s/^\s+//;
    } else {
        warn "Can't open /etc/release: $ERRNO";
    }

    chomp($OSVersion=`uname -v`) unless $OSVersion;
    chomp($OSVersion);
    $OSVersion=~s/^\s*//;
    $OSVersion=~s/\s*$//;

    # Hardware informations
    chomp($karch=`arch -k`);
    chomp($hostid=`hostid`);
    chomp($proct=`uname -p`);
    chomp($platform=`uname -i`);
    $HWDescription = "$platform($karch)/$proct HostID=$hostid";

    $inventory->setHardware({
        OSNAME => "$OSName $OSLevel",
        OSCOMMENTS => $OSComment,
        OSVERSION => $OSVersion,
        DESCRIPTION => $HWDescription
    });

    $inventory->setOperatingSystem({
        NAME                 => "Solaris",
        VERSION              => $OSLevel,
        KERNEL_VERSION       => $OSComment,
        FULL_NAME            => "$OSName $OSLevel"
    });
}


1;
