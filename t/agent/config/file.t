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
        'no-module'            => ['netinventory', 'wakeonlan'],
        'httpd-trust'          => [],
        'conf-reload-interval' => 0
    },
    sample2 => {
        'no-module'            => [],
        'httpd-trust'          => ['example', '127.0.0.1', 'foobar', '123.0.0.0/10'],
        'conf-reload-interval' => 0
    },
    sample3 => {
        'no-module'            => [],
        'httpd-trust'          => [],
        'conf-reload-interval' => 3600
    },
    sample4 => {
        'no-module'            => ['netinventory', 'wakeonlan', 'inventory'],
        'httpd-trust'          => [],
        'conf-reload-interval' => 60
    }
);

plan tests => (scalar keys %config) * 2 + 21;

foreach my $test (keys %config) {
    my $c = FusionInventory::Agent::Config::File->new(
        file => "resources/config/$test"
    );

    $c->init();

    foreach my $k (qw/ no-module httpd-trust conf-reload-interval /) {
        cmp_deeply($c->{$k}, $config{$test}->{$k}, $test." ".$k);
    }

    if ($test eq 'sample1') {
        ok ($c->isParamArrayAndFilled('no-module'));
        ok (! $c->isParamArrayAndFilled('httpd-trust'));
    } elsif ($test eq 'sample2') {
        ok (! $c->isParamArrayAndFilled('no-module'));
        ok ($c->isParamArrayAndFilled('httpd-trust'));
    } elsif ($test eq 'sample3') {
        ok (! $c->isParamArrayAndFilled('no-module'));
        ok (! $c->isParamArrayAndFilled('httpd-trust'));
    } elsif ($test eq 'sample4') {
        ok ($c->isParamArrayAndFilled('no-module'));
        ok (! $c->isParamArrayAndFilled('httpd-trust'));
    }
}

my $c = FusionInventory::Agent::Config::File->new(
    file => "resources/config/sample1"
);
$c->init();
ok (ref($c->{'no-module'}) eq 'ARRAY');
ok (scalar(@{$c->{'no-module'}}) == 2);

$c->init();
ok (ref($c->{'no-module'}) eq 'ARRAY');
ok (scalar(@{$c->{'no-module'}}) == 2);

$c->{file} = "resources/config/sample2";
$c->init();
#httpd-trust=example,127.0.0.1,foobar,123.0.0.0/10
my %cHttpdTrust = map {$_ => 1} @{$c->{'httpd-trust'}};
ok (defined($cHttpdTrust{'example'}));
ok (defined($cHttpdTrust{'127.0.0.1'}));
ok (defined($cHttpdTrust{'foobar'}));
ok (defined($cHttpdTrust{'123.0.0.0/10'}));
ok (scalar(@{$c->{'httpd-trust'}}) == 4);
