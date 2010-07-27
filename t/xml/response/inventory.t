#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More tests => 4;

use_ok( 'FusionInventory::Logger' ); 
use_ok( 'FusionInventory::Agent::XML::Query::Inventory' ); 

my $logger = FusionInventory::Logger->new();
my $inventory = FusionInventory::Agent::XML::Query::Inventory->new({
		logger => $logger,
		config => { VERSION => 'test' },
		target => {
            deviceid => 'CASTROLAPON',
            type => 'local',
            vardir => '/tmp/fusinv'
        }
	});

$inventory->addCPU({
CACHE => 'cache',
CORE => 'core',
DESCRIPTION => 'description',
MANUFACTURER => 'manufacturer',
NAME => 'name',
THREAD => 'thread',
SERIAL => 'serial',
SPEED => 'speed'
});

# Don't want to run a full inventory
$inventory->{isInitialised} = 1;

my $content = $inventory->getContent();

use XML::Simple;
my $href = XMLin($content);
ok($href->{CONTENT}{VERSIONCLIENT}, 'FusionInventory-Agent_vtest');
ok($href->{CONTENT}{CPUS}{CORE}, 'core');
