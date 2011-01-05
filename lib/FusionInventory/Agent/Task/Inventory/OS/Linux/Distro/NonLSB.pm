package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

my @files = (
    [ '/etc/arch-release'      => 'ArchLinux %s' ],
    [ '/etc/debian_version'    => 'Debian GNU/Linux %s' ],
    [ '/etc/fedora-release'    => '%s' ],
    [ '/etc/gentoo-release'    => 'Gentoo Linux %s'],
    [ '/etc/knoppix_version'   => 'Knoppix GNU/Linux %s' ],
    [ '/etc/mandriva-release'  => '%s' ],
    [ '/etc/mandrake-release'  => '%s' ],
    [ '/etc/redhat-release'    => '%s' ],
    [ '/etc/slackware-version' => '%s' ],
    [ '/etc/SuSE-release'      => '%s' ],
    [ '/etc/trustix-release'   => '%s' ],
    [ '/etc/ubuntu_version'    => 'Ubuntu %s' ],
    [ '/etc/vmware-release'    => '%s' ],
    [ '/etc/issue'             => '%s' ],
);

our $runMeIfTheseChecksFailed = ["FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::LSB"];

sub isInventoryEnabled {
    return 1;
}

sub _findRelease {
    my $release;

    foreach (@files) {
        my $file = $_->[0];
        my $distro = $_->[1];

        next unless can_read($file);
        my $version = getFirstLine(file => $file);
        $release = sprintf $distro, $version;
        last;
    }

    return $release;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $OSComment = getFirstLine(command => 'uname -v');

    $inventory->setHardware(
        OSNAME     => _findRelease(),
        OSCOMMENTS => $OSComment
    );
}

1;
