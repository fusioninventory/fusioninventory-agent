#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Temp qw(tempdir);
use Test::Exception;
use Test::More;

use FusionInventory::Agent::Config;

plan tests => 20;

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
key1 = value1
key2 = value1,value2, value3 , value4
key3 =

[section]
key1 = value1
key2 = value1,value2, value3 , value4
key3 =
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
    $config->getValue('default.key1'),
    'value1',
    'single value'
);

is_deeply(
    [ $config->getValues('default.key1') ],
    [ qw/value1/ ],
    'single value, list context'
);

is_deeply(
    $config->getValue('default.key2'),
    [ qw/value1 value2 value3 value4/ ],
    'multiple values'
);

ok(
    !defined $config->getValue('default.key3'),
    'undefined value, default block'
);

ok(
    !defined $config->getValue('default.key4'),
    'non-existing value, default block'
);

is(
    $config->getValue('section.key1'),
    'value1',
    'single value, named block'
);

is_deeply(
    [ $config->getValues('section.key1') ],
    [ qw/value1/ ],
    'single value, list context, named block'
);

is_deeply(
    $config->getValue('section.key2'),
    [ qw/value1 value2 value3 value4/ ],
    'multiple values, named block'
);

ok(
    !defined $config->getValue('section.key3'),
    'undefined value, named block'
);

ok(
    !defined $config->getValue('section.key4'),
    'non-existing value, named block'
);

is_deeply(
    {
        $config->getBlockValues('section'),
    },
    {
        key1 => 'value1',
        key2 => [ qw/value1 value2 value3 value4/ ],
        key3 => undef,
    },
    'value block'
);

is(
    $config->getValue('www.port'),
    '62354',
    'default value'
);
