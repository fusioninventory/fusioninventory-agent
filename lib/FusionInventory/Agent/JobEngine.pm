package FusionInventory::Agent::JobEngine;

use strict;
use warnings;

use IPC::Open3;
use IO::Select;
use POSIX ":sys_wait_h";

use Data::Dumper; # to pass mod parameters

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
    my ($self, $params) = @_;

    my $name = $params->{name};
    my @cmd = @{$params->{cmd}};
    my $isTask = $params->{isTask};
    my $network = $params->{network};

    my $job = {};

    $job->{name} = $name;
    $job->{isTask} = $isTask;
    $job->{network} = $network;

    my $stdin;
    my $stdout;
    my $stderr;

    use Symbol 'gensym'; $stderr = gensym;

    $job->{pid} = open3(
        $stdin,
        $stdout,
        $stderr,
        @cmd
    );
    die unless $stderr;
    $job->{stdin} = $stdin;
    $job->{stdout} = $stdout;
    $job->{stderr} = $stderr;

    $Data::Dumper::Terse = 1;
    $Data::Dumper::Varname='parameter',

    print $stdin Dumper({
            # TODO
            #config => $config,
            #target => $target,
            #prologresp => $prologresp
        });


    if (!$job->{pid}) {
        print "Failed to start cmd\n";
    }
    print "Job started (".$job->{pid}.")\n";

    push @{$self->{jobs}}, $job;

    return $job
}


sub isModInstalled {
    my ($self, $params) = @_;

    my $module = $params->{module};

    foreach my $inc (@INC) {
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
    my $network = $params->{network};

    return if $config->{'no-'.lc($module)};

    if ($self->{runningTask}) {
        $logger->fault("A task is already running with PID ".$self->{runningTask});
    }

    if (!$self->isModInstalled({ module => $module })) {
        $logger->debug("$module is not avalaible");
        return;
    }

    my @cmd;
    push @cmd, "$EXECUTABLE_NAME";
    push @cmd, "-Ilib" if $config->{devlib};
    push @cmd, "-MFusionInventory::Agent::Task::".$module;
    push @cmd, "-e";
    push @cmd, "FusionInventory::Agent::Task::".$module."::main();";
    push @cmd, "--";
    push @cmd, $target->{vardir};

    $self->{runningTask} = $self->start({
            name => $module,
            isTask => 1,
            cmd => \@cmd,
            network => $network,
        });

}

sub isStillAlive {
    my ($self, $job) = @_;

    return 1 if waitpid( $job->{pid}, WNOHANG) == 0;

    my $child_exit_status = $? >> 8;
    print "End of task ".$job->{name}. " With return code ".$child_exit_status."\n";

    return 0;
}

sub stderr {
    my ($self, $job, $buffer) = @_;

    my $logger = $self->{logger};

    die unless $logger;

    return unless defined($buffer);

    while ($buffer =~ s/(\w+):\s(.*?)\n//) {
        $logger->$1($job->{name}.") ".$2);
    }
    if ($buffer !~ /^\s*$/) {
        $logger->debug("WARNING: remaining error messages: $buffer");
    }
}

sub stdout {
    my ($self, $job, $buffer) = @_;

    my $logger = $self->{logger};
    my $network = $job->{network};

    return unless defined($buffer);

    my $msgType;
    my $in;
    my $tmp;

    foreach my $line (split /\n/, $buffer) {
        if ($line =~ /=BEGIN MSG\((.+)\)=/) {
            $msgType = $1;
            $in = 1;
        } elsif ($in && $buffer =~ /=END MSG=/) {
            $network->send({
                    msgType => $msgType,
                    xmlContent => $tmp,
                });
            $in = 0;
            $msgType = undef;
            $tmp = undef;
        } elsif ($in) {
            $tmp .= $line;
        }
    }

}


sub fetchBuffer {
    my ($self, $job) = @_;

    my $logger = $self->{logger};

    foreach my $buffName (qw/stderr stdout/) {
        my $h = $job->{$buffName};
        my $s = IO::Select->new($h);

        my $buffer;

        my $tmp;
        while ($s->can_read(.5) && ($tmp = <$h>)) {
            last unless defined($tmp);
            $buffer .= $tmp;
        }
        $self->$buffName($job, $buffer);
    }

}

sub beat {
    my ($self) = @_;


    sleep(3);
    use Data::Dumper;

    foreach my $id (1..@{$self->{jobs}}) {
        my $job = $self->{jobs}[$id-1];
        $self->fetchBuffer($job);
        if (!$self->isStillAlive($job)) {
            $self->{runningTask} = undef if $job->{isTask};
            splice(@{$self->{jobs}}, $id-1,1)
        }
    }

    1;
}

1;
