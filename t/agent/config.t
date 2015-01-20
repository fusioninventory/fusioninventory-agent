#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Config::File;

my %config = (
    sample1 => {
        _ => {
            'tag'          => undef,
            'server'       => [],
            'no-module'    => ['snmpquery', 'wakeonlan'],
        },
        'http' => {
            'no-ssl-check' => undef,
            'ca-cert-file' => undef,
            'ca-cert-dir'  => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 180,
            'user'         => undef,
        },
        httpd => {
            'httpd-trust' => [],
            'httpd-ip'    => undef,
            'httpd-port'  => 62354,
            'no-httpd'    => undef
        },
        logger => {
            'debug'           => 0,
            'logfile'         => undef,
            'logfile-maxsize' => undef,
            'logfacility'     => 'LOG_USER',
            'logger'          => [ 'Stderr' ],
        },
        inventory => {
            'additional-content' => undef,
            'scan-homedirs'      => undef,
            'no-category'        => [],
            'scan-profiles'      => undef,
            'execution-timeout'  => 180
        },
        deploy => {
            'no-p2p' => undef
        }
    },
    sample2 => {
        '_' => {
            'no-module'    => [ ],
            'server'       => [ ],
            'tag'          => undef,
        },
        'http' => {
            'no-ssl-check' => undef,
            'ca-cert-file' => undef,
            'ca-cert-dir'  => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 180,
            'user'         => undef,
        },
        'httpd' => {
            'httpd-port'  => 62354,
            'httpd-ip'    => undef,
            'no-httpd'    => undef,
            'httpd-trust' => [ 'example', '127.0.0.1', 'foobar', '123.0.0.0/10' ]
        },
        'logger' => {
            'debug'           => 0,
            'logfile'         => undef,
            'logfile-maxsize' => undef,
            'logfacility'     => 'LOG_USER',
            'logger'          => [ 'Stderr' ],
        },
        'inventory' => {
            'additional-content' => undef,
            'no-category'        => [ 'printer' ],
            'execution-timeout'  => 180,
            'scan-homedirs'      => undef,
            'scan-profiles'      => undef
        },
        'deploy' => {
            'no-p2p' => undef
        },
    },
    sample3 => {
        '_' => {
            'no-module'    => [ ],
            'server'       => [ ],
            'tag'          => undef,
        },
        'http' => {
            'no-ssl-check' => undef,
            'ca-cert-file' => undef,
            'ca-cert-dir'  => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 180,
            'user'         => undef,
        },
        'httpd' => {
            'httpd-ip'    => undef,
            'no-httpd'    => undef,
            'httpd-trust' => [ ],
            'httpd-port'  => 62354
        },
        'logger' => {
            'debug'           => 0,
            'logfile'         => undef,
            'logfile-maxsize' => undef,
            'logfacility'     => 'LOG_USER',
            'logger'          => [ 'Stderr' ],
        },
        'inventory' => {
            'scan-homedirs'      => undef,
            'execution-timeout'  => 180,
            'no-category'        => [ ],
            'scan-profiles'      => undef,
            'additional-content' => undef
        },
        'deploy' => {
            'no-p2p' => undef
        },
    }
);

plan tests => scalar keys %config;

foreach my $test (sort keys %config) {
    my $config = FusionInventory::Agent::Config::File->new(
        file => "resources/config/$test"
    );
    cmp_deeply(
        $config,
        bless($config{$test}, 'FusionInventory::Agent::Config::File'),
        $test
    );
}
