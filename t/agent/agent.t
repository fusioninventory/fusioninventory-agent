#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use File::Path;
use File::Temp qw(tempdir);
use Test::Deep;
use Test::More;

use FusionInventory::Agent;
use FusionInventory::Agent::Config;
use FusionInventory::Test::Logger::Test;

plan tests => 16;

my $libdir = tempdir(CLEANUP => $ENV{TEST_DEBUG} ? 0 : 1);
push @INC, $libdir;
my $agent = FusionInventory::Agent->new(libdir => $libdir);

my %tasks;

create_file("$libdir/FusionInventory/Agent/Task/Task1", "Version.pm", <<'EOF');
package FusionInventory::Agent::Task::Task1::Version;
use constant VERSION => 42;
1;
EOF
%tasks = $agent->getAvailableTasks();
cmp_deeply (
    \%tasks,
    { 'Task1' => 42 },
    "single task"
);

create_file("$libdir/FusionInventory/Agent/Task/Task2", "Version.pm", <<'EOF');
package FusionInventory::Agent::Task::Task2::Version;
use constant VERSION => 42;
1;
EOF
%tasks = $agent->getAvailableTasks();
cmp_deeply (
    \%tasks,
    {
        'Task1' => 42,
        'Task2' => 42
    },
    "multiple tasks"
);

create_file("$libdir/FusionInventory/Agent/Task/Task3", "Version.pm", <<'EOF');
package FusionInventory::Agent::Task::Task3::Version;
use Does::Not::Exists;
use constant VERSION => 42;
1;
EOF
%tasks = $agent->getAvailableTasks();
cmp_deeply(
    \%tasks,
    {
        'Task1' => 42,
        'Task2' => 42
    },
    "wrong syntax"
);

create_file("$libdir/FusionInventory/Agent/Task/Task5", "Version.pm", <<'EOF');
package FusionInventory::Agent::Task::Task5::Version;
use constant VERSION => 42;
1;
EOF
%tasks = $agent->getAvailableTasks();
cmp_deeply (
    \%tasks,
    {
        'Task1' => 42,
        'Task2' => 42,
        'Task5' => 42
    },
    "multiple tasks"
);

$agent->{config} = FusionInventory::Agent::Config->create(
    backend => 'file',
    file    =>  'etc/agent.cfg'
);
$agent->{config}->{'no-module'} = ['Task5'];
%tasks = $agent->getAvailableTasks(disabledTasks => ['Task5']);
cmp_deeply (
    \%tasks,
    {
        'Task1' => 42,
        'Task2' => 42,
    },
    "multiple tasks, with one disabled"
);

sub create_file {
    my ($directory, $file, $content) = @_;

    mkpath($directory);

    open (my $fh, '>', "$directory/$file")
        or die "can't create $directory/$file: $!";
    print $fh $content;
    close $fh;
}


$agent->{confdir} = 'etc';
$agent->{datadir} = './share';
$agent->{vardir}  = './var',
    # just to be able to run init() method, we inject mandatory options
    my $options = {
        'server' => 'myserver.mywebextension',
        # we force config to be loaded from file
        'config' => 'file'
    };
$agent->init(options => $options);
# after init call, the member 'config' is defined and well blessed
ok (UNIVERSAL::isa($agent->{config}, 'FusionInventory::Agent::Config'));
ok (! defined($agent->{'conf-file'}));
# changing conf-file
$agent->{config}->{file} = 'resources/config/sample1';
ok (scalar(@{$agent->{config}->{'no-module'}}) == 0);
$agent->reinit();
ok (defined($agent->{config}->{'no-module'}));
ok (scalar(@{$agent->{config}->{'no-module'}}) == 2);
ok (
    ($agent->{config}->{'no-module'}->[0] eq 'netinventory' && $agent->{config}->{'no-module'}->[1] eq 'wakeonlan')
        || ($agent->{config}->{'no-module'}->[1] eq 'netinventory' && $agent->{config}->{'no-module'}->[0] eq 'wakeonlan')
);
ok (! defined $agent->{config}->{'server'});


SKIP: {
    skip ('test for Windows only and with config in registry', 4) if ($OSNAME ne 'MSWin32' || $agent->{config}->{config} ne 'registry');

    my $testKey = 'tag';
    my $testValue = 'TEST_REGISTRY_VALUE';
    # change value in registry
    my $settingsInRegistry = FusionInventory::Test::Utils::openWin32Registry();
    $settingsInRegistry->{$testKey} = $testValue;

    my $keyInitialValue = $agent->{config}->{$testKey};
    $agent->{config}->{config} = 'registry';
    $agent->{config}->{'conf-file'} = '';
    ok ($agent->{config}->{config} eq 'registry');
    $agent->reinit();
    # key config must be set
    ok (defined $agent->{config}->{$testKey});
    # and must be the value set in registry
    ok ($agent->{config}->{$testKey} eq $testValue);

    # delete value in registry
    delete $settingsInRegistry->{$testKey};
    $agent->reinit();
    # must have default value which is initial value
    ok ($agent->{config}->{$testKey} eq $keyInitialValue);
}
