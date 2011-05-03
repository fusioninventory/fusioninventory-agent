#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::Inventory::OS::AIX::Memory;

my %tests = (
    'sample1' => [
        {
            NUMSLOTS    => 0,
            SERIAL      => 'YH10MS5CH923',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'RS6K',
            TYPE        => '00P5767',
            CAPTION     => 'Slot U787A.001.DPM2CW2-P1-C9',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS    => 1,
            SERIAL      => 'YH10MS5CH8ED',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'RS6K',
            TYPE        => '00P5767',
            CAPTION     => 'Slot U787A.001.DPM2CW2-P1-C11',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS    => 2,
            SERIAL      => 'YH10MS5CH8F0',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'RS6K',
            TYPE        => '00P5767',
            CAPTION     => 'Slot U787A.001.DPM2CW2-P1-C14',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS    => 3,
            SERIAL      => 'YH10MS5CH92C',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'RS6K',
            TYPE        => '00P5767',
            CAPTION     => 'Slot U787A.001.DPM2CW2-P1-C16',
            CAPACITY    => '512'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/aix/lsvpd/$test";
    my @memories = FusionInventory::Agent::Task::Inventory::OS::AIX::Memory::_getMemories(file => $file);
    is_deeply(\@memories, $tests{$test}, "memories: $test");
}
