#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Task::Inventory::MacOS::Hostname;

my %tests = (
    'hostname' => 'mac-fusion01'
);

my $datesStr = {
    "7/8/15 11:11 PM" => '08/07/2015',
    "7/31/09 9:18 AM" => '31/07/2009',
    "1/13/10 6:16 PM" => '13/01/2010',
    "04/09/11 22:42" => '09/04/2011'
};

plan tests => 2;

my $file = 'resources/macos/system_profiler/10.6-system_profiler_Software_SPSoftwareDataType';
my $hostname = FusionInventory::Agent::Task::Inventory::MacOS::Hostname::_getHostname(file => $file, format => 'text');
ok ($hostname eq $tests{hostname});