package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB;

use strict;
use warnings;

use English qw(-no_match_vars);

my %files = (
    '/etc/arch-release'      => 'ArchLinux %s',
    '/etc/debian_version'    => 'Debian GNU/Linux %s',
    '/etc/fedora-release'    => '%s',
    '/etc/gentoo-release'    => 'Gentoo Linux %s',
    '/etc/knoppix_version'   => 'Knoppix GNU/Linux $s',
    '/etc/mandriva-release'  => '%s',
    '/etc/mandrake-release'  => '%s',
    '/etc/redhat-release'    => '%s',
    '/etc/slackware-version' => '%s',
    '/etc/SuSE-release'      => '%s',
    '/etc/trustix-release'   => '%s',
    '/etc/ubuntu_version'    => 'Ubuntu %s',
    '/etc/vmware-release'    => '%s',
    '/etc/issue'             => '%s',
);

our $runMeIfTheseChecksFailed = ["FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::LSB"];

sub isInventoryEnabled {
    return 1;
}

sub findRelease {
    my $release;

    foreach my $file (keys %files) {
        next unless -f $file;
        my $handle;
        if (!open $handle, '<', $file) {
            warn "Can't open $file: $ERRNO";
            return;
        }
        my $version = <$handle>;
        chomp $version;
        close $handle;
        $release = sprintf $files{$file}, $version;
        last;
    }

    return $release;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $OSComment = `uname -v`;
    chomp $OSComment;

    $inventory->setHardware({ 
        OSNAME     => findRelease(),
        OSCOMMENTS => $OSComment
    });
}

1;
