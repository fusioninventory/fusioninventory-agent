#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Config;

my %config = (
    sample1 => {
        'no-task'     => ['snmpquery', 'wakeonlan'],
        'no-category' => [],
        'httpd-trust' => [],
        'tasks'       => ['inventory', 'deploy', 'inventory']
    },
    sample2 => {
        'no-task'     => [],
        'no-category' => ['printer'],
        'httpd-trust' => ['example', '127.0.0.1', 'foobar', '123.0.0.0/10']
    },
    sample3 => {
        'no-task'     => [],
        'no-category' => [],
        'httpd-trust' => []
    },
    sample4 => {
        'no-task'     => ['snmpquery','wakeonlan','inventory'],
        'no-category' => [],
        'httpd-trust' => [],
        'tasks'       => ['inventory', 'deploy', 'inventory']
    }
);

plan tests => (scalar keys %config) * 3 + 16;

foreach my $test (keys %config) {
    my $c = FusionInventory::Agent::Config->new(options => {
        'conf-file' => "resources/config/$test"
    });

    foreach my $k (qw/ no-task no-category httpd-trust /) {
        cmp_deeply($c->{$k}, $config{$test}->{$k}, $test." ".$k);
    }

    if ($test eq 'sample1') {
        ok ($c->isParamArrayAndFilled('no-task'));
        ok (! $c->isParamArrayAndFilled('no-category'));
        ok (! $c->isParamArrayAndFilled('httpd-trust'));
        ok ($c->isParamArrayAndFilled('tasks'));
    } elsif ($test eq 'sample2') {
        ok (! $c->isParamArrayAndFilled('no-task'));
        ok ($c->isParamArrayAndFilled('no-category'));
        ok ($c->isParamArrayAndFilled('httpd-trust'));
        ok (! $c->isParamArrayAndFilled('tasks'));
    } elsif ($test eq 'sample3') {
        ok (! $c->isParamArrayAndFilled('no-task'));
        ok (! $c->isParamArrayAndFilled('no-category'));
        ok (! $c->isParamArrayAndFilled('httpd-trust'));
        ok (! $c->isParamArrayAndFilled('tasks'));
    } elsif ($test eq 'sample4') {
        ok ($c->isParamArrayAndFilled('no-task'));
        ok (! $c->isParamArrayAndFilled('no-category'));
        ok (! $c->isParamArrayAndFilled('httpd-trust'));
        ok ($c->isParamArrayAndFilled('tasks'));
    }
}
