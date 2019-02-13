#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;
use Test::MockModule;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::Virtualization::Virtuozzo;
use FusionInventory::Agent::Tools::Virtualization;

my %tests = (
    sample1 => {
        ctid_template   => 'sample1-ctid-conf',
        expected        => [
            {
                VMTYPE    => 'Virtuozzo',
                NAME      => 'vz1.mydomain.com',
                SUBSYSTEM => 'debian-8.0-x86_64-minimal',
                STATUS    => STATUS_RUNNING,
                MEMORY    => '8000000',
                UUID      => 'fakeUUID-101',
                VCPU      => 0
            },
            {
                VMTYPE    => 'Virtuozzo',
                NAME      => 'vz2.mydomain.com',
                SUBSYSTEM => 'debian-8.0-x86_64-minimal',
                STATUS    => STATUS_RUNNING,
                MEMORY    => '8000000',
                UUID      => 'fakeUUID-102',
                VCPU      => 0
            },
            {
                VMTYPE    => 'Virtuozzo',
                NAME      => 'vz3.mydomain.com',
                SUBSYSTEM => 'debian-8.0-x86_64-minimal',
                STATUS    => STATUS_RUNNING,
                MEMORY    => '8000000',
                UUID      => 'fakeUUID-103',
                MAC       => '52:54:00:95:1f:77',
                VCPU      => 0
            },
            {
                VMTYPE    => 'Virtuozzo',
                NAME      => 'vz4.mydomain.com',
                SUBSYSTEM => 'debian-8.0-x86_64-minimal',
                STATUS    => STATUS_OFF,
                MEMORY    => '8000000',
                UUID      => 'fakeUUID-104',
                VCPU      => 0
            }
        ]
    }
);

plan tests => (2 * scalar keys %tests) + 1;

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Virtualization::Virtuozzo'
);

my $inventory = FusionInventory::Test::Inventory->new();

# Set a fake UUID as host UUID as used to create VM UUID
$inventory->setHardware({ UUID => "fakeUUID" });

foreach my $test (keys %tests) {
    my $file = "resources/virtualization/virtuozzo/$test";

    $module->mock(
        '_getMACs',
        sub {
            my (%params) = @_;
            # Outputs of 'ip -0 a' could be found in resources like
            # resources/virtualization/virtuozzo/sample1-getmac-101
            my $file = $file . "-getmac-" . $params{ctid};
            return unless -s $file;
            return &{$module->original('_getMACs')}(
                file    => $file,
                %params
            );
        }
    );

    my $machines = FusionInventory::Agent::Task::Inventory::Virtualization::Virtuozzo::_parseVzlist(
        file            => $file,
        inventory       => $inventory,
        ctid_template   => "resources/virtualization/virtuozzo/".$tests{$test}->{ctid_template}
    );
    cmp_deeply($machines, $tests{$test}->{expected}, "$test: parsing");
    lives_ok {
        $inventory->addEntry(section => 'VIRTUALMACHINES', entry => $_)
            foreach @{$machines};
    } "$test: registering";
}
