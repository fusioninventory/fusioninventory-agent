#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use File::Basename;
use File::Temp qw(tempdir);
use File::Path qw(mkpath);

use Test::Exception;
use Test::More;
use Test::MockModule;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Task::Maintenance;
use FusionInventory::Agent::Target::Local;
use FusionInventory::Agent::Target::Server;
use FusionInventory::Agent::Target::Scheduler;
use FusionInventory::Agent::Task::Deploy::Datastore;

plan tests => 22;

# Setup a target with a Fatal logger and no debug
my $logger = FusionInventory::Agent::Logger->new(
    logger => [ 'Test' ]
);

my $local = FusionInventory::Agent::Target::Local->new(
    path       => tempdir(CLEANUP => 1),
    logger     => $logger,
    basevardir => tempdir(CLEANUP => 1)
);

my $server = FusionInventory::Agent::Target::Server->new(
    url        => 'http://localhost/glpi-any',
    logger     => $logger,
    basevardir => tempdir(CLEANUP => 1)
);

my $scheduler = FusionInventory::Agent::Target::Scheduler->new(
    storage    => $server->getStorage(),
    logger     => $logger,
    basevardir => tempdir(CLEANUP => 1)
);

my $task;

lives_ok {
    $task = FusionInventory::Agent::Task::Maintenance->new(
        target => $local,
        logger => FusionInventory::Agent::Logger->new( 'debug' => 1 ),
        config => {}
    );
} "Maintenance object instanciation for local target" ;
ok( ! $task->isEnabled(), "Maintenance is disabled for local target");

lives_ok {
    $task = FusionInventory::Agent::Task::Maintenance->new(
        target => $server,
        logger => FusionInventory::Agent::Logger->new( 'debug' => 1 ),
        config => {}
    );
} "Maintenance object instanciation for server target" ;
ok( ! $task->isEnabled(), "Maintenance is disabled for server target");

lives_ok {
    $task = FusionInventory::Agent::Task::Maintenance->new(
        target => $scheduler,
        logger => FusionInventory::Agent::Logger->new( 'debug' => 1 ),
        config => {}
    );
} "Maintenance object instanciation for scheduler target" ;
is(scalar($scheduler->plannedTasks()), 0, "No planned task for scheduler");
is(scalar($scheduler->otherTasks()), 0, "No other tasks");
ok( ! $task->isEnabled(), "Maintenance is disabled for scheduler without task");

$scheduler->plannedTasks('Inventory', 'Something');
is(scalar($scheduler->plannedTasks()), 0, "No planned task for scheduler");
is(scalar($scheduler->otherTasks()), 2, "2 other tasks");
ok( ! $task->isEnabled(), "Maintenance is disabled for scheduler but without Maintenance task");

# Only Maintenance is kept as task, but we need at least Deploy in others
$scheduler->plannedTasks('Inventory', 'TaskXYZ', 'Maintenance','Deploy');
is(scalar($scheduler->plannedTasks()), 1, "One planned tasks for scheduler");
is(scalar($scheduler->otherTasks()), 3, "3 other tasks");
ok( $task->isEnabled(), "Maintenance is enabled for scheduler");

lives_ok {
    $task->run();
} "Doing maintenance";

# Test Deploy maintenance module
my $folder = $scheduler->getStorage()->getDirectory().'/deploy/fileparts/private';
SKIP: {
    my $datastore = FusionInventory::Agent::Task::Deploy::Datastore->new(
        config => {},
        path   => $scheduler->getStorage()->getDirectory(),
        logger => $logger
    );
    skip 'disk is still full', 7
        if $datastore->diskIsFull();

    my @files = map { $folder.'/'.$_.'/test' } (0,time-60,time+3600);
    foreach my $file (@files) {
        File::Path::mkpath(dirname($file));
        open FILE, ">$file" or die "Can't create tmp file: $!\n";
        print FILE "TEST\n";
        close(FILE);
    }
    ok( -f $files[0], "File exists in folder 0");
    ok( -f $files[1], "File exists in past folder");
    ok( -f $files[2], "File exists in future folder");

    lives_ok {
        $task->run();
    } "Doing Deploy maintenance";

    ok( ! -f $files[0], "File removed in folder 0");
    ok( ! -f $files[1], "File removed in past folder");
    ok( -f $files[2], "File exists in future folder");
}
