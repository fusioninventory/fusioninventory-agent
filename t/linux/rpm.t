#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::RPM;
use FusionInventory::Logger;
use Test::More;

my %tests = (
    mandriva => [
        {
            FROM        => 'rpm',
            NAME        => 'lib64nm-util1.x86_64',
            COMMENTS    => 'Shared library for nm_util',
            INSTALLDATE => 'sam. 13 mars 2010 10:52:59 CET',
            VERSION     => '0.8-3mdv2010.1',
            FILESIZE    => '271504',
        },
        {
            FROM        => 'rpm',
            NAME        => 'libxfixes3.i586',
            COMMENTS    => 'X Fixes  Library',
            INSTALLDATE => 'mer. 05 mai 2010 19:35:31 CEST',
            VERSION     => '4.0.4-1mdv2010.1',
            FILESIZE    => '17672'
        },
        {
            FROM        => 'rpm',
            NAME        => 'eject.x86_64',
            COMMENTS    => 'A program that ejects removable media using software control',
            INSTALLDATE => 'sam. 13 mars 2010 00:09:59 CET',
            VERSION     => '2.1.5-8mdv2010.1',
            FILESIZE    => '118842'
        },
        {
            FROM        => 'rpm',
            NAME        => 'make.x86_64',
            COMMENTS    => 'A GNU tool which simplifies the build process for users',
            INSTALLDATE => 'lun. 15 mars 2010 22:48:33 CET',
            VERSION     => '3.81-5mdv2010.1',
            FILESIZE    => '1094120',
        },
        {
            FROM        => 'rpm',
            NAME        => 'lib64xmu6.x86_64',
            COMMENTS    => 'Xmu Library',
            INSTALLDATE => 'ven. 12 mars 2010 23:25:28 CET',
            VERSION     => '1.0.5-2mdv2010.1',
            FILESIZE    => '117280',
        },
        {
            FROM        => 'rpm',
            NAME        => 'lib64tasn1-devel.x86_64',
            COMMENTS    => 'The ASN.1 development files',
            INSTALLDATE => 'mer. 28 avril 2010 14:06:27 CEST',
            VERSION     => '2.6-2mdv2010.1',
            FILESIZE    => '491282',
        }
    ]
);

plan tests => scalar keys %tests;

my $logger = FusionInventory::Logger->new();

foreach my $test (keys %tests) {
    my $file = "resources/rpm/$test";
    my $packages = FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::RPM::_parseRpm($logger, $file);
    is_deeply($packages, $tests{$test}, $test);
}
