#!/usr/bin/perl
package Logger;
sub new {
    my $self = {};
    bless $self;
}
sub debug {}
1;
package Backend;
sub new {
    my $self = {};
    bless $self;
}
sub feedInventory {}
1;
use strict;
use warnings;

use Test::More;
use FindBin;
use FusionInventory::Agent;
use FusionInventory::Agent::XML::Query::Inventory;

if (!eval "use XML::TreePP;1") {
    eval "use Test::More skip_all => 'Missing XML::TreePP';";
    exit 0
}

my $test = {
    'REQUEST' => {
        'QUERY' => 'INVENTORY',
        'DEVICEID' => 'test-deviceid',
        'CONTENT' => {
            'NETWORKS' => '',
            'BIOS' => '',
            'VERSIONCLIENT' => $FusionInventory::Agent::AGENT_STRING ||
            'FusionInventory-Agent_v'.$FusionInventory::Agent::VERSION,
            'DRIVES' => [
            {
                'VOLUMN' => '/dev/sda2',
                'TOTAL' => '18777',
                'SERIAL' => '7f8d8f98-15d7-4bdb-b402-46cbed25432b',
                'FREE' => '9120',
                'TYPE' => '/',
                'FILESYSTEM' => 'ext3'
            },
            {
                'VOLUMN' => '/dev/hda2',
                'TOTAL' => '177',
                'FREE' => '90',
                'TYPE' => '/toto',
                'FILESYSTEM' => 'ext4'
            }
            ],
            'DOWNLOAD' => {
                'HISTORY' => {
                    'PACKAGE' => [
                    {
                        '-ID' => '1234567891'
                    },
                    {
                        '-ID' => '1234567892'
                    }
                    ]
                }
            },
            'HARDWARE' => {
                'PROCESSORS' => '1456',
                'ARCHNAME' => 'i486-linux-gnu-thread-multi',
                'CHECKSUM' => '262143',
                'PROCESSORN' => '1',
                'PROCESSORT' => 'void CPU',
                'VMSYSTEM' => 'Physical'
            },
            'CPUS' => {
                'SERIAL' => 'AEZVRV',
                'MANUFACTURER' => 'FusionInventory Developers',
                'SPEED' => '1456',
                'THREAD' => '3',
                'NAME' => 'void CPU',
                'CORE' => '1'
            },
        ACCESSLOG => '',
        }
    }
};


plan tests => 1;
my $logger = Logger->new ();
my $backend = Backend->new ();
my $config = {VERSION => $FusionInventory::Agent::VERSION};
my $target = {
    deviceid => 'test-deviceid',
    type => 'server',
    vardir => "/tmp/test$$"
};
my $inventory = FusionInventory::Agent::XML::Query::Inventory->new({
        config => $config,
        target => $target,
        backend => $backend,
        logger => $logger,
    });

$inventory->addCPU({
        NAME => 'void CPU',
        SPEED => 1456,
        MANUFACTURER => 'FusionInventory Developers',
        SERIAL => 'AEZVRV',
        THREAD => 3,
        CORE => 1
    });
$inventory->addDrive({
        FILESYSTEM => 'ext3',
        FREE => 9120,
        SERIAL => '7f8d8f98-15d7-4bdb-b402-46cbed25432b',
        TOTAL => 18777,
        TYPE => '/',
        VOLUMN => '/dev/sda2',
    });
$inventory->addDrive({
        FILESYSTEM => 'ext4',
        FREE => 90,
        TOTAL => 177,
        TYPE => '/toto',
        VOLUMN => '/dev/hda2',
    });

$inventory->addSoftwareDeploymentPackage({ ORDERID => '1234567891' });
$inventory->addSoftwareDeploymentPackage({ ORDERID => '1234567892' });

my $xml = $inventory->getContent();

my $tpp =  XML::TreePP->new();
my $href = $tpp->parse( $xml );

is_deeply($href, $test, "inventory");
