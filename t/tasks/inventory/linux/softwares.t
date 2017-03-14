#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);

$ENV{TZ} = 'CET';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::Generic::Softwares::RPM;
use FusionInventory::Agent::Task::Inventory::Generic::Softwares::Deb;
use FusionInventory::Agent::Task::Inventory::Generic::Softwares::Gentoo;

my $rpm_packages = [
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'libpciaccess0',
        COMMENTS    => 'Generic PCI access library (from X.org)',
        INSTALLDATE => '19/07/2011',
        FILESIZE    => '38452',
        FROM        => 'rpm',
        ARCH        => 'i586',
        VERSION     => '0.12.1-1.mga1',
        SYSTEM_CATEGORY => 'System Environment/Libraries'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'firebird-devel',
        COMMENTS    => 'Development Libraries for Firebird SQL Database',
        INSTALLDATE => '09/01/2012',
        FILESIZE    => '351554',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '2.5.1.26351.0-3.mga2',
        SYSTEM_CATEGORY => 'Documentation'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'gjs',
        COMMENTS    => 'JavaScript bindings based on gobject-introspection',
        INSTALLDATE => '27/03/2012',
        FILESIZE    => '176167',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '1.32.0-1.mga2',
        SYSTEM_CATEGORY => 'Unspecified'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'lib64nss3',
        COMMENTS    => 'Network Security Services (NSS)',
        INSTALLDATE => '18/04/2012',
        FILESIZE    => '3346040',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '3.13.4-1.mga2',
        SYSTEM_CATEGORY => 'Unspecified'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'ruby-term-ansicolor',
        COMMENTS    => 'Ruby library that colors strings using ANSI escape sequences',
        INSTALLDATE => '29/07/2011',
        FILESIZE    => '7211',
        FROM        => 'rpm',
        ARCH        => 'noarch',
        VERSION     => '1.0.5-3.mga1',
        SYSTEM_CATEGORY => 'Libraries'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'lib64tidy-devel',
        COMMENTS    => 'Headers for developing programs that will use tidy',
        INSTALLDATE => '02/01/2012',
        FILESIZE    => '1930155',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '20090904-3.mga1',
        SYSTEM_CATEGORY => 'Unspecified'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'xfsprogs',
        COMMENTS    => 'Utilities for managing the XFS filesystem',
        INSTALLDATE => '25/03/2012',
        FILESIZE    => '3628382',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '3.1.8-1.mga2',
        SYSTEM_CATEGORY => 'System Environment/Base'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'lib64swresample0',
        COMMENTS    => 'Shared library part of ffmpeg',
        INSTALLDATE => '12/04/2012',
        FILESIZE    => '35016',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '0.10.2-2.mga2.tainted',
        SYSTEM_CATEGORY => 'Unspecified'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'lib64pyglib2.0_0',
        COMMENTS    => 'Python Glib bindings shared library',
        INSTALLDATE => '23/02/2012',
        FILESIZE    => '18672',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '2.28.6-6.mga2',
        SYSTEM_CATEGORY => 'Unspecified'
    },
    {
        PUBLISHER   => 'Mageia',
        NAME        => 'perl-Gtk2-ImageView',
        COMMENTS    => 'Perl bindings to the GtkImageView image viewer widget',
        INSTALLDATE => '03/04/2012',
        FILESIZE    => '153539',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '0.50.0-4.mga2',
        SYSTEM_CATEGORY => 'Development/Libraries'
    }
];
my $deb_packages = [
    {
        FROM     => 'deb',
        NAME     => 'adduser',
        ARCH     => 'all',
        VERSION  => '3.112+nmu2',
        FILESIZE => '1228',
        SYSTEM_CATEGORY => 'admin'
    },
    {
        FROM     => 'deb',
        NAME     => 'anthy-common',
        ARCH     => 'all',
        VERSION  => '9100h-6',
        FILESIZE => '13068',
        SYSTEM_CATEGORY => 'unknown'
    },
    {
        FROM     => 'deb',
        NAME     => 'apache2',
        ARCH     => 'amd64',
        VERSION  => '2.2.16-6+squeeze6',
        FILESIZE => '36',
        SYSTEM_CATEGORY => 'httpd'
    },
    {
        FROM     => 'deb',
        NAME     => 'apache2-mpm-prefork',
        ARCH     => 'amd64',
        VERSION  => '2.2.16-6+squeeze6',
        FILESIZE => '68',
        SYSTEM_CATEGORY => 'httpd'
    },
    {
        FROM     => 'deb',
        NAME     => 'apache2-utils',
        ARCH     => 'amd64',
        VERSION  => '2.2.16-6+squeeze6',
        FILESIZE => '384',
        SYSTEM_CATEGORY => 'httpd'
    },
    {
        FROM     => 'deb',
        NAME     => 'apache2.2-bin',
        ARCH     => 'amd64',
        VERSION  => '2.2.16-6+squeeze6',
        FILESIZE => '3856',
        SYSTEM_CATEGORY => 'httpd'
    },
    {
        FROM     => 'deb',
        NAME     => 'apache2.2-common',
        ARCH     => 'amd64',
        VERSION  => '2.2.16-6+squeeze6',
        FILESIZE => '2144',
        SYSTEM_CATEGORY => 'httpd'
    },
    {
        FROM     => 'deb',
        NAME     => 'apt',
        ARCH     => 'amd64',
        VERSION  => '0.8.10.3+squeeze1',
        FILESIZE => '5644',
        SYSTEM_CATEGORY => 'admin'
    },
    {
        FROM     => 'deb',
        NAME     => 'apt-utils',
        ARCH     => 'amd64',
        VERSION  => '0.8.10.3+squeeze1',
        FILESIZE => '540',
        SYSTEM_CATEGORY => 'admin'
    },
    {
        FROM     => 'deb',
        NAME     => 'apt-xapian-index',
        ARCH     => 'all',
        VERSION  => '0.41',
        FILESIZE => '376',
        SYSTEM_CATEGORY => 'admin'
    },
    {
        FROM     => 'deb',
        NAME     => 'aptitude',
        ARCH     => 'amd64',
        VERSION  => '0.6.3-3.2+squeeze1',
        FILESIZE => '11916',
        SYSTEM_CATEGORY => 'admin'
    },
    {
        FROM     => 'deb',
        NAME     => 'aspell',
        ARCH     => 'amd64',
        VERSION  => '0.60.6-4',
        FILESIZE => '1184',
        SYSTEM_CATEGORY => 'text'
    },
    {
        FROM     => 'deb',
        NAME     => 'aspell-en',
        ARCH     => 'all',
        VERSION  => '6.0-0-6',
        FILESIZE => '548',
        SYSTEM_CATEGORY => 'text'
    },
    {
        FROM     => 'deb',
        NAME     => 'aspell-fr',
        ARCH     => 'all',
        VERSION  => '0.50-3-7',
        FILESIZE => '636',
        SYSTEM_CATEGORY => 'text'
    },
    {
        FROM     => 'deb',
        NAME     => 'at',
        ARCH     => 'amd64',
        VERSION  => '3.1.12-1',
        FILESIZE => '220',
        SYSTEM_CATEGORY => 'admin'
    }
];

