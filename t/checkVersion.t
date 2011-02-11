#!/usr/bin/perl -w
use strict;
use File::Glob;
use Test::More;
use Data::Dumper;
use File::Basename;

my %tests = (
        getFusionInventoryTaskList => [
          {
            'version' => '3.0.0',
            'path' => 'lib/FusionInventory/Agent/Task/Inventory.pm',
            'module' => 'Inventory'
          },
          {
            'version' => '3.0.0',
            'path' => 'lib/FusionInventory/Agent/Task/Ping.pm',
            'module' => 'Ping'
          },
          {
            'version' => '3.0.0',
            'path' => 'lib/FusionInventory/Agent/Task/WakeOnLan.pm',
            'module' => 'WakeOnLan'
          }
        ]
);

my @taskPm;
foreach (File::Glob::bsd_glob('lib/FusionInventory/Agent/Task/*.pm')) {
    next if basename($_) eq 'Base.pm';
    push @taskPm, $_;
}


plan tests => 2 + int @taskPm;
use_ok('FusionInventory::Agent::Tools');

foreach (@taskPm) {
    ok (getVersionFromTaskModuleFile($_), 'getVersionFromTaskModuleFile()')
}

my $r = getFusionInventoryTaskList({ devlib => "1" });
is_deeply($r, $tests{getFusionInventoryTaskList}, 'getFusionInventoryTaskList()');
