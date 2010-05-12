package FusionInventory::Agent::JobEngine;

use strict;
use warnings;

use IPC::Open3;
use IO::Select;
use POSIX ":sys_wait_h";

use English;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{config} = $params->{config};
    $self->{logger} = $params->{logger};

    $self->{jobs} = [];

    # We can't have more than on task at the same time
    $self->{runningTask} = undef;

    bless $self;
}

sub start {
    my $self = shift;
    my $name = shift;
    my @cmd = @_;

    my $job = {};

    $job->{name} = $name;

    $job->{pid} = open3(
        $job->{stdin},
        $job->{stdout},
        $job->{stderr},
        @cmd
    );

    if (!$job->{pid}) {
        print "Failed to start cmd\n";
    }
    print "Job started (".$job->{pid}.")\n";

    push @{$self->{jobs}}, $job;

    my $t = $job->{stdout};
    print foreach (<$t>);
    return $job
}


sub isModInstalled {
    my ($self, $params) = @_;

    my $module = $params->{module};

    foreach my $inc (@INC) {
        print $inc.'/FusionInventory/Agent/Task/'.$module.'.pm'."\n";
        return 1 if -f $inc.'/FusionInventory/Agent/Task/'.$module.'.pm';
    }

    return 0;
}


sub isATaskRunning {
    my ($self, $params) = @_;

    return $self->{runningTask}?1:undef;

}

sub startTask {
    my ($self, $params) = @_;

    my $config = $self->{config};
    my $target = $params->{target};
    my $module = $params->{module};
    my $logger = $self->{logger};

    if ($self->{runningTask}) {
        $logger->fault("A task is already running with PID ".$self->{runningTask});
    }

    if (!$self->isModInstalled({ module => $module })) {
        $logger->debug("$module is not avalaible");
    }

    my @cmd;
    push @cmd, "$EXECUTABLE_NAME";
    push @cmd, "-Ilib" if $config->{devlib};
    push @cmd, "-MFusionInventory::Agent::Task::".$module;
    push @cmd, "-e";
    push @cmd, "FusionInventory::Agent::Task::".$module."::main();";
    push @cmd, "--";
    push @cmd, $target->{vardir};

    $self->{runningTask} = $self->start("Module $module", @cmd);

}

sub isDead {
    my ($self) = @_;

    return if waitpid( $self->{pid}, WNOHANG) == 0;

    my $child_exit_status = $? >> 8;
    print "End of task ".$self->{name}. " With return code ".$child_exit_status."\n";

    return 1;
}

sub getError {
    my ($self) = @_;

    my $h = $self->{stdout};
    my $s = IO::Select->new();
    $s->add($h);

    my $buffer;

    my $tmp;
    while ($s->can_read(.5) && ($tmp = <$h>)) {
        last unless defined($tmp);
        $buffer .= $tmp;
    }
    return unless defined($buffer);

    while ($buffer =~ s/(\w+):(.*?)\n//) {
        print "Error($1): $2\n";

    }
    print "remaining error messages:\n $buffer\n";
}

1;
