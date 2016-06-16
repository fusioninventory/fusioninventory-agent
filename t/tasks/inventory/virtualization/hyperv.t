#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::Deep;
use Test::Exception;
use Test::MockModule;
use Test::More;
use UNIVERSAL::require;

use FusionInventory::Agent::Inventory;
use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/lib/fake/windows' if $OSNAME ne 'MSWin32';
}

use Config;
# check thread support availability
if (!$Config{usethreads} || $Config{usethreads} ne 'define') {
    plan skip_all => 'thread support required';
}

Test::NoWarnings->use();

FusionInventory::Agent::Task::Inventory::Virtualization::HyperV->require();

my %tests = (
    'unknown' => [
        {
            VMTYPE    => 'HyperV',
            SUBSYSTEM => 'MS HyperV',
            NAME      => undef,
            STATUS    => 'running',
            UUID      => undef,
            VCPU      => undef,
            MEMORY    => undef,
        },
        {
            VMTYPE    => 'HyperV',
            SUBSYSTEM => 'MS HyperV',
            NAME      => 'vmw7cainf295537',
            STATUS    => 'running',
            UUID      => undef,
            VCPU      => undef,
            MEMORY    => undef,
        },
        {
            VMTYPE    => 'HyperV',
            SUBSYSTEM => 'MS HyperV',
            NAME      => 'COLETA_FABIANO',
            STATUS    => 'running',
            UUID      => undef,
            VCPU      => undef,
            MEMORY    => undef,
        },
        {
            SUBSYSTEM => 'MS HyperV',
            VMTYPE    => 'HyperV',
            NAME      => 'W2012',
            STATUS    => 'shutdown',
            UUID      => undef,
            VCPU      => undef,
            MEMORY    => undef,
        }
    ],
    '2008' => [
        {
            VMTYPE    => 'HyperV',
            SUBSYSTEM => 'MS HyperV',
            NAME      => 'SRV00093',
            STATUS    => 'running',
            UUID      => undef,
            VCPU      => undef,
            MEMORY    => undef,
        },
        {
            VMTYPE    => 'HyperV',
            SUBSYSTEM => 'MS HyperV',
            NAME      => 'vm-0450-glpi',
            STATUS    => 'shutdown',
            UUID      => undef,
            VCPU      => 2,
            MEMORY    => 2048,
        },
    ]
);

plan tests => (2 * scalar keys %tests) + 1;

my $inventory = FusionInventory::Agent::Inventory->new();

# fake Tools::Win32, instead of Task::Inventory::Virtualization::HyperV, as
# it is loaded at runtime
my $module = Test::MockModule->new(
    'FusionInventory::Agent::Tools::Win32'
);

foreach my $test (keys %tests) {
    $module->mock(
        'getWMIObjects',
        mockGetWMIObjects($test)
    );

    my @machines = FusionInventory::Agent::Task::Inventory::Virtualization::HyperV::_getVirtualMachines();
    cmp_deeply(
        \@machines,
        $tests{$test},
        "$test: parsing"
    );
    lives_ok {
        $inventory->addEntry(section => 'VIRTUALMACHINES', entry => $_)
            foreach @machines;
    } "$test: registering";
}