plan tests => 7;

my $inventory = FusionInventory::Test::Inventory->new();

my $packages;
$packages = FusionInventory::Agent::Task::Inventory::Generic::Softwares::RPM::_getPackagesList(
    file => "resources/linux/packaging/rpm"
);
SKIP: {
    skip ('test can fail because of timezone setting on Win32', 1)
        if ($OSNAME eq 'MSWin32');
    cmp_deeply($packages, $rpm_packages, 'rpm: parsing');
}
lives_ok {
    $inventory->addEntry(section => 'SOFTWARES', entry => $_)
        foreach @$packages;
} 'rpm: registering';

$packages = FusionInventory::Agent::Task::Inventory::Generic::Softwares::Deb::_getPackagesList(
    file => "resources/linux/packaging/dpkg"
);
cmp_deeply($packages, $deb_packages, 'dpkg: parsing');
lives_ok {
    $inventory->addEntry(section => 'SOFTWARES', entry => $_)
        foreach @$packages;
} 'dpkg: registering';

ok(
    !FusionInventory::Agent::Task::Inventory::Generic::Softwares::Gentoo::_equeryNeedsWildcard(
        file => "resources/linux/equery/gentoo1"
    ),
    "old equery version"
);

ok(
    FusionInventory::Agent::Task::Inventory::Generic::Softwares::Gentoo::_equeryNeedsWildcard(
        file => "resources/linux/equery/gentoo2"
    ),
    "new equery version"
);
