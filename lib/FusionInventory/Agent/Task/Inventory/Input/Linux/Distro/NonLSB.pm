package FusionInventory::Agent::Task::Inventory::Input::Linux::Distro::NonLSB;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

# This array contains four items for each distribution:
# - release file
# - distribution name,
# - regex to get the version
# - template to get the full name
my @distributions = (
    # vmware-release contains something like "VMware ESX Server 3" or "VMware ESX 4.0 (Kandinsky)"
    [ '/etc/vmware-release',    'VMWare',                     '([\d.]+)',         '%s' ],

    [ '/etc/arch-release',      'ArchLinux',                  '(.*)',             'ArchLinux %s' ],

    [ '/etc/debian_version',    'Debian',                     '(.*)',             'Debian GNU/Linux %s'],

    # fedora-release contains something like "Fedora release 9 (Sulphur)"
    [ '/etc/fedora-release',    'Fedora',                     'release ([\d.]+)', '%s' ],

    [ '/etc/gentoo-release',    'Gentoo',                     '(.*)',             'Gentoo Linux %s' ],

    # knoppix_version contains something like "3.2 2003-04-15".
    # Note: several 3.2 releases can be made, with different dates, so we need to keep the date suffix
    [ '/etc/knoppix_version',   'Knoppix',                    '(.*)',             'Knoppix GNU/Linux %s' ],

    # mandriva-release contains something like "Mandriva Linux release 2010.1 (Official) for x86_64"
    [ '/etc/mandriva-release',  'Mandriva',                   'release ([\d.]+)', '%s'],

    # mandrake-release contains something like "Mandrakelinux release 10.1 (Community) for i586"
    [ '/etc/mandrake-release',  'Mandrake',                   'release ([\d.]+)', '%s'],

    # redhat-release contains something like "Red Hat Enterprise Linux Server release 5 (Tikanga)"
    [ '/etc/redhat-release',    'RedHat',                     'release ([\d.]+)', '%s' ],

    [ '/etc/slackware-version', 'Slackware',                  'Slackware (.*)',   '%s' ],

    # SuSE-release contains something like "SUSE Linux Enterprise Server 11 (x86_64)"
    # Note: it may contain several extra lines
    [ '/etc/SuSE-release',      'SuSE',                       '([\d.]+)',         '%s' ],

    # trustix-release contains something like "Trustix Secure Linux release 2.0 (Cloud)"
    [ '/etc/trustix-release',   'Trustix',                    'release ([\d.]+)', '%s' ],

    # Fallback
    [ '/etc/issue',             'Unknown Linux distribution', '([\d.]+)'        , '%s' ],

    # Note: Ubuntu is not listed here as it does not have a
    # ubuntu-{release,version} file, but it should always have the lsb_release
    # command so it will be handled by the Linux::Distro::LSB module
);

our $runMeIfTheseChecksFailed =
    ["FusionInventory::Agent::Task::Inventory::Input::Linux::Distro::LSB"];

sub isEnabled {
    return !canRun("lsb_release");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $distribution = first { -f $_->[0] } @distributions;
    return unless $distribution;

    $inventory->setHardware({
        OSNAME => _findRelease($distribution),
    });

    $inventory->setOperatingSystem(_getDistroData($distribution));
}

sub _getDistroData {
    my ($distribution) = @_;

    my $name     = $distribution->[1];
    my $regexp   = $distribution->[2];
    my $template = $distribution->[3];

    my $line       = getFirstLine(file => $distribution->[0]);
    my $release    = sprintf $template, $line;
    my ($version)  = $line =~ /$regexp/;

    my $data = {
        NAME      => $name,
        VERSION   => $version,
        FULL_NAME => $release
    };

    if ($name eq 'SuSE') {
        $data->{SERVICE_PACK} = getFirstMatch(
            file    => '/etc/SuSE-release',
            pattern => qr/^PATCHLEVEL = ([0-9]+)/
        );
    }

    return $data;
}

sub _findRelease {
    my ($distribution) = @_;

    my $template = $distribution->[3];

    my $line    = getFirstLine(file => $distribution->[0]);
    my $release = sprintf $template, $line;

    return $release;
}

1;
