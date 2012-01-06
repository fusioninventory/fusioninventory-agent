#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::BSD::Softwares;

my %pkg_info_tests = (
    'sample1' => [
        {
            NAME        => 'GeoIP',
            DESCRIPTION => 'Find the country that any IP address or hostname originates',
            VERSION     => '1.4.8_1'
        },
        {
            NAME        => 'ImageMagick',
            DESCRIPTION => 'Image processing tools',
            VERSION     => '6.7.0.10_1'
        },
        {
            NAME        => 'ORBit2',
            DESCRIPTION => 'High-performance CORBA ORB with support for the C language',
            VERSION     => '2.14.19'
        },
        {
            NAME        => 'Ocsinventory-Agent',
            DESCRIPTION => 'Keep track of the computers configuration and software',
            VERSION     => '1.1.2.1_1,1'
        },
        {
            NAME        => 'Ocsinventory-Agent',
            DESCRIPTION => 'Keep track of the computers configuration and software',
            VERSION     => '2.0,1'
        },
        {
            NAME        => 'OpenEXR',
            DESCRIPTION => 'A high dynamic-range (HDR) image file format',
            VERSION     => '1.6.1_3'
        },
        {
            NAME        => 'a2ps-a4',
            DESCRIPTION => 'Formats an ascii file for printing on a postscript printer',
            VERSION     => '4.13b_4'
        },
        {
            NAME        => 'aalib',
            DESCRIPTION => 'An ascii art library',
            VERSION     => '1.4.r5_6'
        },
        {
            NAME        => 'acidrip',
            DESCRIPTION => 'GTK2::Perl wrapper for MPlayer and MEncoder for ripping DVD',
            VERSION     => '0.14_8'
        },
        {
            NAME        => 'acroread8',
            DESCRIPTION => 'Adobe Reader for view, print, and search PDF documents (ENU',
            VERSION     => '8.1.7_3'
        },
        {
            NAME        => 'acroreadwrapper',
            DESCRIPTION => 'Wrapper script for Adobe Reader',
            VERSION     => '0.0.20110920'
        },
        {
            NAME        => 'alsa-lib',
            DESCRIPTION => 'ALSA compatibility library',
            VERSION     => '1.0.23'
        },
        {
            NAME        => 'ap22-mod_perl2',
            DESCRIPTION => 'Embeds a Perl interpreter in the Apache2 server',
            VERSION     => '2.0.5_1,3'
        },
        {
            NAME        => 'apache',
            DESCRIPTION => 'Version 2.2.x of Apache web server with prefork MPM.',
            VERSION     => '2.2.19'
        },
        {
            NAME        => 'apache-ant',
            DESCRIPTION => 'Java- and XML-based build tool, conceptually similar to mak',
            VERSION     => '1.8.2'
        },
        {
            NAME        => 'appres',
            DESCRIPTION => 'Program to list application\'s resources',
            VERSION     => '1.0.3'
        },
        {
            NAME        => 'apr-ipv6-devrandom-gdbm-db42',
            DESCRIPTION => 'Apache Portability Library',
            VERSION     => '1.4.5.1.3.12'
        },
        {
            NAME        => 'aspell',
            DESCRIPTION => 'Spelling checker with better suggestion logic than ispell',
            VERSION     => '0.60.6.1'
        },
        {
            NAME        => 'atk',
            DESCRIPTION => 'A GNOME accessibility toolkit (ATK)',
            VERSION     => '2.0.1'
        },
        {
            NAME        => 'atkmm',
            DESCRIPTION => 'C++ wrapper for ATK API library',
            VERSION     => '2.22.5'
        },
        {
            NAME        => 'attica',
            DESCRIPTION => 'Collaboration Services API library',
            VERSION     => '0.2.80,1'
        },
        {
            NAME        => 'atunes',
            DESCRIPTION => 'A full-featured audio player and manager developed in Java',
            VERSION     => '2.0.1'
        },
        {
            NAME        => 'audacity',
            DESCRIPTION => 'Audacity is a GUI editor for digital audio waveforms',
            VERSION     => '1.2.4b_9'
        },
        {
            NAME        => 'autoconf',
            DESCRIPTION => 'Automatically configure source code on many Un*x platforms ',
            VERSION     => '2.13.000227_6'
        },
        {
            NAME        => 'autoconf',
            DESCRIPTION => 'Automatically configure source code on many Un*x platforms ',
            VERSION     => '2.68'
        },
        {
            NAME        => 'autoconf-wrapper',
            DESCRIPTION => 'Wrapper script for GNU autoconf',
            VERSION     => '20101119'
        },
        {
            NAME        => 'automake',
            DESCRIPTION => 'GNU Standards-compliant Makefile generator (1.11)',
            VERSION     => '1.11.1'
        },
        {
            NAME        => 'automake',
            DESCRIPTION => 'GNU Standards-compliant Makefile generator (1.4)',
            VERSION     => '1.4.6_6'
        },
        {
            NAME        => 'automake-wrapper',
            DESCRIPTION => 'Wrapper script for GNU automake',
            VERSION     => '20101119'
        },
        {
            NAME        => 'automoc4',
            DESCRIPTION => 'Automatic moc for Qt 4 packages',
            VERSION     => '0.9.88_1'
        },
        {
            NAME        => 'avahi-app',
            DESCRIPTION => 'Service discovery on a local network',
            VERSION     => '0.6.29'
        },
        {
            NAME        => 'b43-fwcutter',
            DESCRIPTION => 'Extracts firmware for Broadcom Wireless adapters',
            VERSION     => '012'
        },
        {
            NAME        => 'babl',
            DESCRIPTION => 'Dynamic pixel format conversion library',
            VERSION     => '0.1.4'
        },
        {
            NAME        => 'bash',
            DESCRIPTION => 'The GNU Project\'s Bourne Again SHell',
            VERSION     => '4.1.11'
        }
    ]
);

plan tests => scalar keys %pkg_info_tests;

foreach my $test (keys %pkg_info_tests) {
    my $file = "resources/bsd/pkg_info/$test";
    my $results = FusionInventory::Agent::Task::Inventory::Input::BSD::Softwares::_getPackagesListFromPkgInfo(file => $file);
    is_deeply($results, $pkg_info_tests{$test}, $test);
}
