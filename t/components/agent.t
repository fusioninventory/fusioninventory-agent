#!/usr/bin/perl

use strict;
use warnings;

use File::Path;
use File::Temp qw(tempdir);
use Test::Deep;
use Test::More;

use FusionInventory::Agent;

plan tests => 4;

my $libdir = tempdir(CLEANUP => $ENV{TEST_DEBUG} ? 0 : 1);
push @INC, $libdir;
my $agent = FusionInventory::Agent->new(libdir => $libdir);

my %tasks;

create_file("$libdir/FusionInventory/Agent/Task", "Task1.pm", <<'EOF');
package FusionInventory::Agent::Task::Task1;
use base qw(FusionInventory::Agent::Task);
our $VERSION = 42;
EOF
%tasks = $agent->getAvailableTasks();
cmp_deeply (
    \%tasks,
    { 'Task1' => 42 },
    "single task"
);

create_file("$libdir/FusionInventory/Agent/Task", "Task2.pm", <<'EOF');
package FusionInventory::Agent::Task::Task2;
use base qw(FusionInventory::Agent::Task);
our $VERSION = 42;
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

create_file("$libdir/FusionInventory/Agent/Task", "Task3.pm", <<'EOF');
package FusionInventory::Agent::Task::Task3;
use base qw(FusionInventory::Agent::Task;
use Does::Not::Exists;
our $VERSION = 42;
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

create_file("$libdir/FusionInventory/Agent/Task", "Test4.pm", <<'EOF');
package FusionInventory::Agent::Task::Test4;
our $VERSION = 42;
EOF
%tasks = $agent->getAvailableTasks();
cmp_deeply(
    \%tasks,
    { 
        'Task1' => 42,
        'Task2' => 42
    },
    "wrong class"
);

sub create_file {
    my ($directory, $file, $content) = @_;

    mkpath($directory);

    open (my $fh, '>', "$directory/$file")
        or die "can't create $directory/$file: $!";
    print $fh $content;
    close $fh;
}
