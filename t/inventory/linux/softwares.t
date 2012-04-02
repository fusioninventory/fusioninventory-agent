#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares::RPM;
use FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares::Deb;
use FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares::Gentoo;

my $rpm_packages = [
    {
        FROM        => 'rpm',
        PUBLISHER   => 'Red Hat, Inc.',
        NAME        => 'specspo',
        COMMENTS    => 'Fedora package descriptions, summaries, and groups.',
        INSTALLDATE => 'Wed Dec 22 23:26:02 2010',
        VERSION     => '13-1.el5',
        FILESIZE    =>  '20486218'
    },
    {
        FROM        => 'rpm',
        PUBLISHER   => 'Red Hat, Inc.',
        NAME        => 'mktemp',
        COMMENTS    => 'A small utility for safely making /tmp files.',
        INSTALLDATE => 'Wed Dec 22 23:26:17 2010',
        VERSION     => '1.5-23.2.2',
        FILESIZE    =>  '15712'
    },
    {
        FROM        => 'rpm',
        PUBLISHER   => 'Red Hat, Inc.',
        NAME        => 'libICE',
        COMMENTS    => 'X.Org X11 libICE runtime library',
        INSTALLDATE => 'Wed Dec 22 23:26:18 2010',
        VERSION     => '1.0.1-2.1',
        FILESIZE    =>  '111181'
    },
    {
        FROM        => 'rpm',
        PUBLISHER   => 'Red Hat, Inc.',
        NAME        => 'nspr',
        COMMENTS    => 'Netscape Portable Runtime',
        INSTALLDATE => 'Wed Dec 22 23:26:22 2010',
        VERSION     => '4.7.3-2.el5',
        FILESIZE    =>  '253512'
    }
];
my $deb_packages = [
    {
        FROM     => 'deb',
        NAME     => 'acpi-support-base',
        COMMENTS => 'scripts for handling base ACPI events such as the power button',
        VERSION  => '0.109-11',
        FILESIZE => '88'
    },
    {
        FROM     => 'deb',
        NAME     => 'acpid',
        COMMENTS => 'Utilities for using ACPI power management',
        VERSION  => '1.0.8-1lenny2',
        FILESIZE => '196'
    },
    {
        FROM     => 'deb',
        NAME     => 'adduser',
        COMMENTS => 'add and remove users and groups',
        VERSION  => '3.110',
        FILESIZE => '944'
    },
    {
        FROM     => 'deb',
        NAME     => 'apt',
        COMMENTS => 'Advanced front-end for dpkg',
        VERSION  => '0.7.20.2+lenny2',
        FILESIZE => '4652'
    },
    {
        FROM     => 'deb',
        NAME     => 'apt-utils',
        COMMENTS => 'APT utility programs',
        VERSION  => '0.7.20.2+lenny2',
        FILESIZE => '396'
    },
    {
        FROM     => 'deb',
        NAME     => 'aptitude',
        COMMENTS => 'terminal-based package manager',
        VERSION  => '0.4.11.11-1~lenny1',
        FILESIZE => '9808'
    },
    {
        FROM     => 'deb',
        NAME     => 'at',
        COMMENTS => 'Delayed job execution and batch processing',
        VERSION  => '3.1.10.2',
        FILESIZE => '220'
    }
];

plan tests => 4;

my $packages;
$packages = FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares::RPM::_getPackagesList(
    file => "resources/linux/packaging/rpm"
);
is_deeply($packages, $rpm_packages, 'rpm parsing');

$packages = FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares::Deb::_getPackagesList(
    file => "resources/linux/packaging/dpkg"
);
is_deeply($packages, $deb_packages, 'dpkg parsing');

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
