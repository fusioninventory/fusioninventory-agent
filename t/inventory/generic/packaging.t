#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::RPM;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::Deb;
use FusionInventory::Logger;
use Test::More;

my $rpm_packages = [
    {
        FROM        => 'rpm',
        NAME        => 'lib64nm-util1',
        COMMENTS    => 'Shared library for nm_util',
        INSTALLDATE => 'sam. 13 mars 2010 10:52:59 CET',
        VERSION     => '0.8-3mdv2010.1',
        FILESIZE    => '271504',
    },
    {
        FROM        => 'rpm',
        NAME        => 'libxfixes3',
        COMMENTS    => 'X Fixes  Library',
        INSTALLDATE => 'mer. 05 mai 2010 19:35:31 CEST',
        VERSION     => '4.0.4-1mdv2010.1',
        FILESIZE    => '17672'
    },
    {
        FROM        => 'rpm',
        NAME        => 'eject',
        COMMENTS    => 'A program that ejects removable media using software control',
        INSTALLDATE => 'sam. 13 mars 2010 00:09:59 CET',
        VERSION     => '2.1.5-8mdv2010.1',
        FILESIZE    => '118842'
    },
    {
        FROM        => 'rpm',
        NAME        => 'make',
        COMMENTS    => 'A GNU tool which simplifies the build process for users',
        INSTALLDATE => 'lun. 15 mars 2010 22:48:33 CET',
        VERSION     => '3.81-5mdv2010.1',
        FILESIZE    => '1094120',
    },
    {
        FROM        => 'rpm',
        NAME        => 'lib64xmu6',
        COMMENTS    => 'Xmu Library',
        INSTALLDATE => 'ven. 12 mars 2010 23:25:28 CET',
        VERSION     => '1.0.5-2mdv2010.1',
        FILESIZE    => '117280',
    },
    {
        FROM        => 'rpm',
        NAME        => 'lib64tasn1-devel',
        COMMENTS    => 'The ASN.1 development files',
        INSTALLDATE => 'mer. 28 avril 2010 14:06:27 CEST',
        VERSION     => '2.6-2mdv2010.1',
        FILESIZE    => '491282',
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

plan tests => 2;

my $packages;
$packages = FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::RPM::_getPackagesListFromRpm(
    file => "resources/packaging/rpm"
);
is_deeply($packages, $rpm_packages, 'rpm parsing');

$packages = FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::Deb::_getPackagesListFromDpkg(
    file => "resources/packaging/dpkg"
);
is_deeply($packages, $deb_packages, 'dpkg parsing');
