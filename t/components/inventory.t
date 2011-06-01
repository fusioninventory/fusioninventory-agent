#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use Config;
use Test::More;
use Test::Exception;

use FusionInventory::Agent;
use FusionInventory::Agent::Inventory;
use FusionInventory::Agent::Logger;

plan tests => 19;

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Test' ],
    debug    => 1
);

my $inventory;

lives_ok {
    $inventory = FusionInventory::Agent::Inventory->new(
        logger   => $logger
    );
} 'everything OK';

isa_ok($inventory, 'FusionInventory::Agent::Inventory');

is_deeply(
    $inventory->{content},
    {
        HARDWARE => {
            ARCHNAME => $Config{archname},
            VMSYSTEM => 'Physical'
        },
        VERSIONCLIENT => $FusionInventory::Agent::AGENT_STRING
    },
    'initial state'
);

$inventory->processChecksum();
is(
    $inventory->{content}->{HARDWARE}->{CHECKSUM},
    262143,
    'initial state checksum'
);

throws_ok {
    $inventory->addEntry(
        section => 'FOOS',
    );
} qr/^no entry/, 'no entry';

throws_ok {
    $inventory->addEntry(
        section => 'FOOS',
        entry   => { bar => 1 }
    );
} qr/^unknown section FOOS/, 'unknown section';

$inventory->addEntry(
    section => 'ENVS',
    entry   => { 
        KEY => 'key1',
        VAL => 'val1'
    }
);

my $content;

is_deeply(
    $inventory->{content}->{ENVS},
    [
        { KEY => 'key1', VAL => 'val1' }
    ],
    'first environment variable added'
);

$inventory->addEntry(
    section => 'ENVS',
    entry   => { 
        KEY => 'key2',
        VAL => 'val2'
    }
);

is_deeply(
    $inventory->{content}->{ENVS},
    [
        { KEY => 'key1', VAL => 'val1' },
        { KEY => 'key2', VAL => 'val2' },
    ],
    'second environment variable added'
);

$inventory->addEntry(
    section => 'ENVS',
    entry   => { 
        KEY => 'key3',
        VAL => undef
    }
);

is_deeply(
    $inventory->{content}->{ENVS},
    [
        { KEY => 'key1', VAL => 'val1' },
        { KEY => 'key2', VAL => 'val2' },
        { KEY => 'key3'                },
    ],
    'entry with undefined value added'
);

$inventory->addEntry(
    section => 'ENVS',
    entry   => { 
        KEY => 'key4',
        VAL => "val4\x12"
    }
);

is_deeply(
    $inventory->{content}->{ENVS},
    [
        { KEY => 'key1', VAL => 'val1' },
        { KEY => 'key2', VAL => 'val2' },
        { KEY => 'key3'                },
        { KEY => 'key4', VAL => 'val4' }
    ],
    'entry with non-sanitized value added'
);

$inventory->addEntry(
    section => 'ENVS',
    entry   => { 
        KEY => 'key5',
        LAV => 'val5'
    }
);

is_deeply(
    $inventory->{content}->{ENVS},
    [
        { KEY => 'key1', VAL => 'val1' },
        { KEY => 'key2', VAL => 'val2' },
        { KEY => 'key3'                },
        { KEY => 'key4', VAL => 'val4' },
        { KEY => 'key5'                }
    ],
    'entry with unknown field added'
);

is(
    $logger->{backends}->[0]->{message},
    "unknown field LAV for section ENVS",
    'unknown field logged'
);

$inventory->addEntry(
    section => 'CPUS',
    entry   => {
        NAME         => 'void CPU',
        SPEED        => 1456,
        MANUFACTURER => 'FusionInventory Developers',
        SERIAL       => 'AEZVRV',
        THREAD       => 3,
        CORE         => 1
    }
);

is_deeply(
    $inventory->{content}->{CPUS},
    [
        {
            CORE         => 1,
            MANUFACTURER => 'FusionInventory Developers',
            NAME         => 'void CPU',
            SERIAL       => 'AEZVRV',
            SPEED        => 1456,
            THREAD       => 3,
        },
    ],
    'CPU added'
);

$inventory->setGlobalValues();

is(
    $inventory->{content}->{HARDWARE}->{PROCESSORN},
    1,
    'global CPU number'
);

is(
    $inventory->{content}->{HARDWARE}->{PROCESSORS},
    1456,
    'global CPU speed'
);

is(
    $inventory->{content}->{HARDWARE}->{PROCESSORT},
    'void CPU',
    'global CPU type',
);

$inventory->processChecksum();

is(
    $inventory->{content}->{HARDWARE}->{CHECKSUM},
    1,
    'checksum after CPU addition'
);

$inventory->addEntry(
    section => 'DRIVES',
    entry   => {
        FILESYSTEM => 'ext3',
        FREE       => 9120,
        SERIAL     => '7f8d8f98-15d7-4bdb-b402-46cbed25432b',
        TOTAL      => 18777,
        TYPE       => '/',
        VOLUMN     => '/dev/sda2',
    }
);

is_deeply(
    $inventory->{content}->{DRIVES},
    [
        {
            FILESYSTEM => 'ext3',
            FREE       => 9120,
            SERIAL     => '7f8d8f98-15d7-4bdb-b402-46cbed25432b',
            TOTAL      => 18777,
            TYPE       => '/',
            VOLUMN     => '/dev/sda2'
        }
    ],
    'drive addition'
);

$inventory->processChecksum();

is(
    $inventory->{content}->{HARDWARE}->{CHECKSUM},
    513,
    'checksum after drive addition'
);
