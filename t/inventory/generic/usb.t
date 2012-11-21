#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Generic::USB;

my %tests = (
    'dell-xt2' => [
        {
            VENDORID  => '0a5c',
            SUBCLASS  => '0',
            CLASS     => '9',
            PRODUCTID => '4500'
        },
        {
            VENDORID  => '413c',
            SUBCLASS  => '1',
            CLASS     => '3',
            PRODUCTID => '8161'
        },
        {
            VENDORID  => '413c',
            SUBCLASS  => '1',
            CLASS     => '3',
            PRODUCTID => '8162'
        },
        {
            VENDORID  => '413c',
            SUBCLASS  => '1',
            CLASS     => '254',
            PRODUCTID => '8160'
        },
        {
            VENDORID  => '0a5c',
            SERIAL    => '0123456789ABCD',
            SUBCLASS  => '0',
            CLASS     => '254',
            PRODUCTID => '5801'
        },
        {
            VENDORID  => '047d',
            SUBCLASS  => '1',
            CLASS     => '3',
            PRODUCTID => '101f'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/generic/lsusb/$test";
    my @devices = FusionInventory::Agent::Task::Inventory::Input::Generic::USB::_getDevices(file => $file);
    is_deeply(\@devices, $tests{$test}, $test);
}
