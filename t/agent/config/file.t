#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::Deep;
use Test::More;
use Storable;
use UNIVERSAL;

use FusionInventory::Agent::Config::File;
use FusionInventory::Test::Utils;

my %config = (
    sample1 => {
        file => 'resources/config/sample1',
        _ => {
            'no-module'            => ['netinventory', 'wakeonlan'],
            'conf-reload-interval' => 0,
            'server'               => undef,
            'tag'                  => undef
        },
        http => {
            'no-ssl-check' => undef,
            'ca-cert-path' => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 180,
            'user'         => undef,
        },
        httpd => {
            'httpd-trust' => [],
            'httpd-port'  => 62354,
            'httpd-ip'    => undef,
            'no-httpd'    => undef,
        },
        logger => {
            'debug'           => undef,
            'logfile'         => undef,
            'logfile-maxsize' => undef,
            'logfacility'     => 'LOG_USER',
            'logger'          => 'Stderr',
        }
    },
    sample2 => {
        file => 'resources/config/sample2',
        _ => {
            'no-module'            => [],
            'conf-reload-interval' => 0,
            'server'               => undef,
            'tag'                  => undef
        },
        http => {
            'no-ssl-check' => undef,
            'ca-cert-path' => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 180,
            'user'         => undef,
        },
        httpd => {
            'httpd-trust' => ['example', '127.0.0.1', 'foobar', '123.0.0.0/10'],
            'httpd-port'  => 62354,
            'httpd-ip'    => undef,
            'no-httpd'    => undef,
        },
        logger => {
            'debug'           => undef,
            'logfile'         => undef,
            'logfile-maxsize' => undef,
            'logfacility'     => 'LOG_USER',
            'logger'          => 'Stderr',
        }
    },
    sample3 => {
        file => 'resources/config/sample3',
        _ => {
            'no-module'            => [],
            'conf-reload-interval' => 3600,
            'server'               => undef,
            'tag'                  => undef
        },
        http => {
            'no-ssl-check' => undef,
            'ca-cert-path' => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 180,
            'user'         => undef,
        },
        httpd => {
            'httpd-trust' => [],
            'httpd-port'  => 62354,
            'httpd-ip'    => undef,
            'no-httpd'    => undef,
        },
        logger => {
            'debug'           => undef,
            'logfile'         => undef,
            'logfile-maxsize' => undef,
            'logfacility'     => 'LOG_USER',
            'logger'          => 'Stderr',
        }
    },
    sample4 => {
        file => 'resources/config/sample4',
        _ => {
            'no-module'            => ['netinventory', 'wakeonlan', 'inventory'],
            'conf-reload-interval' => 60,
            'server'               => undef,
            'tag'                  => undef
        },
        http => {
            'no-ssl-check' => undef,
            'ca-cert-path' => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 180,
            'user'         => undef,
        },
        httpd => {
            'httpd-trust' => [],
            'httpd-port'  => 62354,
            'httpd-ip'    => undef,
            'no-httpd'    => undef,
        },
        logger => {
            'debug'           => undef,
            'logfile'         => undef,
            'logfile-maxsize' => undef,
            'logfacility'     => 'LOG_USER',
            'logger'          => 'Stderr',
        }
    }
);

plan tests => scalar keys %config;

foreach my $test (sort keys %config) {
    my $c = FusionInventory::Agent::Config::File->new(
        file => "resources/config/$test"
    );

    $c->init();

    cmp_deeply(
        $c,
        bless($config{$test}, 'FusionInventory::Agent::Config::File'),
        $test
    );
}
