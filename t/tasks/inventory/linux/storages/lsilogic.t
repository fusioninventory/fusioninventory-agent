#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Linux::Storages::Lsilogic;

my %tests = (
    sample1 => {
        name       => 'foo',
        disks   => [
             {
                SIZE         => '152576',
                NAME         => 'foo',
                FIRMWARE     => 'D',
                MANUFACTURER => 'Seagate',
                MODEL        => 'ST3160815AS',
                device       => '/dev/sg1',
            },
            {
                SIZE         => '152576',
                NAME         => 'foo',
                FIRMWARE     => 'D',
                MANUFACTURER => 'Seagate',
                MODEL        => 'ST3160815AS',
                device       => '/dev/sg0',
          }
        ]
    },
    sample2 => {
        name       => 'foo',
        disks      => [
            {
                SIZE         => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'CBRCA146C3ETS0 N',
                MODEL        => 'CBRCA146C3ETS0 N',
                device       => '/dev/sg5',
            },
            {
                SIZE         => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'CBRCA146C3ETS0 N',
                MODEL        => 'CBRCA146C3ETS0 N',
                device       => '/dev/sg4',
            },
            {
                SIZE         => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'B53C',
                MANUFACTURER => 'Seagate',
                MODEL        => 'ST9146803SS',
                device       => '/dev/sg3',
            },
            {
                SIZE         => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'CBRCA146C3ETS0 N',
                MODEL        => 'CBRCA146C3ETS0 N',
                device       => '/dev/sg2',
            },
            {
                SIZE         => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'CBRCA146C3ETS0 N',
                MODEL        => 'CBRCA146C3ETS0 N',
                device       => '/dev/sg1',
            },
            {
                SIZE         => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'CBRCA146C3ETS0 N',
                MODEL        => 'CBRCA146C3ETS0 N',
                device       => '/dev/sg0',
            }
        ]
    }
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/linux/mpt-status/$test";
    my @disks = FusionInventory::Agent::Task::Inventory::Linux::Storages::Lsilogic::_getDiskFromMptStatus(
        file       => $file,
        name       => $tests{$test}->{name},
    );
    cmp_deeply(\@disks, $tests{$test}->{disks}, $test);
}
