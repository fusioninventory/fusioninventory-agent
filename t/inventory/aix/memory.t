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
    'aix-5.3b' => [
        {
            NUMSLOTS    => 0,
            SERIAL      => '00005055',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'RS6K',
            TYPE        => undef,
            CAPTION     => 'Slot U788D.001.99DXY4Y-P1-C1',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => 1,
            SERIAL      => '04008030',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'RS6K',
            TYPE        => undef,
            CAPTION     => 'Slot U788D.001.99DXY4Y-P1-C2',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => 2,
            SERIAL      => '00007033',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'RS6K',
            TYPE        => undef,
            CAPTION     => 'Slot U788D.001.99DXY4Y-P1-C3',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => 3,
            SERIAL      => '00005031',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'RS6K',
            TYPE        => undef,
            CAPTION     => 'Slot U788D.001.99DXY4Y-P1-C4',
            CAPACITY    => '1024'
        }
    ],
    'aix-5.3c' => [
        {
            NUMSLOTS    => 0,
            SERIAL      => 'YLD001110C29',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P1-C1',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 1,
            SERIAL      => 'YLD005346272',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P1-C2',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 2,
            SERIAL      => 'YLD000110C0C',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P1-C3',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 3,
            SERIAL      => 'YLD004930776',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P1-C4',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 4,
            SERIAL      => 'YLD00793074C',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P1-C5',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 5,
            SERIAL      => 'YLD003810961',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P1-C6',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 6,
            SERIAL      => 'YLD006346270',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P1-C7',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 7,
            SERIAL      => 'YLD00281096F',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P1-C8',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 8,
            SERIAL      => 'YLD009710956',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P2-C1',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 9,
            SERIAL      => 'YLD00D346271',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P2-C2',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 10,
            SERIAL      => 'YLD00851096F',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P2-C3',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 11,
            SERIAL      => 'YLD00C930661',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P2-C4',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 12,
            SERIAL      => 'YLD00F930748',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P2-C5',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 13,
            SERIAL      => 'YLD00B410C26',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P2-C6',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 14,
            SERIAL      => 'YLD00E34627B',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P2-C7',
            CAPACITY    => '4096'
        },
        {
            NUMSLOTS    => 15,
            SERIAL      => 'YLD00A610973',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5036',
            CAPTION     => 'Slot U78A5.001.WIH5D66-P2-C8',
            CAPACITY    => '4096'
        }
    ],
    'aix-6.1b' => [
        {
            NUMSLOTS    => 0,
            SERIAL      => 'YLD0014403BC',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5035',
            CAPTION     => 'Slot U78A5.001.WIH55B2-P1-C1',
            CAPACITY    => '2048'
        },
        {
            NUMSLOTS    => 1,
            SERIAL      => 'YLD0004403BB',
            DESCRIPTION => 'Memory DIMM',
            VERSION     => 'ipzSeries',
            TYPE        => '43X5035',
            CAPTION     => 'Slot U78A5.001.WIH55B2-P1-C3',
            CAPACITY    => '2048'
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
