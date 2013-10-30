#!/usr/local/bin/perl

use strict;
use warnings;

use Clone qw(clone);
use Test::More;
use Test::Deep;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware::Generic;

# each item is an arrayref of four elements:
# - raw SNMP values
# - input ports list
# - output ports list
# - test explication
my @cdp_info_tests = (
    [
        {
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.4.24.7' => [ 'STRING', '0xc0a8148b' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.5.24.7' => [ 'STRING', '7.4.9c' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.6.24.7' => [ 'STRING', 'SIPE05FB981A7A7' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.7.24.7' => [ 'STRING', 'Port 1' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.8.24.7' => [ 'STRING', 'Cisco IP Phone SPA508G' ],
        },
        {
            24 => {}
        },
        {
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
        },
        'connected devices info through CDP'
    ],
    [
        {
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.4.24.7' => [ 'STRING', '0xc0a8148b' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.6.24.7' => [ 'STRING', 'SIPE05FB981A7A7' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.7.24.7' => [ 'STRING', 'Port 1' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.8.24.7' => [ 'STRING', 'Cisco IP Phone SPA508G' ],
        },
        {
            24 => {}
        },
        {
            24 => {}
        },
        'connected devices info through CDP, missing CDP cache version'
    ],
    [
        {
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.4.24.7' => [ 'STRING', '0xc0a8148b' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.5.24.7' => [ 'STRING', '7.4.9c' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.6.24.7' => [ 'STRING', 'SIPE05FB981A7A7' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.7.24.7' => [ 'STRING', 'Port 1' ],
        },
        {
            24 => {}
        },
        {
            24 => {}
        },
        'connected devices info through CDP, missing CDP cache platform'
    ],
);

plan tests => 
    scalar @cdp_info_tests;

my $model = {
    oids => {
        cdpCacheAddress    => '.1.3.6.1.4.1.9.9.23.1.2.1.1.4',
        cdpCacheVersion    => '.1.3.6.1.4.1.9.9.23.1.2.1.1.5',
        cdpCacheDeviceId   => '.1.3.6.1.4.1.9.9.23.1.2.1.1.6',
        cdpCacheDevicePort => '.1.3.6.1.4.1.9.9.23.1.2.1.1.7',
        cdpCachePlatform   => '.1.3.6.1.4.1.9.9.23.1.2.1.1.8'
    }
};

foreach my $test (@cdp_info_tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(hash => $test->[0]);
    my $ports = clone($test->[1]);

    FusionInventory::Agent::Tools::Hardware::Generic::_setConnectedDevicesInfoCDP(
        snmp  => $snmp,
        model => $model,
        ports => $ports,
    );

    cmp_deeply(
        $ports,
        $test->[2],
        $test->[3]
    );
}
