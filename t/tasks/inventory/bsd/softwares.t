#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::BSD::Softwares;

my %pkg_info_tests = (
    'sample1' => [
        {
            NAME     => 'GeoIP',
            COMMENTS => 'Find the country that any IP address or hostname originates',
            VERSION  => '1.4.8_1'
        },
        {
            NAME     => 'ImageMagick',
            COMMENTS => 'Image processing tools',
            VERSION  => '6.7.0.10_1'
        },
        {
            NAME     => 'ORBit2',
            COMMENTS => 'High-performance CORBA ORB with support for the C language',
            VERSION  => '2.14.19'
        },
        {
            NAME     => 'Ocsinventory-Agent',
            COMMENTS => 'Keep track of the computers configuration and software',
            VERSION  => '1.1.2.1_1,1'
        },
        {
            NAME     => 'Ocsinventory-Agent',
            COMMENTS => 'Keep track of the computers configuration and software',
            VERSION  => '2.0,1'
        },
        {
            NAME     => 'OpenEXR',
            COMMENTS => 'A high dynamic-range (HDR) image file format',
            VERSION  => '1.6.1_3'
        },
        {
            NAME     => 'a2ps-a4',
            COMMENTS => 'Formats an ascii file for printing on a postscript printer',
            VERSION  => '4.13b_4'
        },
        {
            NAME     => 'aalib',
            COMMENTS => 'An ascii art library',
            VERSION  => '1.4.r5_6'
        },
        {
            NAME     => 'acidrip',
            COMMENTS => 'GTK2::Perl wrapper for MPlayer and MEncoder for ripping DVD',
            VERSION  => '0.14_8'
        },
        {
            NAME     => 'acroread8',
            COMMENTS => 'Adobe Reader for view, print, and search PDF documents (ENU',
            VERSION  => '8.1.7_3'
        },
        {
            NAME     => 'acroreadwrapper',
            COMMENTS => 'Wrapper script for Adobe Reader',
            VERSION  => '0.0.20110920'
        },
        {
            NAME     => 'alsa-lib',
            COMMENTS => 'ALSA compatibility library',
            VERSION  => '1.0.23'
        },
        {
            NAME     => 'ap22-mod_perl2',
            COMMENTS => 'Embeds a Perl interpreter in the Apache2 server',
            VERSION  => '2.0.5_1,3'
        },
        {
            NAME     => 'apache',
            COMMENTS => 'Version 2.2.x of Apache web server with prefork MPM.',
            VERSION  => '2.2.19'
        },
        {
            NAME     => 'apache-ant',
            COMMENTS => 'Java- and XML-based build tool, conceptually similar to mak',
            VERSION  => '1.8.2'
        },
        {
            NAME     => 'appres',
            COMMENTS => 'Program to list application\'s resources',
            VERSION  => '1.0.3'
        },
        {
            NAME     => 'apr-ipv6-devrandom-gdbm-db42',
            COMMENTS => 'Apache Portability Library',
            VERSION  => '1.4.5.1.3.12'
        },
        {
            NAME     => 'aspell',
            COMMENTS => 'Spelling checker with better suggestion logic than ispell',
            VERSION  => '0.60.6.1'
        },
        {
            NAME     => 'atk',
            COMMENTS => 'A GNOME accessibility toolkit (ATK)',
            VERSION  => '2.0.1'
        },
        {
            NAME     => 'atkmm',
            COMMENTS => 'C++ wrapper for ATK API library',
            VERSION  => '2.22.5'
        },
        {
            NAME     => 'attica',
            COMMENTS => 'Collaboration Services API library',
            VERSION  => '0.2.80,1'
        },
        {
            NAME     => 'atunes',
            COMMENTS => 'A full-featured audio player and manager developed in Java',
            VERSION  => '2.0.1'
        },
        {
            NAME     => 'audacity',
            COMMENTS => 'Audacity is a GUI editor for digital audio waveforms',
            VERSION  => '1.2.4b_9'
        },
        {
            NAME     => 'autoconf',
            COMMENTS => 'Automatically configure source code on many Un*x platforms ',
            VERSION  => '2.13.000227_6'
        },
        {
            NAME     => 'autoconf',
            COMMENTS => 'Automatically configure source code on many Un*x platforms ',
            VERSION  => '2.68'
        },
        {
            NAME     => 'autoconf-wrapper',
            COMMENTS => 'Wrapper script for GNU autoconf',
            VERSION  => '20101119'
        },
        {
            NAME     => 'automake',
            COMMENTS => 'GNU Standards-compliant Makefile generator (1.11)',
            VERSION  => '1.11.1'
        },
        {
            NAME     => 'automake',
            COMMENTS => 'GNU Standards-compliant Makefile generator (1.4)',
            VERSION  => '1.4.6_6'
        },
        {
            NAME     => 'automake-wrapper',
            COMMENTS => 'Wrapper script for GNU automake',
            VERSION  => '20101119'
        },
        {
            NAME     => 'automoc4',
            COMMENTS => 'Automatic moc for Qt 4 packages',
            VERSION  => '0.9.88_1'
        },
        {
            NAME     => 'avahi-app',
            COMMENTS => 'Service discovery on a local network',
            VERSION  => '0.6.29'
        },
        {
            NAME     => 'b43-fwcutter',
            COMMENTS => 'Extracts firmware for Broadcom Wireless adapters',
            VERSION  => '012'
        },
        {
            NAME     => 'babl',
            COMMENTS => 'Dynamic pixel format conversion library',
            VERSION  => '0.1.4'
        },
        {
            NAME     => 'bash',
            COMMENTS => 'The GNU Project\'s Bourne Again SHell',
            VERSION  => '4.1.11'
        }
    ]
);

plan tests => scalar keys %pkg_info_tests;

foreach my $test (keys %pkg_info_tests) {
    my $file = "resources/bsd/pkg_info/$test";
    my $results = FusionInventory::Agent::Task::Inventory::BSD::Softwares::_getPackagesListFromPkgInfo(file => $file);
    cmp_deeply($results, $pkg_info_tests{$test}, $test);
}
