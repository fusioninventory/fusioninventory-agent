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
            'tag'                  => undef
        },
        server => {
            'url'          => undef,
            'no-ssl-check' => undef,
            'ca-cert-path' => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 180,
            'user'         => undef,
        },
        listener => {
            'disable' => undef,
            'trust'   => [],
            'port'    => 62354,
            'ip'      => undef,
        },
        logger => {
            'backend'  => 'Stderr',
            'debug'    => undef,
            'file'     => undef,
            'maxsize'  => undef,
            'facility' => 'LOG_USER',
        },
        config => {
            'reload-interval' => 0,
        }
    },
    sample2 => {
        file => 'resources/config/sample2',
        _ => {
            'no-module'            => [],
            'tag'                  => undef
        },
        server => {
            'url'          => undef,
            'no-ssl-check' => undef,
            'ca-cert-path' => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 180,
            'user'         => undef,
        },
        listener => {
            'disable' => undef,
            'trust'   => ['example', '127.0.0.1', 'foobar', '123.0.0.0/10'],
            'port'    => 62354,
            'ip'      => undef,
        },
        logger => {
            'backend'  => 'Stderr',
            'debug'    => undef,
            'file'     => undef,
            'maxsize'  => undef,
            'facility' => 'LOG_USER',
        },
        config => {
            'reload-interval' => 0,
        }
    },
    sample3 => {
        file => 'resources/config/sample3',
        _ => {
            'no-module'            => [],
            'tag'                  => undef
        },
        server => {
            'url'          => undef,
            'no-ssl-check' => undef,
            'ca-cert-path' => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 180,
            'user'         => undef,
        },
        listener => {
            'disable' => undef,
            'trust'   => [],
            'port'    => 62354,
            'ip'      => undef,
        },
        logger => {
            'backend'  => 'Stderr',
            'debug'    => undef,
            'file'     => undef,
            'maxsize'  => undef,
            'facility' => 'LOG_USER',
        },
        config => {
            'reload-interval' => 3600,
        }
    },
    sample4 => {
        file => 'resources/config/sample4',
        _ => {
            'no-module'            => ['netinventory', 'wakeonlan', 'inventory'],
            'tag'                  => undef
        },
        server => {
            'url'          => undef,
            'no-ssl-check' => undef,
            'ca-cert-path' => undef,
            'password'     => undef,
            'proxy'        => undef,
            'timeout'      => 180,
            'user'         => undef,
        },
        listener => {
            'disable' => undef,
            'trust'   => [],
            'port'    => 62354,
            'ip'      => undef,
        },
        logger => {
            'backend'  => 'Stderr',
            'debug'    => undef,
            'file'     => undef,
            'maxsize'  => undef,
            'facility' => 'LOG_USER',
        },
        config => {
            'reload-interval' => 60,
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
