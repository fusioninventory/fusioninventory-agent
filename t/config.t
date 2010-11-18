#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Temp qw(tempdir);
use Test::Exception;
use Test::More;

use FusionInventory::Agent::Config;

plan tests => 12;

my $config;

throws_ok {
    $config = FusionInventory::Agent::Config->new();
} qr/^no configuration file/, 'no config file';

throws_ok {
    $config = FusionInventory::Agent::Config->new(directory => '/do/not/exist');
} qr/^non-existing file/, 'non-existing config file';

throws_ok {
    $config = FusionInventory::Agent::Config->new(file => '/do/not/exist');
} qr/^non-existing file/, 'non-existing config file';

my $dir = tempdir(CLEANUP => 1);
my $file = "$dir/agent.cfg";
open (my $fh, '>', $file);
print $fh <<'EOF';
foo1 = foo1
foo2 = foo2

[bar1]
foo10 = foo10
foo11 = foo11

EOF
close $fh;
chmod 0000, $file;

throws_ok {
    $config = FusionInventory::Agent::Config->new(directory => $dir);
} qr/^non-readable file/, 'non-readable config file, indirect access';

throws_ok {
    $config = FusionInventory::Agent::Config->new(file => $file);
} qr/^non-readable file/, 'non-readable config file, direct access';

chmod 0644, $file;

lives_ok {
    $config = FusionInventory::Agent::Config->new(directory => $dir);
} 'config file OK, indirect access';

lives_ok {
    $config = FusionInventory::Agent::Config->new(file => $file);
} 'config file OK, direct access';

isa_ok(
    $config,
    'FusionInventory::Agent::Config',
    'config class'
);

is(
    $config->getValue('default.foo1'),
    'foo1',
    'single value, default block'
);

is(
    $config->getValue('bar1.foo10'),
    'foo10',
    'single value, named block'
);

is_deeply(
    $config->getBlock('bar1'),
    {
        foo10 => 'foo10',
        foo11 => 'foo11',
    },
    'value block'
);

is(
    $config->getValue('scheduler.delaytime'),
    '3600',
    'default value'
);
