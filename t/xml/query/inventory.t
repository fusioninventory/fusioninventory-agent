#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Config;
use XML::TreePP;

use FusionInventory::Agent;
use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Logger;

plan tests => 7;

my $inventory;
throws_ok {
    $inventory = FusionInventory::Agent::XML::Query::Inventory->new({
    });
} qr/^no deviceid/, 'no device id';

lives_ok {
    $inventory = FusionInventory::Agent::XML::Query::Inventory->new({
        deviceid => 'foo',
        logger   => FusionInventory::Logger->new(),
    });
} 'everything OK';

isa_ok($inventory, 'FusionInventory::Agent::XML::Query::Inventory');

$inventory->processChecksum();

my $tpp = XML::TreePP->new();
my $content;

$content = {
    REQUEST => {
        DEVICEID => 'foo',
        QUERY => 'INVENTORY',
        CONTENT => {
            HARDWARE => {
                ARCHNAME => $Config{archname},
                CHECKSUM => 262143,
                VMSYSTEM => 'Physical'
            },
            VERSIONCLIENT => $FusionInventory::Agent::AGENT_STRING
        },
    }
};
is_deeply(
    scalar $tpp->parse($inventory->getContent()),
    $content,
    'creation content'
);

$inventory->addCPU({
    NAME => 'void CPU',
    SPEED => 1456,
    MANUFACTURER => 'FusionInventory Developers',
    SERIAL => 'AEZVRV',
    THREAD => 3,
    CORE => 1
});
$inventory->processChecksum();

$content = {
    REQUEST => {
        DEVICEID => 'foo',
        QUERY => 'INVENTORY',
        CONTENT => {
            VERSIONCLIENT => $FusionInventory::Agent::AGENT_STRING,
            HARDWARE => {
                ARCHNAME => $Config{archname},
                CHECKSUM => 1,
                PROCESSORN => 1,
                PROCESSORS => 1456,
                PROCESSORT => 'void CPU',
                VMSYSTEM => 'Physical'
            },
            CPUS => {
                CORE => 1,
                MANUFACTURER => 'FusionInventory Developers',
                NAME => 'void CPU',
                SERIAL => 'AEZVRV',
                SPEED => 1456,
                THREAD => 3,
            }
        },
    }
};
is_deeply(
    scalar $tpp->parse($inventory->getContent()),
    $content,
    'CPU added'
);

$inventory->addEntry({
    section => 'DRIVES',
    entry   => {
        FILESYSTEM => 'ext3',
        FREE       => 9120,
        SERIAL     => '7f8d8f98-15d7-4bdb-b402-46cbed25432b',
        TOTAL      => 18777,
        TYPE       => '/',
        VOLUMN     => '/dev/sda2',
    }
});
$inventory->processChecksum();

$content = {
    REQUEST => {
        DEVICEID => 'foo',
        QUERY => 'INVENTORY',
        CONTENT => {
            VERSIONCLIENT => $FusionInventory::Agent::AGENT_STRING,
            HARDWARE => {
                ARCHNAME => $Config{archname},
                CHECKSUM => 513,
                PROCESSORN => 1,
                PROCESSORS => 1456,
                PROCESSORT => 'void CPU',
                VMSYSTEM => 'Physical'
            },
            CPUS => {
                CORE => 1,
                MANUFACTURER => 'FusionInventory Developers',
                NAME => 'void CPU',
                SERIAL => 'AEZVRV',
                SPEED => 1456,
                THREAD => 3,
            },
            DRIVES => {
                FILESYSTEM => 'ext3',
                FREE => 9120,
                SERIAL => '7f8d8f98-15d7-4bdb-b402-46cbed25432b',
                TOTAL => 18777,
                TYPE => '/',
                VOLUMN => '/dev/sda2'
            }
        },
    }
};
is_deeply(
    scalar $tpp->parse($inventory->getContent()),
    $content,
    'drive added'
);

$inventory->addSoftwareDeploymentPackage({ ORDERID => '1234567891' });
$inventory->processChecksum();

$content = {
    REQUEST => {
        DEVICEID => 'foo',
        QUERY => 'INVENTORY',
        CONTENT => {
            VERSIONCLIENT => $FusionInventory::Agent::AGENT_STRING,
            HARDWARE => {
                ARCHNAME => $Config{archname},
                CHECKSUM => 1,
                PROCESSORN => 1,
                PROCESSORS => 1456,
                PROCESSORT => 'void CPU',
                VMSYSTEM => 'Physical'
            },
            CPUS => {
                CORE => 1,
                MANUFACTURER => 'FusionInventory Developers',
                NAME => 'void CPU',
                SERIAL => 'AEZVRV',
                SPEED => 1456,
                THREAD => 3,
            },
            DRIVES => {
                FILESYSTEM => 'ext3',
                FREE => 9120,
                SERIAL => '7f8d8f98-15d7-4bdb-b402-46cbed25432b',
                TOTAL => 18777,
                TYPE => '/',
                VOLUMN => '/dev/sda2'
            },
            DOWNLOAD => {
                HISTORY => {
                    PACKAGE => {
                        ID => 1234567891
                    }
                }
            }
        },
    }
};
is_deeply(
    scalar $tpp->parse($inventory->getContent()),
    $content,
    'software added'
);
