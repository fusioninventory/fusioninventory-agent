#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::OS::Generic::USB;
use FusionInventory::Agent::Logger;

my %tests = (
    'latitude-xt2' => [
        {
            'vendorId' => '1d6b',
            'serial' => '0000',
            'subClass' => '0',
            'class' => '9',
            'productId' => '0001'
        },
        {
            'vendorId' => '0a5c',
            'subClass' => '0',
            'class' => '9',
            'productId' => '4500'
        },
        {
            'vendorId' => '413c',
            'subClass' => '1',
            'class' => '3',
            'productId' => '8161'
        },
        {
            'vendorId' => '413c',
            'subClass' => '1',
            'class' => '3',
            'productId' => '8162'
        },
        {
            'vendorId' => '413c',
            'subClass' => '1',
            'class' => '254',
            'productId' => '8160'
        },
        {
            'vendorId' => '1d6b',
            'serial' => '0000',
            'subClass' => '0',
            'class' => '9',
            'productId' => '0001'
        },
        {
            'vendorId' => '1d6b',
            'serial' => '0000',
            'subClass' => '0',
            'class' => '9',
            'productId' => '0001'
        },
        {
            'vendorId' => '0a5c',
            'serial' => '0123456789ABCD',
            'subClass' => '0',
            'class' => '254',
            'productId' => '5801'
        },
        {
            'vendorId' => '1d6b',
            'serial' => '0000',
            'subClass' => '0',
            'class' => '9',
            'productId' => '0001'
        },
        {
            'vendorId' => '1d6b',
            'serial' => '0000',
            'subClass' => '0',
            'class' => '9',
            'productId' => '0001'
        },
        {
            'vendorId' => '1b96',
            'subClass' => '0',
            'class' => '0',
            'productId' => '0001'
        },
        {
            'vendorId' => '1d6b',
            'serial' => '0000',
            'subClass' => '0',
            'class' => '9',
            'productId' => '0001'
        },
        {
            'vendorId' => '047d',
            'subClass' => '1',
            'class' => '3',
            'productId' => '101f'
        },
        {
            'vendorId' => '1d6b',
            'serial' => '0000',
            'subClass' => '0',
            'class' => '9',
            'productId' => '0002'
        },
        {
            'vendorId' => '1d6b',
            'serial' => '0000',
            'subClass' => '0',
            'class' => '9',
            'productId' => '0002'
        }
    ]
);

plan tests => scalar keys %tests;

my $logger = FusionInventory::Agent::Logger->new();

foreach my $test (keys %tests) {
    my $file = "resources/lsusb/$test";
    my @devices = FusionInventory::Agent::Task::Inventory::OS::Generic::USB::_getDevices($logger, $file);
    is_deeply(\@devices, $tests{$test}, $test) or print Dumper(\@devices);
use Data::Dumper;
}
