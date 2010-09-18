#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::MacOS::Mem;
use FusionInventory::Logger;
use Test::More;

my %tests = (
    '10.5-powerpc' => [
        {
            NUMSLOTS     => 0,
            SERIALNUMBER => 'Unknown',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'DDR2 SDRAM',
            CAPACITY     => '1000',
            CAPTION      => 'Status: OK'
        },
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => 'Unknown',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'DDR2 SDRAM',
            CAPACITY     => '1000',
            CAPTION      => 'Status: OK'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => 'Empty',
            DESCRIPTION  => 'Empty',
            TYPE         => 'Empty',
            CAPTION      => 'Status: Empty'
        },
        {
            NUMSLOTS     => 3,
            SERIALNUMBER => 'Empty',
            DESCRIPTION  => 'Empty',
            TYPE         => 'Empty',
            CAPTION      => 'Status: Empty'
        },
        {
            NUMSLOTS     => 4,
            SERIALNUMBER => 'Empty',
            DESCRIPTION  => 'Empty',
            TYPE         => 'Empty',
            CAPTION      => 'Status: Empty'
        },
        {
            NUMSLOTS     => 5,
            SERIALNUMBER => 'Empty',
            DESCRIPTION  => 'Empty',
            TYPE         => 'Empty',
            CAPTION      => 'Status: Empty'
        },
        {
            NUMSLOTS     => 6,
            SERIALNUMBER => 'Empty',
            DESCRIPTION  => 'Empty',
            TYPE         => 'Empty',
            CAPTION      => 'Status: Empty'
        },
        {
            NUMSLOTS     => 7,
            SERIALNUMBER => 'Empty',
            DESCRIPTION  => 'Empty',
            TYPE         => 'Empty',
            CAPTION      => 'Status: Empty'
        }
    ],
    '10.6-intel' => [
        {
            NUMSLOTS     => 0,
            SERIALNUMBER => '0xD5289015',
            DESCRIPTION  => '0x3848544631323836344844592D3636374531',
            SPEED        => '667',
            TYPE         => 'DDR2 SDRAM',
            CAPACITY     => '1000',
            CAPTION      => 'Status: OK'
        },
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => '0x00000000',
            DESCRIPTION  => '0x313032343633363735305320202020202020',
            SPEED        => '667',
            TYPE         => 'DDR2 SDRAM',
            CAPACITY     => '1000',
            CAPTION      => 'Status: OK'
        }
    ],
);

plan tests => scalar keys %tests;

my $logger = FusionInventory::Logger->new();

foreach my $test (keys %tests) {
    my $file = "resources/system_profiler/$test";
    my $memories = FusionInventory::Agent::Task::Inventory::OS::MacOS::Mem::_getMemories($logger, $file);
    is_deeply($memories, $tests{$test}, $test);
}
