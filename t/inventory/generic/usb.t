#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Generic::USB;

my %tests = (
    'dell-xt2' => [
        {
            VENDORID  => '1d6b',
            SERIAL    => '0000',
            SUBCLASS  => '0',
            CLASS     => '9',
            PRODUCTID => '0001'
        },
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
            VENDORID  => '1d6b',
            SERIAL    => '0000',
            SUBCLASS  => '0',
            CLASS     => '9',
            PRODUCTID => '0001'
        },
        {
            VENDORID  => '1d6b',
            SERIAL    => '0000',
            SUBCLASS  => '0',
            CLASS     => '9',
            PRODUCTID => '0001'
        },
        {
            VENDORID  => '0a5c',
            SERIAL    => '0123456789ABCD',
            SUBCLASS  => '0',
            CLASS     => '254',
            PRODUCTID => '5801'
        },
        {
            VENDORID  => '1d6b',
            SERIAL    => '0000',
            SUBCLASS  => '0',
            CLASS     => '9',
            PRODUCTID => '0001'
        },
        {
            VENDORID  => '1d6b',
            SERIAL    => '0000',
            SUBCLASS  => '0',
            CLASS     => '9',
            PRODUCTID => '0001'
        },
        {
            VENDORID  => '1b96',
            SUBCLASS  => '0',
            CLASS     => '0',
            PRODUCTID => '0001'
        },
        {
            VENDORID  => '1d6b',
            SERIAL    => '0000',
            SUBCLASS  => '0',
            CLASS     => '9',
            PRODUCTID => '0001'
        },
        {
            VENDORID  => '047d',
            SUBCLASS  => '1',
            CLASS     => '3',
            PRODUCTID => '101f'
        },
        {
            VENDORID  => '1d6b',
            SERIAL    => '0000',
            SUBCLASS  => '0',
            CLASS     => '9',
            PRODUCTID => '0002'
        },
        {
            VENDORID  => '1d6b',
            SERIAL    => '0000',
            SUBCLASS  => '0',
            CLASS     => '9',
            PRODUCTID => '0002'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/generic/lsusb/$test";
    my @devices = FusionInventory::Agent::Task::Inventory::Input::Generic::USB::_getDevices(file => $file);
    is_deeply(\@devices, $tests{$test}, $test);
}
