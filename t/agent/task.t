#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Temp qw(tempdir);
use Test::More;
use Test::Exception;

use FusionInventory::Agent::Target::Local;
use FusionInventory::Agent::Task::Inventory;
use FusionInventory::Agent::Tools;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/lib/fake/windows' if $OSNAME ne 'MSWin32';
}

plan tests => 9;

my $task;
throws_ok {
    $task = FusionInventory::Agent::Task::Inventory->new();
} qr/^no target parameter/,
'instanciation: no target';

lives_ok {
    $task = FusionInventory::Agent::Task::Inventory->new(
        target => FusionInventory::Agent::Target::Local->new(
            path => tempdir(),
            basevardir => tempdir()
        ),
    );
} 'instanciation: ok';

my @modules = $task->getModules();
ok(@modules != 0, 'modules list is not empty');
ok(
    (all { $_ =~ /^FusionInventory::Agent::Task::Inventory::/ } @modules),
    'modules list only contains inventory modules'
);

use Config;
# check thread support availability
SKIP: {
    skip ('thread support required', 5)
        if (!$Config{usethreads} || $Config{usethreads} ne 'define');

    # WMI inventory as derivated Inventory task
    require_ok('FusionInventory::Agent::Task::WMI');

    lives_ok {
        $task = FusionInventory::Agent::Task::WMI->new(
            target => FusionInventory::Agent::Target::Local->new(
                path => tempdir(),
                basevardir => tempdir()
            )
        );
    } 'WMI task instanciation: ok';

    @modules = $task->getModules();
    ok(@modules != 0, 'wmi modules list is not empty');
    ok(
        (all { $_ =~ /^FusionInventory::Agent::Task::Inventory::/ } @modules),
        'modules list only contains inventory modules'
    );
    cmp_ok(
        (all { $_ =~ /^FusionInventory::Agent::Task::Inventory::Generic::Software/ } @modules),
        '==', 0,
        'module list without inventory modules for generic softwares'
    );
}
