package FusionInventory::Agent::Server;

use strict;
use warnings;
use base qw/FusionInventory::Agent/;

use Cwd;
use English qw(-no_match_vars);
use POE;

use FusionInventory::Agent::Server::HTTPD;
use FusionInventory::Agent::Server::Scheduler;

sub run {
    my ($self, %params) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};

    foreach my $job (split(' ', $config->getValues('global.jobs') || '')) {
        push @{$self->{jobs}}, $self->getJobFromConfiguration($job);
    }

    die "No jobs defined, aborting" unless $self->{jobs};

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

    my $www_config = $config->getBlock('www');
    if ($www_config) {
        FusionInventory::Agent::Server::HTTPD->new(
            logger  => $logger,
            state   => $self,
            htmldir => $self->{datadir} . '/html',
            ip      => $www_config->{ip},
            port    => $www_config->{port},
            trust   => $www_config->{trust},
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
}

sub runAllJobs {
    my ($self) = @_;

    $self->runJob($_) foreach (@{$self->{jobs}});
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
