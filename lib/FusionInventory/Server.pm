package FusionInventory::Server;

use strict;
use warnings;

use POE;
use POE::Component::IKC::Server;

use Cwd;
use English qw(-no_match_vars);

use FusionInventory::Agent;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::Receiver;
use FusionInventory::Agent::Scheduler;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Target::Local;
use FusionInventory::Agent::Target::Stdout;
use FusionInventory::Agent::Target::Server;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::XML::Query::Prolog;
use FusionInventory::Logger;

sub new {
    my ($class, %params) = @_;

    my $self = {
        confdir => $params{confdir},
        datadir => $params{datadir},
        vardir  => $params{vardir},
        debug   => $params{debug},
        token   => _computeNewToken()
    };
    bless $self, $class;

    my $config = FusionInventory::Agent::Config->new(
        file      => $params{conffile},
        directory => $params{confdir},
    );
    $self->{config} = $config;

    my $logger = FusionInventory::Logger->new(
        %{$config->getBlock('logger')},
        backends => [ $config->getValues('logger.backends') ],
        debug    => $self->{debug}
    );
    $self->{logger} = $logger;

    if ($REAL_USER_ID != 0) {
        $logger->info("You should run this program as super-user.");
    }

    $logger->debug("Configuration directory: $self->{confdir}");
    $logger->debug("Data directory: $self->{datadir}");
    $logger->debug("Storage directory: $self->{vardir}");

    my $hostname = getHostname();

    my $storage = FusionInventory::Agent::Storage->new(
        logger    => $logger,
        directory => $self->{vardir},
    );
    my $data = $storage->restore();

    if (
        !defined($data->{previousHostname}) ||
        $data->{previousHostname} ne $hostname
    ) {
        my ($year, $month , $day, $hour, $min, $sec) =
            (localtime(time()))[5,4,3,2,1,0];
        $data->{deviceid} = sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
            $hostname, ($year + 1900), ($month + 1), $day, $hour, $min, $sec;
        $data->{previousHostname} = $hostname;
        $storage->save({ data => $data });
    }
    $self->{deviceid} = $data->{deviceid};


    my @targets;
    foreach my $target_name ($config->getValues('global.targets')) {
        my $target_config = $config->getBlock($target_name);
        die "No configuration section for target $target_name, aborting"
            unless keys %$target_config;

        my $target_type = $target_config->{type}
            or die "No type for target $target_name, aborting";

        SWITCH: {
            if ($target_type eq 'stdout') {
                push
                    @targets,
                    FusionInventory::Agent::Target::Stdout->new(
                        logger     => $logger,
                        maxOffset  => $config->{delaytime},
                        basevardir => $self->{vardir},
                        format     => $target_config->{format}
                    );
                last SWITCH;
            }

            if ($target_type eq 'local') {
                push
                    @targets,
                    FusionInventory::Agent::Target::Local->new(
                        logger     => $logger,
                        maxOffset  => $config->{delaytime},
                        basevardir => $self->{vardir},
                        path       => $target_config->{path},
                        deviceid   => $self->{deviceid},
                        format     => $target_config->{format}
                    );
                last SWITCH;
            }

            if ($target_type eq 'server') {
                push
                    @targets,
                    FusionInventory::Agent::Target::Server->new(
                        logger     => $logger,
                        maxOffset  => $config->{delaytime},
                        basevardir => $self->{vardir},
                        url        => $target_config->{url},
                        deviceid   => $self->{deviceid},
                        format     => $target_config->{format}
                    );
                last SWITCH;
            }

            die "Invalid type $target_type for target $target_name, aborting";
        }
    }

    die "no targets defined, aborting" unless @targets;

    $self->{scheduler} = FusionInventory::Agent::Scheduler->new(
        logger => $logger,
    );
    $self->{scheduler}->addTarget($_) foreach @targets;

    if ($params{fork}) {

        $logger->debug("Daemon mode enabled");

        my $cwd = getcwd();
        Proc::Daemon->require();
        if ($EVAL_ERROR) {
            $logger->fault("Can't load Proc::Daemon. Is the module installed?");
            exit 1;
        }
        Proc::Daemon::Init();
        $logger->debug("Daemon started");
        if ($self->_isAgentAlreadyRunning()) {
            $logger->fault("An agent is already runnnig, exiting...");
            exit 1;
        }
        # If we are in dev mode, we want to stay in the source directory to
        # be able to access the 'lib' directory
        chdir $cwd if $config->{devlib};

    }

    if (!$config->{'no-www'}) {
        FusionInventory::Agent::Receiver->require();
        if ($EVAL_ERROR) {
            $logger->debug("Failed to load Receiver module: $EVAL_ERROR");
        } else {

            $self->{receiver} = FusionInventory::Agent::Receiver->new(
                logger    => $logger,
                scheduler => $self->{scheduler},
                agent     => $self,
                htmldir   => $self->{datadir} . '/html',
                ip        => $config->{'www-ip'},
                port      => $config->{'www-port'},
                trust_localhost => $config->{'www-trust-localhost'},
            );
        }
    }

    POE::Component::IKC::Server->spawn(
        ip => 127.0.0.1,
        port=>3030,
        name=>'Server'
	); # more options are available
    POE::Kernel->call(IKC => publish => 'config', ["get"]);
    POE::Kernel->call(IKC => publish => 'target', ["get"]);
    POE::Kernel->call(IKC => publish => 'network', ["send"]);
#    POE::Kernel->call(IKC => publish => 'prolog', ["getOptionsInfoByName"]);


    $logger->debug("FusionInventory Agent initialised");

    return $self;
}

sub _isAgentAlreadyRunning {
    my ($self) = @_;

    # TODO add a workaround if Proc::PID::File is not installed
    eval {
        require Proc::PID::File;
        return Proc::PID::File->running();
    };
    $self->{logger}->debug(
        'Proc::PID::File unavalaible, unable to check for running agent'
    ) if $EVAL_ERROR;

    return 0;
}

sub run {
    my ($self) = @_;

    my $config = $self->{config};
    my $scheduler = $self->{scheduler};

    $config->createSession();

    foreach my $target (@{$scheduler->{targets}}) {
        # Create the POE session
        $target->createSession();
    }

    POE::Kernel->run();

    exit;
}

sub getToken {
    my ($self) = @_;
    return $self->{token};
}

sub resetToken {
    my ($self) = @_;
    $self->{token} = _computeNewToken();
}

sub _computeNewToken {
    my @chars = ('A'..'Z');
    return join('', map { $chars[rand @chars] } 1..8);
}

1;

__END__

=head1 NAME

FusionInventory::Server - Fusion Inventory server

=head1 DESCRIPTION

This is the agent object.

=head1 METHODS

=head2 new()

The constructor. No arguments allowed.

=head2 run()

Run the agent.

=head2 getToken()

Get the current authentication token.

=head2 resetToken()

Reset the current authentication token to a new random value.

