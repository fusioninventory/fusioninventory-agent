#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::Deep;
use Test::Exception;
use Test::MockModule;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Inventory;
use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/lib/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Win32::USB;

my %tests = (
    7 => [
        {
            NAME         => 'Generic USB Hub',
            VENDORID     => '8087',
            PRODUCTID    => '0024',
            MANUFACTURER => 'Intel Corp.',
            CAPTION      => 'Integrated Rate Matching Hub'
        },
        {
            NAME         => 'Generic USB Hub',
            VENDORID     => '8087',
            PRODUCTID    => '0024',
            MANUFACTURER => 'Intel Corp.',
            CAPTION      => 'Integrated Rate Matching Hub'
        },
        {
            NAME         => 'ASUS Bluetooth',
            VENDORID     => '0B05',
            MANUFACTURER => 'ASUSTek Computer, Inc.',
            PRODUCTID    => '179C'
        },
        {
            NAME         => 'Périphérique USB composite',
            SERIAL       => '6BE882AB',
            VENDORID     => '046D',
            PRODUCTID    => '08C9',
            CAPTION      => 'QuickCam Ultra Vision',
            MANUFACTURER => 'Logitech, Inc.'

        },
        {
            CAPTION      => 'Premium Optical Wheel Mouse (M-BT58)',
            MANUFACTURER => 'Logitech, Inc.',
            NAME         => 'Périphérique d’entrée USB',
            VENDORID     => '046D',
            PRODUCTID    => 'C03E'
        },
        {
            NAME         => 'Périphérique USB composite',
            VENDORID     => '046D',
            PRODUCTID    => 'C30A',
            CAPTION      => 'iTouch Composite',
            MANUFACTURER => 'Logitech, Inc.'
        },
    ],
    xppro2 => [
        {
            MANUFACTURER => 'Cherry GmbH',
            NAME         => "Concentrador USB genérico",
            VENDORID     => '046A',
            PRODUCTID    => '0009'
        },
        {
            MANUFACTURER => 'Cherry GmbH',
            NAME         => 'Dispositivo compuesto USB',
            VENDORID     => '046A',
            PRODUCTID    => '0019'
        },
        {
            CAPTION      => 'SmartTerminal XX44',
            MANUFACTURER => 'Cherry GmbH',
            NAME         => 'SmartTerminal XX44',
            VENDORID     => '046A',
            PRODUCTID    => '002D'
        },
        {
            CAPTION      => 'Printing Support',
            MANUFACTURER => 'Hewlett-Packard',
            NAME         => 'Compatibilidad con impresoras USB',
            SERIAL       => 'JV40VNJ',
            VENDORID     => '03F0',
            PRODUCTID    => '3A17'
        },
        {
            CAPTION      => 'HL-5250DN Printer',
            MANUFACTURER => 'Brother Industries, Ltd',
            NAME         => 'Compatibilidad con impresoras USB',
            SERIAL       => 'J5J126789',
            VENDORID     => '04F9',
            PRODUCTID    => '002B'
        },
        {
            CAPTION      => 'LaserJet P2015 series',
            MANUFACTURER => 'Hewlett-Packard',
            NAME         => 'Dispositivo compuesto USB',
            SERIAL       => '00CNBW86S20B',
            VENDORID     => '03F0',
            PRODUCTID    => '3817'
        }
    ]
);

plan tests => (2 * scalar keys %tests) + 1;

my $inventory = FusionInventory::Agent::Inventory->new();

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Win32::USB'
);

foreach my $test (keys %tests) {
    $module->mock(
        'getWMIObjects',
        mockGetWMIObjects($test)
    );

    my @devices = FusionInventory::Agent::Task::Inventory::Win32::USB::_getDevices(datadir => './share');
    cmp_deeply(
        \@devices,
        $tests{$test},
        "$test: parsing"
    );
    lives_ok {
        $inventory->addEntry(section => 'USBDEVICES', entry => $_)
            foreach @devices;
    } "$test: registering";
}
