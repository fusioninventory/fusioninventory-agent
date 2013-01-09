#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares::RPM;
use FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares::Deb;
use FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares::Gentoo;

my $rpm_packages = [
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'libpciaccess0',
        COMMENTS    => 'Generic PCI access library (from X.org)',
        INSTALLDATE => 'mar. 19 juil. 2011 15:05:03 CEST',
        FILESIZE    => '38452',
        FROM        => 'rpm',
        ARCH        => 'i586',
        VERSION     => '0.12.1-1.mga1'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'firebird-devel',
        COMMENTS    => 'Development Libraries for Firebird SQL Database',
        INSTALLDATE => 'lun. 09 janv. 2012 09:24:00 CET',
        FILESIZE    => '351554',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '2.5.1.26351.0-3.mga2'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'gjs',
        COMMENTS    => 'JavaScript bindings based on gobject-introspection',
        INSTALLDATE => 'mar. 27 mars 2012 19:08:21 CEST',
        FILESIZE    => '176167',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '1.32.0-1.mga2'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'lib64nss3',
        COMMENTS    => 'Network Security Services (NSS)',
        INSTALLDATE => 'mer. 18 avril 2012 22:21:13 CEST',
        FILESIZE    => '3346040',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '3.13.4-1.mga2'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'ruby-term-ansicolor',
        COMMENTS    => 'Ruby library that colors strings using ANSI escape sequences',
        INSTALLDATE => 'ven. 29 juil. 2011 13:12:10 CEST',
        FILESIZE    => '7211',
        FROM        => 'rpm',
        ARCH        => 'noarch',
        VERSION     => '1.0.5-3.mga1'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'lib64tidy-devel',
        COMMENTS    => 'Headers for developing programs that will use tidy',
        INSTALLDATE => 'lun. 02 janv. 2012 13:12:46 CET',
        FILESIZE    => '1930155',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '20090904-3.mga1'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'xfsprogs',
        COMMENTS    => 'Utilities for managing the XFS filesystem',
        INSTALLDATE => 'dim. 25 mars 2012 00:45:24 CET',
        FILESIZE    => '3628382',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '3.1.8-1.mga2'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'lib64swresample0',
        COMMENTS    => 'Shared library part of ffmpeg',
        INSTALLDATE => 'jeu. 12 avril 2012 10:02:14 CEST',
        FILESIZE    => '35016',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '0.10.2-2.mga2.tainted'
    },
    {
        PUBLISHER   => 'Mageia.Org',
        NAME        => 'lib64pyglib2.0_0',
        COMMENTS    => 'Python Glib bindings shared library',
        INSTALLDATE => 'jeu. 23 févr. 2012 10:25:31 CET',
        FILESIZE    => '18672',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '2.28.6-6.mga2'
    },
    {
        PUBLISHER   => 'Mageia',
        NAME        => 'perl-Gtk2-ImageView',
        COMMENTS    => 'Perl bindings to the GtkImageView image viewer widget',
        INSTALLDATE => 'mar. 03 avril 2012 16:38:46 CEST',
        FILESIZE    => '153539',
        FROM        => 'rpm',
        ARCH        => 'x86_64',
        VERSION     => '0.50.0-4.mga2'
    }
];
my $deb_packages = [
    {
        FROM     => 'deb',
        NAME     => 'adduser',
        COMMENTS => 'add and remove users and groups',
        ARCH     => 'all',
        VERSION  => '3.112+nmu2',
        FILESIZE => '1228'
    },
    {
        FROM     => 'deb',
        NAME     => 'anthy-common',
        COMMENTS => 'input method for Japanese - common files and dictionary',
        ARCH     => 'all',
        VERSION  => '9100h-6',
        FILESIZE => '13068'
    },
    {
        FROM     => 'deb',
        NAME     => 'apache2',
        COMMENTS => 'Apache HTTP Server metapackage',
        ARCH     => 'amd64',
        VERSION  => '2.2.16-6+squeeze6',
        FILESIZE => '36'
    },
    {
        FROM     => 'deb',
        NAME     => 'apache2-mpm-prefork',
        COMMENTS => 'Apache HTTP Server - traditional non-threaded model',
        ARCH     => 'amd64',
        VERSION  => '2.2.16-6+squeeze6',
        FILESIZE => '68'
    },
    {
        FROM     => 'deb',
        NAME     => 'apache2-utils',
        COMMENTS => 'utility programs for webservers',
        ARCH     => 'amd64',
        VERSION  => '2.2.16-6+squeeze6',
        FILESIZE => '384'
    },
    {
        FROM     => 'deb',
        NAME     => 'apache2.2-bin',
        COMMENTS => 'Apache HTTP Server common binary files',
        ARCH     => 'amd64',
        VERSION  => '2.2.16-6+squeeze6',
        FILESIZE => '3856'
    },
    {
        FROM     => 'deb',
        NAME     => 'apache2.2-common',
        COMMENTS => 'Apache HTTP Server common files',
        ARCH     => 'amd64',
        VERSION  => '2.2.16-6+squeeze6',
        FILESIZE => '2144'
    },
    {
        FROM     => 'deb',
        NAME     => 'apt',
        COMMENTS => 'Advanced front-end for dpkg',
        ARCH     => 'amd64',
        VERSION  => '0.8.10.3+squeeze1',
        FILESIZE => '5644'
    },
    {
        FROM     => 'deb',
        NAME     => 'apt-utils',
        COMMENTS => 'APT utility programs',
        ARCH     => 'amd64',
        VERSION  => '0.8.10.3+squeeze1',
        FILESIZE => '540'
    },
    {
        FROM     => 'deb',
        NAME     => 'apt-xapian-index',
        COMMENTS => 'maintenance and search tools for a Xapian index of Debian packages',
        ARCH     => 'all',
        VERSION  => '0.41',
        FILESIZE => '376'
    },
    {
        FROM     => 'deb',
        NAME     => 'aptitude',
        COMMENTS => 'terminal-based package manager (terminal interface only)',
        ARCH     => 'amd64',
        VERSION  => '0.6.3-3.2+squeeze1',
        FILESIZE => '11916'
    },
    {
        FROM     => 'deb',
        NAME     => 'aspell',
        COMMENTS => 'GNU Aspell spell-checker',
        ARCH     => 'amd64',
        VERSION  => '0.60.6-4',
        FILESIZE => '1184'
    },
    {
        FROM     => 'deb',
        NAME     => 'aspell-en',
        COMMENTS => 'English dictionary for GNU Aspell',
        ARCH     => 'all',
        VERSION  => '6.0-0-6',
        FILESIZE => '548'
    },
    {
        FROM     => 'deb',
        NAME     => 'aspell-fr',
        COMMENTS => 'French dictionary for aspell',
        ARCH     => 'all',
        VERSION  => '0.50-3-7',
        FILESIZE => '636'
    },
    {
        FROM     => 'deb',
        NAME     => 'at',
        COMMENTS => 'Delayed job execution and batch processing',
        ARCH     => 'amd64',
        VERSION  => '3.1.12-1',
        FILESIZE => '220'
    }
];

plan tests => 4;

my $packages;
$packages = FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares::RPM::_getPackagesList(
    file => "resources/linux/packaging/rpm"
);
cmp_deeply($packages, $rpm_packages, 'rpm parsing');

$packages = FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares::Deb::_getPackagesList(
    file => "resources/linux/packaging/dpkg"
);
cmp_deeply($packages, $deb_packages, 'dpkg parsing');

ok(
    !FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares::Gentoo::_equeryNeedsWildcard(
        file => "resources/linux/equery/gentoo1"
    ),
    "old equery version"
);

ok(
    FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares::Gentoo::_equeryNeedsWildcard(
        file => "resources/linux/equery/gentoo2"
    ),
    "new equery version"
);
