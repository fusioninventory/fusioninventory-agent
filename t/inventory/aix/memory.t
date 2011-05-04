#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::Inventory::OS::AIX::Memory;

my %tests = (
    'aix-5.3' => [
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
    ],
    'aix-6.1' => [
        {
            NUMSLOTS    => 0,
            SERIAL      => 'YLD00030486D',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '77P8784',
            CAPTION     => 'Slot U78A0.001.DNWHPLG-P1-C13-C2',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 1,
            SERIAL      => 'YLD003304853',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '77P8784',
            CAPTION     => 'Slot U78A0.001.DNWHPLG-P1-C13-C3',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 2,
            SERIAL      => 'YLD0013047DE',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '77P8784',
            CAPTION     => 'Slot U78A0.001.DNWHPLG-P1-C13-C4',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 3,
            SERIAL      => 'YLD002304855',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '77P8784',
            CAPTION     => 'Slot U78A0.001.DNWHPLG-P1-C13-C5',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 4,
            SERIAL      => 'YLD006304856',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '77P8784',
            CAPTION     => 'Slot U78A0.001.DNWHPLG-P1-C13-C6',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 5,
            SERIAL      => 'YLD00530483B',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '77P8784',
            CAPTION     => 'Slot U78A0.001.DNWHPLG-P1-C13-C7',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 6,
            SERIAL      => 'YLD007304859',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '77P8784',
            CAPTION     => 'Slot U78A0.001.DNWHPLG-P1-C13-C8',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 7,
            SERIAL      => 'YLD00430481E',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '77P8784',
            CAPTION     => 'Slot U78A0.001.DNWHPLG-P1-C13-C9',
            CAPACITY    => '4096'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/aix/lsvpd/$test";
    my @memories = FusionInventory::Agent::Task::Inventory::OS::AIX::Memory::_getMemories(file => $file);
    is_deeply(\@memories, $tests{$test}, "memories: $test");
}
