#!/usr/local/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;

use FusionInventory::Agent::Manufacturer;

plan tests => 3;

my $walks = {
    cdpCacheDevicePort => {
        OID => '.1.3.6.1.4.1.9.9.23.1.2.1.1.7'
    },
    cdpCacheVersion => {
        OID => '.1.3.6.1.4.1.9.9.23.1.2.1.1.5'
    },
    cdpCacheDeviceId => {
        OID => '.1.3.6.1.4.1.9.9.23.1.2.1.1.6'
    },
    cdpCachePlatform => {
        OID => '.1.3.6.1.4.1.9.9.23.1.2.1.1.8'
    },
};

my $results = {
    cdpCacheAddress => {
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.4.24.7' => '0xc0a8148b'
    },
    cdpCacheDevicePort => {
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.7.24.7' => 'Port 1'
    },
    cdpCacheVersion => {
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.5.24.7' => '7.4.9c'
    },
    cdpCacheDeviceId => {
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.6.24.7' => 'SIPE05FB981A7A7'
    },
    cdpCachePlatform => {
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.8.24.7' => 'Cisco IP Phone SPA508G'
    },
};

my $ports = {};

my $expected = {
    24 => {
        CONNECTIONS => {
            CDP => 1,
            CONNECTION => {
                SYSDESCR => '7.4.9c',
                IFDESCR  => 'Port 1',
                MODEL    => 'Cisco IP Phone SPA508G',
                IP       => '192.168.20.139',
                SYSNAME  => 'SIPE05FB981A7A7'
             }
         }
     }
};

FusionInventory::Agent::Manufacturer::setConnectedDevicesUsingCDP(
    walks   => $walks,
    results => $results,
    ports   => $ports,
);

cmp_deeply(
    $ports,
    $expected,
    'all CDP informations, full result',
);

{
    local $results->{cdpCacheVersion} = undef;

    $ports    = {};
    $expected = {};

    FusionInventory::Agent::Manufacturer::setConnectedDevicesUsingCDP(
        walks   => $walks,
        results => $results,
        ports   => $ports,
    );

    cmp_deeply(
        $ports,
        $expected,
        'missing CDP cache version, no result',
    );
}

{
    local $results->{cdpCachePlatform} = undef;

    $ports    = {};
    $expected = {};

    FusionInventory::Agent::Manufacturer::setConnectedDevicesUsingCDP(
        walks   => $walks,
        results => $results,
        ports   => $ports,
    );

    cmp_deeply(
        $ports,
        $expected,
        'missing CDP cache platform, no result',
    );
}
