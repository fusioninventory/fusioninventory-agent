#!/usr/local/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware::Generic;

plan tests => 3;

my $model = {
    oids => {
        cdpCacheAddress    => '.1.3.6.1.4.1.9.9.23.1.2.1.1.4',
        cdpCacheVersion    => '.1.3.6.1.4.1.9.9.23.1.2.1.1.5',
        cdpCacheDeviceId   => '.1.3.6.1.4.1.9.9.23.1.2.1.1.6',
        cdpCacheDevicePort => '.1.3.6.1.4.1.9.9.23.1.2.1.1.7',
        cdpCachePlatform   => '.1.3.6.1.4.1.9.9.23.1.2.1.1.8'
    }
};

my %all_values = (
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.4.24.7' => [ 'STRING', '0xc0a8148b' ],
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.5.24.7' => [ 'STRING', '7.4.9c' ],
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.6.24.7' => [ 'STRING', 'SIPE05FB981A7A7' ],
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.7.24.7' => [ 'STRING', 'Port 1' ],
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.8.24.7' => [ 'STRING', 'Cisco IP Phone SPA508G' ],
);

my $snmp = FusionInventory::Agent::SNMP::Mock->new(hash => \%all_values);

my $ports = {};

my $expected = {
    24 => {
        CONNECTIONS => {
            CDP => 1,
            CONNECTION => {
                MAC      => 'E0:5F:B9:81:A7:A7',
                SYSDESCR => '7.4.9c',
                IFDESCR  => 'Port 1',
                MODEL    => 'Cisco IP Phone SPA508G',
                IP       => '192.168.20.139',
                SYSNAME  => 'SIPE05FB981A7A7'
             }
         }
     }
};

FusionInventory::Agent::Tools::Hardware::Generic::setConnectedDevicesUsingCDP(
    snmp  => $snmp,
    model => $model,
    ports => $ports,
);

cmp_deeply(
    $ports,
    $expected,
    'all CDP informations, full result',
);

my %noversion_values = %all_values;
delete $noversion_values{'.1.3.6.1.4.1.9.9.23.1.2.1.1.5.24.7'};
$snmp = FusionInventory::Agent::SNMP::Mock->new(hash => \%noversion_values);
$ports    = {};
$expected = {};

FusionInventory::Agent::Tools::Hardware::Generic::setConnectedDevicesUsingCDP(
    model => $model,
    snmp  => $snmp,
    ports => $ports,
);

cmp_deeply(
    $ports,
    $expected,
    'missing CDP cache version, no result',
);

my %noplatform_values = %all_values;
delete $noplatform_values{'.1.3.6.1.4.1.9.9.23.1.2.1.1.8.24.7'};
$snmp = FusionInventory::Agent::SNMP::Mock->new(hash => \%noplatform_values);
$ports    = {};
$expected = {};

FusionInventory::Agent::Tools::Hardware::Generic::setConnectedDevicesUsingCDP(
    model => $model,
    snmp  => $snmp,
    ports => $ports,
);

cmp_deeply(
    $ports,
    $expected,
    'missing CDP cache platform, no result',
);
