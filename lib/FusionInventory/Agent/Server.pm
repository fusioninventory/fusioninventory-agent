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

    FusionInventory::Agent::Server::Scheduler->new(
        logger => $self->{logger},
        agent  => $self,
    );

    my $www_config = $self->{config}->getBlock('www');
    if ($www_config) {
        FusionInventory::Agent::Server::HTTPD->new(
            logger  => $self->{logger},
            agent   => $self,
            htmldir => $self->{datadir} . '/html',
            ip      => $www_config->{ip},
            port    => $www_config->{port},
            trust   => $www_config->{trust},
        );
    } else {
        $self->{logger}->info("Web interface disabled");
    }

    POE::Kernel->run();
}

sub daemonize {
    my ($self) = @_;

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

    if ($pid) {
        # parent: exit immediatly
        exit;
    } else {
        # child: notify POE kernel
        POE::Kernel->has_forked();
    }
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

Run the the agent as a server.

=head2 daemonize(%params)

Fork the agent in the background.

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
