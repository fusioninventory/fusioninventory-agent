#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Temp qw/tempdir/;
use Test::More;
use Test::Exception;

use FusionInventory::Agent::Storage;

plan tests => 10;

my $storage;
throws_ok {
    $storage = FusionInventory::Agent::Storage->new();
} qr/^no directory parameter/,
'instanciation: no directory';

my $basedir = tempdir(CLEANUP => $ENV{TEST_DEBUG} ? 0 : 1);
my $readdir = "$basedir/read";
mkdir $readdir;
chmod 0555, $readdir;

throws_ok {
    $storage = FusionInventory::Agent::Storage->new(
        directory => $readdir
    );
} qr/^Can't write in/,
'instanciation: non-writable directory';

throws_ok {
    $storage = FusionInventory::Agent::Storage->new(
        directory => "$readdir/subdir"
    );
} qr/^Can't create/,
'instanciation: non-creatable subdirectory';

my $writedir = "$basedir/write";
mkdir $writedir;
chmod 0755, $writedir;

lives_ok {
    $storage = FusionInventory::Agent::Storage->new(
        directory => $writedir
    );
} 'instanciation: writable directory';

lives_ok {
    $storage = FusionInventory::Agent::Storage->new(
        directory => "$writedir/subdir"
    );
} 'instanciation: creatable subdirectory';

ok(-d "$writedir/subdir", "subdirectory creation");

ok(!$storage->has(), "content existence");
ok(!defined $storage->restore(), "content retrieval");

$storage->save(data => { foo => "bar" });

ok($storage->has(), "content existence");
is_deeply($storage->restore(), { foo => "bar" }, "content retrieval");
