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
            'no-ssl-check' => 0,
            'ca-cert-file' => undef,
            'ca-cert-dir'  => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 30,
            'user'         => undef,
        },
        httpd => {
            'disable' => 0,
            'trust'   => [],
            'ip'      => undef,
            'port'    => 62354,
        },
        logger => {
            'file'      => undef,
            'maxsize'   => undef,
            'facility'  => 'LOG_USER',
            'backend'   => 'Stderr',
            'verbosity' => 'info',
        },
        inventory => {
            'disable'            => 0,
            'additional-content' => undef,
            'no-category'        => [],
            'scan-homedirs'      => 0,
            'scan-profiles'      => 0,
            'timeout'            => 30
        },
        deploy => {
            'disable' => 0,
            'no-p2p'  => 0,
        },
        'wakeonlan' => {
            'disable' => 1,
        },
        'netdiscovery' => {
            'disable' => 0,
        },
        'netinventory' => {
            'disable'              => 1,
            'aggregation_as_trunk' => 0,
            'trunk_pvid'           => 0
        },
        'collect' => {
            'disable' => 0,
        },
    },
    sample2 => {
        '_' => {
            'server'       => [ ],
            'tag'          => undef,
        },
        'http' => {
            'no-ssl-check' => 0,
            'ca-cert-file' => undef,
            'ca-cert-dir'  => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 30,
            'user'         => undef,
        },
        'httpd' => {
            'disable' => 0,
            'port'    => 62354,
            'ip'      => undef,
            'trust'   => [ 'example', '127.0.0.1', 'foobar', '123.0.0.0/10' ]
        },
        'logger' => {
            'file'      => undef,
            'maxsize'   => undef,
            'facility'  => 'LOG_USER',
            'backend'   => 'Stderr',
            'verbosity' => 'info',
        },
        'inventory' => {
            'disable'            => 0,
            'additional-content' => undef,
            'no-category'        => [ 'printer' ],
            'timeout'            => 30,
            'scan-homedirs'      => 0,
            'scan-profiles'      => 0,
        },
        'deploy' => {
            'disable' => 0,
            'no-p2p'  => 0,
        },
        'wakeonlan' => {
            'disable' => 0,
        },
        'netdiscovery' => {
            'disable' => 0,
        },
        'netinventory' => {
            'disable'              => 0,
            'aggregation_as_trunk' => 0,
            'trunk_pvid'           => 0
        },
        'collect' => {
            'disable' => 0,
        },
    },
    sample3 => {
        '_' => {
            'server'       => [ ],
            'tag'          => undef,
        },
        'http' => {
            'no-ssl-check' => 0,
            'ca-cert-file' => undef,
            'ca-cert-dir'  => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 30,
            'user'         => undef,
        },
        'httpd' => {
            'disable' => 0,
            'ip'      => undef,
            'trust'   => [ ],
            'port'    => 62354
        },
        'logger' => {
            'file'      => undef,
            'maxsize'   => undef,
            'facility'  => 'LOG_USER',
            'backend'   => 'Stderr',
            'verbosity' => 'info',
        },
        'inventory' => {
            'additional-content' => undef,
            'disable'            => 0,
            'no-category'        => [ ],
            'scan-homedirs'      => 0,
            'scan-profiles'      => 0,
            'timeout'            => 30,
        },
        'deploy' => {
            'disable' => 0,
            'no-p2p'  => 0,
        },
        'wakeonlan' => {
            'disable' => 0,
        },
        'netdiscovery' => {
            'disable' => 0,
        },
        'netinventory' => {
            'disable'              => 0,
            'aggregation_as_trunk' => 0,
            'trunk_pvid'           => 0
        },
        'collect' => {
            'disable' => 0,
        },
    },
    default => {
        _ => {
            'tag'          => undef,
            'server'       => [],
        },
        'http' => {
            'no-ssl-check' => 0,
            'ca-cert-file' => undef,
            'ca-cert-dir'  => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 30,
            'user'         => undef,
        },
        httpd => {
            'disable' => 0,
            'trust'   => [],
            'ip'      => undef,
            'port'    => 62354,
        },
        logger => {
            'file'      => undef,
            'maxsize'   => undef,
            'facility'  => 'LOG_USER',
            'backend'   => 'stderr',
            'verbosity' => 'info',
        },
        inventory => {
            'disable'            => 0,
            'additional-content' => undef,
            'no-category'        => [],
            'scan-homedirs'      => 0,
            'scan-profiles'      => 0,
            'timeout'            => 30
        },
        deploy => {
            'disable' => 0,
            'no-p2p'  => 0,
        },
        'wakeonlan' => {
            'disable' => 0,
        },
        'netdiscovery' => {
            'disable' => 0,
        },
        'netinventory' => {
            'disable'              => 0,
            'aggregation_as_trunk' => 0,
            'trunk_pvid'           => 0
        },
        'collect' => {
            'disable' => 0,
        },
    },
    empty => {
        _ => {
            'tag'          => undef,
            'server'       => [],
        },
        'http' => {
            'no-ssl-check' => 0,
            'ca-cert-file' => undef,
            'ca-cert-dir'  => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 30,
            'user'         => undef,
        },
        httpd => {
            'disable' => 0,
            'trust'   => [],
            'ip'      => undef,
            'port'    => 62354,
        },
        logger => {
            'file'      => undef,
            'maxsize'   => undef,
            'facility'  => 'LOG_USER',
            'backend'   => 'Stderr',
            'verbosity' => 'info',
        },
        inventory => {
            'disable'            => 0,
            'additional-content' => undef,
            'no-category'        => [],
            'scan-homedirs'      => 0,
            'scan-profiles'      => 0,
            'timeout'            => 30
        },
        deploy => {
            'disable' => 0,
            'no-p2p'  => 0,
        },
        'wakeonlan' => {
            'disable' => 0,
        },
        'netdiscovery' => {
            'disable' => 0,
        },
        'netinventory' => {
            'disable'              => 0,
            'aggregation_as_trunk' => 0,
            'trunk_pvid'           => 0
        },
        'collect' => {
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
