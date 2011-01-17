#!/usr/bin/perl

use strict;
use warnings;

use File::Temp qw/tempdir/;
use Test::More;
use Test::Exception;

use FusionInventory::Agent::Job;

plan tests => 6;

my $target;
throws_ok {
    $target = FusionInventory::Agent::Job->new();
} qr/^no id parameter/,
'instanciation: no id';

throws_ok {
    $target = FusionInventory::Agent::Job->new(
        id => 'job'
    );
} qr/^no task parameter/,
'instanciation: no task';

throws_ok {
    $target = FusionInventory::Agent::Job->new(
        id   => 'job',
        task => 'task',
    );
} qr/^no target parameter/,
'instanciation: no target';

throws_ok {
    $target = FusionInventory::Agent::Job->new(
        id     => 'job',
        task   => 'task',
        target => 'target',
    );
} qr/^no basevardir parameter/,
'instanciation: no basevardir';

my $basevardir = tempdir(CLEANUP => $ENV{TEST_DEBUG} ? 0 : 1);

lives_ok {
    $target = FusionInventory::Agent::Job->new(
        id         => 'job',
        task       => 'task',
        target     => 'target',
        basevardir => $basevardir
    );
} 'instanciation: ok';

my $storage_dir = "$basevardir/job" ;
ok(-d $storage_dir, "storage directory creation");
