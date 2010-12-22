package FusionInventory::Agent::Server;

use strict;
use warnings;
use base qw/FusionInventory::Agent/;

use Cwd;
use English qw(-no_match_vars);
use POE;
use POE::Component::IKC::Server;

use FusionInventory::Agent::Config;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Server::HTTPD;
use FusionInventory::Agent::Server::Scheduler;
use FusionInventory::Agent::Target::Local;
use FusionInventory::Agent::Target::Stdout;
use FusionInventory::Agent::Target::Server;
use FusionInventory::Agent::XML::Query::Prolog;

sub run {
    my ($self, %params) = @_;

    my $config = $self->{config};

    foreach my $target_name ($config->getValues('global.targets')) {
        my $target_config = $config->getBlock($target_name);
        die "No configuration section for target $target_name, aborting"
            unless keys %$target_config;

        my $target_type = $target_config->{type}
            or die "No type for target $target_name, aborting";

        SWITCH: {
            if ($target_type eq 'stdout') {
                push
                    @{$self->{targets}},
                    FusionInventory::Agent::Target::Stdout->new(
                        id         => $target_name,
                        logger     => $self->{logger},
                        basevardir => $self->{vardir},
                        period     => $target_config->{delaytime},
                        format     => $target_config->{format}
                    );
                last SWITCH;
            }

            if ($target_type eq 'local') {
                push
                    @{$self->{targets}},
                    FusionInventory::Agent::Target::Local->new(
                        id         => $target_name,
                        logger     => $self->{logger},
                        basevardir => $self->{vardir},
                        period     => $target_config->{delaytime},
                        path       => $target_config->{path},
                        format     => $target_config->{format}
                    );
                last SWITCH;
            }

            if ($target_type eq 'server') {
                push
                    @{$self->{targets}},
                    FusionInventory::Agent::Target::Server->new(
                        id           => $target_name,
                        logger       => $self->{logger},
                        basevardir   => $self->{vardir},
                        period       => $target_config->{delaytime},
                        url          => $target_config->{url},
                        format       => $target_config->{format},
                        tag          => $target_config->{tag},
                        user         => $target_config->{user},
                        password     => $target_config->{password},
                        proxy        => $target_config->{proxy},
                        ca_cert_dir  => $target_config->{'ca-cert-dir'},
                        ca_cert_file => $target_config->{'ca-cert-file'},
                        ssl_check    => $target_config->{'ssl-check'},
                    );
                last SWITCH;
            }

            die "Invalid type $target_type for target $target_name, aborting";
        }
    }

    die "No targets defined, aborting" unless $self->{targets};

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
            logger    => $logger,
            state     => $self,
            htmldir   => $self->{datadir} . '/html',
            ip        => $www_config->{ip},
            port      => $www_config->{port},
            trust_localhost => $www_config->{'trust-localhost'},
        );
    } else {
        $logger->info("Web interface disabled");
    }

    POE::Component::IKC::Server->spawn(
        ip   => '127.0.0.1',
        port => 3030,
        name  => 'Server'
    ); # more options are available
    POE::Kernel->call(IKC => publish => 'config', ["get"]);
    POE::Kernel->call(IKC => publish => 'target', ["get"]);
    POE::Kernel->call(IKC => publish => 'network', ["send"]);
    POE::Kernel->call(IKC => publish => 'prolog', ["getOptionsInfoByName"]);
}

sub getToken {
    my ($self) = @_;
    return $self->{token};
}

sub getTargets {
    my ($self) = @_;

    return @{$self->{targets}};
}

sub resetToken {
    my ($self) = @_;
    $self->{token} = _computeNewToken();
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

