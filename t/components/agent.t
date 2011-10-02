#!/usr/bin/perl

use strict;
use warnings;

use File::Path qw(make_path);
use File::Temp qw(tempdir);
use Test::More;

use FusionInventory::Agent;

plan tests => 8;

my $agent = FusionInventory::Agent->new();

my %before = $agent->getAvailableTasks();
my $tmpdir = tempdir(CLEANUP => $ENV{TEST_DEBUG} ? 0 : 1);
my $tasks;

create_file("$tmpdir/1/FusionInventory/Agent/Task", "Test1.pm", <<'EOF');
package FusionInventory::Agent::Task::Test1;
use base qw(FusionInventory::Agent::Task);
our $VERSION = 42;
EOF
$tasks = get_new_tasks("$tmpdir/1");
is_deeply (
    $tasks,
    { 'Test1' => 42 },
    "single task"
);

create_file("$tmpdir/2/FusionInventory/Agent/Task", "Test2a.pm", <<'EOF');
package FusionInventory::Agent::Task::Test2a;
use base qw(FusionInventory::Agent::Task);
our $VERSION = 42;
EOF
create_file("$tmpdir/2/FusionInventory/Agent/Task", "Test2b.pm", <<'EOF');
package FusionInventory::Agent::Task::Test2b;
use base qw(FusionInventory::Agent::Task);
our $VERSION = 42;
EOF
$tasks = get_new_tasks("$tmpdir/2");
is_deeply (
    $tasks,
    { 
        'Test2a' => 42,
        'Test2b' => 42
    },
    "multiple tasks, single root"
);

create_file("$tmpdir/3/a/FusionInventory/Agent/Task", "Test3a.pm", <<'EOF');
package FusionInventory::Agent::Task::Test3a;
use base qw(FusionInventory::Agent::Task);
our $VERSION = 42;
EOF
create_file("$tmpdir/3/b/FusionInventory/Agent/Task", "Test3b.pm", <<'EOF');
package FusionInventory::Agent::Task::Test3b;
use base qw(FusionInventory::Agent::Task);
our $VERSION = 42;
EOF
$tasks = get_new_tasks("$tmpdir/3/a", "$tmpdir/3/b");
is_deeply (
    $tasks,
    { 
        'Test3a' => 42,
        'Test3b' => 42
    },
    "multiple tasks, multiple roots"
);

create_file("$tmpdir/4/a/FusionInventory/Agent/Task", "Test4.pm", <<'EOF');
package FusionInventory::Agent::Task::Test4;
use base qw(FusionInventory::Agent::Task);
our $VERSION = 42;
EOF
create_file("$tmpdir/4/b/FusionInventory/Agent/Task", "Test4.pm", <<'EOF');
package FusionInventory::Agent::Task::Test4;
use base qw(FusionInventory::Agent::Task);
our $VERSION = 43;
EOF
$tasks = get_new_tasks("$tmpdir/4/a", "$tmpdir/4/b");
is_deeply (
    $tasks,
    { 
        'Test4' => 42,
    },
    "single tasks, multiple versions, first found wins"
);

create_file("$tmpdir/5/FusionInventory/Task", "Test5.pm", <<'EOF');
package FusionInventory::Agent::Task::Test5;
use base qw(FusionInventory::Agent::Task);
our $VERSION = 42;
EOF
$tasks = get_new_tasks("$tmpdir/5");
is_deeply($tasks, {}, "wrong path");

create_file("$tmpdir/6/FusionInventory/Agent/Task", "Test6", <<'EOF');
package FusionInventory::Agent::Task::Test6;
use base qw(FusionInventory::Agent::Task);
our $VERSION = 42;
EOF
$tasks = get_new_tasks("$tmpdir/6");
is_deeply($tasks, {}, "wrong file name");

create_file("$tmpdir/7/FusionInventory/Agent/Task", "Test7.pm", <<'EOF');
package FusionInventory::Agent::Task::Test7;
use base qw(FusionInventory::Agent::Task;
use Does::Not::Exists;
our $VERSION = 42;
EOF
$tasks = get_new_tasks("$tmpdir/7");
is_deeply($tasks, {}, "wrong syntax");

create_file("$tmpdir/8/FusionInventory/Agent/Task", "Test8.pm", <<'EOF');
package FusionInventory::Agent::Task::Test8;
our $VERSION = 42;
EOF
$tasks = get_new_tasks("$tmpdir/8");
is_deeply($tasks, {}, "wrong class");

sub create_file {
    my ($directory, $file, $content) = @_;

    make_path($directory);

    open (my $fh, '>', "$directory/$file")
        or die "can't create $directory/$file: $!";
    print $fh $content;
    close $fh;
}

sub get_new_tasks {
    my @dirs = @_;

    unshift @INC, @dirs;

    my %after = $agent->getAvailableTasks();

    shift @INC foreach @dirs;

    my $new = {};
    foreach my $key (keys %after) {
        next if exists $before{$key};
        $new->{$key} = $after{$key};
    }

    return $new;
}
