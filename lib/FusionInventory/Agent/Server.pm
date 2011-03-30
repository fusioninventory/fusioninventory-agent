package FusionInventory::Agent::Server;

use strict;
use warnings;
use base qw/FusionInventory::Agent/;

use Cwd;
use English qw(-no_match_vars);
use POE;
use POE qw( Wheel::Run );

use FusionInventory::Agent::Config;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Server::HTTPD;
use FusionInventory::Agent::Server::Scheduler;
use FusionInventory::Agent::Target::Server;

sub run {
    my ($self, %params) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};

# TODO: get the JSON with HTTP
#    foreach my $job (split(' ', $config->getValues('global.jobs') || '')) {
#        push @{$self->{jobs}}, $self->getJobFromConfiguration($job);
#    }
#
#    die "No jobs defined, aborting" unless $self->{jobs};
use JSON;
use LWP::Simple;
 $self->{config} = decode_json(get("http://deploy/fake/?a=getConfig&d=TODO"));
#  $self->{config} = {
#        global => {
#            baseUrl => "http://server/glpi"
#        },
#        httpd => {
#            ip => '0.0.0.0',
#            port => 62354,
#            trust => [ '127.0.0.1' ]
#        },
#    jobs => [
#    {
#        task => 'Config', 
#        remote => '/plugins/fusioninventory/b',
#        periodicity => 3600,
#        startAt => 1301324176
#    },
#    {
#        task => 'Deploy',
#        remote => 'https://server2/deploy',
#        periodicity => 600
#    },
#    {
#        task => 'ESX',
#        remote => '/plugins/fusioninventory/b',
#        startAt => 1,
#        periodicity => 700
#    },
#    {
#        task => 'Inventory',
#        remote => '/plugins/fusinvinventory/b',
#        startAt => 1,
#        periodicity => 36000
#    }
#        ]
#    };
#

    if ($params{fork}) {
        Proc::Daemon->require();
        die "Unable to load Proc::Daemon, exiting..." if $EVAL_ERROR;

        my $daemon = Proc::Daemon->new(
            work_dir => $self->{vardir},
            pid_file => 'server.pid',
        );

        # check if the daemon is already running
        die "A server is already running, exiting..." if $daemon->Status(
            $self->{vardir} . '/server.pid'
        );

        # fork
        my $pid = $daemon->Init();

        # call main POE loop in child only
        if (!$pid) {
            POE::Kernel->has_forked();
            $self->init();
            POE::Kernel->run();
        }
    } else {
        # call main POE loop
        $self->init();
        POE::Kernel->run();
    }
}

sub init {
    my ($self) = @_;

    my $logger = $self->{logger};
    my $config = $self->{config};

    FusionInventory::Agent::Server::Scheduler->new(
        logger => $logger,
        state  => $self,
    );

    $self->{jobs} = [];
    foreach (@{$self->{config}{jobs}}) {
# TODO: Move this somewhere else?
        my $target = FusionInventory::Agent::Target::Server->new(
                id => "TODO",
                url => $_->{remote},
                logger => $logger
                );

        push @{$self->{jobs}}, FusionInventory::Agent::Job->new(
                id => $_->{task},
                task => $_->{task},
                offset => $_->{periodicity},
                startAt => $_->{startAt},
                remote => $_->{remote},
                target => $target,
                basevardir => "TODO"
                );
    }


    my $www_config = $config->{'httpd'};
    if ($www_config) {
        FusionInventory::Agent::Server::HTTPD->new(
            logger  => $logger,
            state   => $self,
            htmldir => $self->{datadir} . '/html',
            ip      => $config->{ip},
            port    => $config->{port},
            trust   => $config->{trust},
        );
    } else {
        $logger->info("Web interface disabled");
    }
}

sub getToken {
    my ($self) = @_;
    return $self->{token};
}

sub getJobs {
    my ($self) = @_;
    return @{$self->{jobs}};
}

sub resetToken {
    my ($self) = @_;
    $self->{token} = _computeNewToken();
}

sub runJob {
    my ($self, $job) = @_;

    $self->{logger}->debug("[server] running job $job->{id}");

    $job->scheduleNextRun();
  POE::Session->create(
    inline_states => {
      _start           => sub {

      print $_[KERNEL]->alias_resolve("job")."\n";
      if (defined $_[KERNEL]->alias_resolve("job")) {
      print "a job is already running.\n";
      return;
      }



        $_[KERNEL]->alias_set("job");

    my $child = POE::Wheel::Run->new(
      Program => sub {
        my $taskPkg = "FusionInventory::Agent::Task::".$job->{task};
        $taskPkg->require();
        my $task = $taskPkg->new();
        $task->run(
                logger => $self->{logger},
                target => $job->{target},
                deviceid => $self->{deviceid}
                );
      },
      StdoutEvent  => "got_child_stdout",
      StderrEvent  => "got_child_stderr",
      CloseEvent   => "got_child_close",
    );

    $_[KERNEL]->sig_child($child->PID, "got_child_signal");
    $_[HEAP]{children_by_wid}{$child->ID} = $child;
    $_[HEAP]{children_by_pid}{$child->PID} = $child;

    print(
      "Child pid ", $child->PID,
      " started as wheel ", $child->ID, ".\n"
    );
  },
#      got_child_stdout => \&on_child_stdout,
#      got_child_stderr => \&on_child_stderr,
      got_child_close  => \&on_child_close,
      got_child_signal => \&on_child_signal,
    }
  );

}

sub runAllJobs {
    my ($self) = @_;

    $self->runJob($_) foreach (@{$self->{jobs}});
}



  # Wheel event, including the wheel's ID.
  sub on_child_stdout {
    my ($stdout_line, $wheel_id) = @_[ARG0, ARG1];
    my $child = $_[HEAP]{children_by_wid}{$wheel_id};
    print "pid ", $child->PID, " STDOUT: $stdout_line\n";
  }

  # Wheel event, including the wheel's ID.
  sub on_child_stderr {
    my ($stderr_line, $wheel_id) = @_[ARG0, ARG1];
    my $child = $_[HEAP]{children_by_wid}{$wheel_id};
    print "pid ", $child->PID, " STDERR: $stderr_line\n";
  }

  # Wheel event, including the wheel's ID.
  sub on_child_close {
    my $wheel_id = $_[ARG0];
    $_[KERNEL]->alias_remove("job");
    my $child = delete $_[HEAP]{children_by_wid}{$wheel_id};

    # May have been reaped by on_child_signal().
    unless (defined $child) {
      print "wid $wheel_id closed all pipes.\n";
      return;
    }

    print "pid ", $child->PID, " closed all pipes.\n";
    delete $_[HEAP]{children_by_pid}{$child->PID};
  }

  sub on_child_signal {
    print "pid $_[ARG1] exited with status $_[ARG2].\n";
    my $child = delete $_[HEAP]{children_by_pid}{$_[ARG1]};

    # May have been reaped by on_child_close().
    return unless defined $child;
    delete $_[HEAP]{children_by_wid}{$child->ID};
  }


1;

__END__

=head1 NAME

FusionInventory::Server - Fusion Inventory server

=head1 DESCRIPTION

This is the agent object.

=head1 METHODS

=head2 new(%params)

The constructor.

=head2 run(%params)

Run the server.

=head2 getToken()

Get the current authentication token.

=head2 resetToken()

Reset the current authentication token to a new random value.

=head2 runJob($job)

Run the given job

=head2 runAllJobs()

Run all available jos

=head2 getJobs()

Return all available jos
