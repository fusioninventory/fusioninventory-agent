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
            'disable' => undef,
            'trust'   => [],
            'ip'      => undef,
            'port'    => 62354,
        },
        logger => {
            'debug'           => 0,
            'logfile'         => undef,
            'logfile-maxsize' => undef,
            'logfacility'     => 'LOG_USER',
            'logger'          => [ 'Stderr' ],
        },
        inventory => {
            'disable'            => 0,
            'additional-content' => undef,
            'scan-homedirs'      => undef,
            'no-category'        => [],
            'scan-profiles'      => undef,
            'execution-timeout'  => 180
        },
        deploy => {
            'disable' => 0,
            'no-p2p'  => undef
        },
        'wakeonlan' => {
            'disable' => 1,
        },
        'netdiscovery' => {
            'disable' => 0,
        },
        'netinventory' => {
            'disable' => 1,
        },
    },
    sample2 => {
        '_' => {
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
            'disable' => undef,
            'port'    => 62354,
            'ip'      => undef,
            'trust'   => [ 'example', '127.0.0.1', 'foobar', '123.0.0.0/10' ]
        },
        'logger' => {
            'debug'           => 0,
            'logfile'         => undef,
            'logfile-maxsize' => undef,
            'logfacility'     => 'LOG_USER',
            'logger'          => [ 'Stderr' ],
        },
        'inventory' => {
            'disable'            => 0,
            'additional-content' => undef,
            'no-category'        => [ 'printer' ],
            'execution-timeout'  => 180,
            'scan-homedirs'      => undef,
            'scan-profiles'      => undef
        },
        'deploy' => {
            'disable' => 0,
            'no-p2p'  => undef
        },
        'wakeonlan' => {
            'disable' => 0,
        },
        'netdiscovery' => {
            'disable' => 0,
        },
        'netinventory' => {
            'disable' => 0,
        },
    },
    sample3 => {
        '_' => {
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
            'disable' => undef,
            'ip'      => undef,
            'trust'   => [ ],
            'port'    => 62354
        },
        'logger' => {
            'debug'           => 0,
            'logfile'         => undef,
            'logfile-maxsize' => undef,
            'logfacility'     => 'LOG_USER',
            'logger'          => [ 'Stderr' ],
        },
        'inventory' => {
            'disable'            => 0,
            'scan-homedirs'      => undef,
            'execution-timeout'  => 180,
            'no-category'        => [ ],
            'scan-profiles'      => undef,
            'additional-content' => undef
        },
        'deploy' => {
            'disable' => 0,
            'no-p2p'  => undef
        },
        'wakeonlan' => {
            'disable' => 0,
        },
        'netdiscovery' => {
            'disable' => 0,
        },
        'netinventory' => {
            'disable' => 0,
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
