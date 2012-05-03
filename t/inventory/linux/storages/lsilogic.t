#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::Input::Linux::Storages::Lsilogic;
use Test::More;

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
                DESCRIPTION  => 'SATA',
                id           => '1',
                TYPE         => 'disk'
            },
            {
                SIZE         => '152576',
                NAME         => 'foo',
                FIRMWARE     => 'D',
                MANUFACTURER => 'Seagate',
                MODEL        => 'ST3160815AS',
                DESCRIPTION  => 'SATA',
                id           => '0',
                TYPE         => 'disk'
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
                DESCRIPTION  => 'SATA',
                id           => '5',
                TYPE         => 'disk'
            },
            {
                SIZE         => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'CBRCA146C3ETS0 N',
                MODEL        => 'CBRCA146C3ETS0 N',
                DESCRIPTION  => 'SATA',
                id           => '4',
                TYPE         => 'disk'
            },
            {
                SIZE         => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'B53C',
                MANUFACTURER => 'Seagate',
                MODEL        => 'ST9146803SS',
                DESCRIPTION  => 'SATA',
                id           => '3',
                TYPE         => 'disk'
            },
            {
                SIZE         => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'CBRCA146C3ETS0 N',
                MODEL        => 'CBRCA146C3ETS0 N',
                DESCRIPTION  => 'SATA',
                id           => '2',
                TYPE         => 'disk'
            },
            {
                SIZE         => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'CBRCA146C3ETS0 N',
                MODEL        => 'CBRCA146C3ETS0 N',
                DESCRIPTION  => 'SATA',
                id           => '1',
                TYPE         => 'disk'
            },
            {
                SIZE         => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'CBRCA146C3ETS0 N',
                MODEL        => 'CBRCA146C3ETS0 N',
                DESCRIPTION  => 'SATA',
                id           => '0',
                TYPE         => 'disk'
            }
        ]
    }
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/linux/mpt-status/$test";
    my @disks = FusionInventory::Agent::Task::Inventory::Input::Linux::Storages::Lsilogic::_getDiskFromMptStatus(
        file       => $file,
        name       => $tests{$test}->{name},
    );
    is_deeply(\@disks, $tests{$test}->{disks}, $test);
}
