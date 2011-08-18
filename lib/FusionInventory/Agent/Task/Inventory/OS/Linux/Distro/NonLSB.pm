package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB;

use strict;
use warnings;

use English qw(-no_match_vars);

# This hash contains the following fields:
#     File to read             => Full version string
my @files = (
    [ '/etc/vmware-release'    => '%s' ],
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
    [ '/etc/issue'             => '%s' ],
);

# Note: the following hash, as well as the setDistroData method below, were
# added after the files hash above, and the getRelease function below.
# As a result, there is a lot of duplication between the two. This is
# deliberate, to avoid messing with existing code that works on a stable branch.
# In the 2.2.x branch, or later, the first pair should be removed.
# See: http://forge.fusioninventory.org/issues/1066

# This hash contains the following fields:
#     File to read             => Distro name => Regex to get distro version => Full version
my @filesDistros = (
    # vmware-release contains something like "VMware ESX Server 3" or "VMware ESX 4.0 (Kandinsky)"
    [ '/etc/vmware-release'    => 'VMWare'    => '.* ([0-9\.]+).*'          => '%s' ],

    [ '/etc/arch-release'      => 'ArchLinux' => '(.*)'                     => 'ArchLinux %s' ],

    [ '/etc/debian_version'    => 'Debian'    => '(.*)'                     => 'Debian GNU/Linux %s'],

    # fedora-release contains something like "Fedora release 9 (Sulphur)"
    [ '/etc/fedora-release'    => 'Fedora'    => '.* release ([0-9\.]+).*'  => '%s' ],

    [ '/etc/gentoo-release'    => 'Gentoo'    => '(.*)'                     => 'Gentoo Linux %s' ],

    # knoppix_version contains something like "3.2 2003-04-15".
    # Note: several 3.2 releases can be made, with different dates, so we need to keep the date suffix
    [ '/etc/knoppix_version'   => 'Knoppix'   => '(.*)'                     => 'Knoppix GNU/Linux %s' ],

    # mandriva-release contains something like "Mandriva Linux release 2010.1 (Official) for x86_64"
    [ '/etc/mandriva-release'  => 'Mandriva'  => '.* release ([0-9\.]+).*'  => '%s'],

    # mandrake-release contains something like "Mandrakelinux release 10.1 (Community) for i586"
    [ '/etc/mandrake-release'  => 'Mandrake'  => '.* release ([0-9\.]+).*'  => '%s'],

    # redhat-release contains something like "Red Hat Enterprise Linux Server release 5 (Tikanga)"
    [ '/etc/redhat-release'    => 'RedHat'    => '.* release ([0-9\.]+).*'  => '%s' ],

    [ '/etc/slackware-version' => 'Slackware' => 'Slackware (.*)'           => '%s' ],

    # SuSE-release contains something like "SUSE Linux Enterprise Server 11 (x86_64)"
    # Note: it may contain several extra lines
    [ '/etc/SuSE-release'      => 'SuSE'      => '.* ([0-9\.]+).*'          => '%s' ],

    # trustix-release contains something like "Trustix Secure Linux release 2.0 (Cloud)"
    [ '/etc/trustix-release'   => 'Trustix'   => '.* release ([0-9\.]+).*'  => '%s' ],

    # Fallback
    [ '/etc/issue'             => 'Unknown Linux distribution' => '.* ([0-9\.]+).*' => '%s' ],

    # Note: Ubuntu is not listed here as it does not have a
    # ubuntu-{release,version} file, but it should always have the lsb_release
    # command so it will be handled by the Linux::Distro::LSB module
);


our $runMeIfTheseChecksFailed = ["FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::LSB"];

sub isInventoryEnabled {
    return 1;
}

sub findRelease {
    my $release;

    foreach (@files) {
        my $file = $_->[0];
        my $distro = $_->[1];

        next unless -f $file;
        my $handle;
        if (!open $handle, '<', $file) {
            warn "Can't open $file: $ERRNO";
            return;
        }
        my $version = <$handle>;
        chomp $version;
        close $handle;
        $release = sprintf $distro, $version;
        last;
    }

    return $release;
}

sub setDistroData {
    my $inventory = shift;

    my $distroName;
    my $distroVersion;
	my $commercialFullName;

    foreach (@filesDistros) {
        my $file = $_->[0];
        $distroName = $_->[1];
        my $distroVersRegex = $_->[2];
        my $distroFullName  = $_->[3];

        next unless -f $file;
        my $handle;
        if (!open $handle, '<', $file) {
            warn "Can't open $file: $ERRNO";
            return;
        }
        my $version = <$handle>;
        chomp $version;
        close $handle;

        $commercialFullName = sprintf $distroFullName, $version;
        if ($version =~ /^$distroVersRegex/) {
            $distroVersion = $1;

            # Now we have found the distro name and version, let's set them
            $inventory->setOperatingSystem({
                NAME                 => "$distroName",
                VERSION              => "$distroVersion",
                FULL_NAME            => $commercialFullName
            });

            # We found what we need, no need to continue checking
            last;
        }
    }
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $OSComment = `uname -v`;
    chomp $OSComment;

    my $OSFullName = findRelease();

    $inventory->setHardware({ 
        OSNAME     => $OSFullName,
        OSCOMMENTS => $OSComment
    });

    setDistroData($inventory);

}

1;
