#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::OS::Linux::iLO;
use FusionInventory::Agent::Logger;
my $logger = FusionInventory::Agent::Logger->new(
        backends => []
);

my %tests = (
    'sample1' => {
            'IPGATEWAY' => '192.168.10.254',
            'IPMASK' => '255.255.248.0',
            'STATUS' => 'Up',
            'SPEED' => '10',
            'TYPE' => 'Ethernet',
            'IPSUBNET' => '192.168.8.0',
            'MANAGEMENT' => 'iLO',
            'DESCRIPTION' => 'Management Interface - HP iLO',
            'IPADDRESS' => '192.168.10.1'
            },
     'sample2-missing-xsltproc' => {
          'IPGATEWAY' => undef,
          'IPMASK' => undef,
          'STATUS' => 'Down',
          'SPEED' => undef,
          'TYPE' => 'Ethernet',
          'IPSUBNET' => '',
          'MANAGEMENT' => 'iLO',
          'DESCRIPTION' => 'Management Interface - HP iLO(err: sh: xsltproc: not found)',
          'IPADDRESS' => undef
        }
);

plan tests => int (keys %tests);

foreach my $test (keys %tests) {
    my $file = "resources/linux/hponcfg_-aw_-/$test";
    my $results = FusionInventory::Agent::Task::Inventory::OS::Linux::iLO::_parseHponcfg(file => $file, logger => $logger);
    is_deeply($results, $tests{$test}, $test);
}

