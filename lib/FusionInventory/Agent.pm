package FusionInventory::Agent;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;
use File::Glob;
use IO::Handle;
use POSIX ":sys_wait_h"; # WNOHANG

use FusionInventory::Agent::HTTP::Client::Fusion;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Target::Server;
use FusionInventory::Agent::Task;
use FusionInventory::Agent::Controller;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Hostname;
use FusionInventory::Agent::Message::Outbound;

our $VERSION = '2.3.99';
our $VERSION_STRING = _versionString($VERSION);
our $AGENT_STRING = "FusionInventory-Agent_v$VERSION";

sub _versionString {
    my ($VERSION) = @_;

    my $string = "FusionInventory Agent ($VERSION)";
    if ($VERSION =~ /^\d\.\d\.99/) {
        $string .= " **THIS IS A DEVELOPMENT RELEASE**";
    }

    return $string;
}

sub new {
    my ($class, %params) = @_;

    my $self = {
        status  => 'unknown',
        setup   => $params{setup},
        config  => $params{config},
        logger  => $params{logger} ||
                   FusionInventory::Agent::Logger->new(),
        controllers => [],
        modules     => {},
    };
    bless $self, $class;

    return $self;
}

sub init {
    my ($self, %params) = @_;

    my $logger = $self->{logger};
    my $config = $self->{config};

    $self->{storage} = FusionInventory::Agent::Storage->new(
        logger    => $logger,
        directory => $self->{setup}->{vardir}
    );

    # handle persistent state
    $self->_loadState();

    if (!$self->{deviceid}) {
        $self->{deviceid} = _computeDeviceId();
        $self->_saveState();
    }

    $logger->debug("agent state initialized");
}

sub initModules {
    my ($self, %params) = @_;

    my $logger = $self->{logger};
    my $config = $self->{config};

    $self->{modules} = $self->_loadModules(
        disabled => $config->{'no-module'},
        fork     => $params{fork}
    );

    $logger->debug("agent modules initialized:");
    foreach my $module (keys %{$self->{modules}}) {
        $logger->debug("- $module $self->{modules}->{$module}");
    }

}

sub initControllers {
    my ($self) = @_;

    my $logger = $self->{logger};
    my $config = $self->{config};

    foreach my $url (@{$config->{server}}) {
        my $controller = FusionInventory::Agent::Controller->new(
            logger     => $logger,
            basevardir => $self->{setup}->{vardir},
            url        => $url,
        );
        push @{$self->{controllers}}, $controller;
    }

    $logger->debug("agent controllers initialized:");
    foreach my $controller (@{$self->{controllers}}) {
        $logger->debug("- $controller->{id} ($controller->{url})");
    }
}

sub initHTTPInterface {
    my ($self) = @_;

    my $logger = $self->{logger};
    my $config = $self->{config};

    FusionInventory::Agent::HTTP::Server->require();
    if ($EVAL_ERROR) {
        $logger->error("Failed to load HTTP server: $EVAL_ERROR");
        return;
    }

    $self->{server} = FusionInventory::Agent::HTTP::Server->new(
        logger          => $self->{logger},
        agent           => $self,
        htmldir         => $self->{setup}->{datadir} . '/html',
        ip              => $config->{'httpd-ip'},
        port            => $config->{'httpd-port'},
        trust           => $config->{'httpd-trust'}
    );
    $self->{server}->init();

    $logger->debug("agent HTTP interface initialized");
}

sub initHandlers {
    my ($self, %params) = @_;

    my $logger = $self->{logger};

    my $handler = sub { $self->terminate(@_); exit 0; };
    $SIG{INT}   = $handler;
    $SIG{TERM}  = $handler;

    $logger->debug("agent signal handlers initialized");
}

sub run {
    my ($self) = @_;

    $self->{status} = 'waiting';

    while (1) {
        $self->handleControllers(fork => 1, force => 0);
        $self->{server}->handleRequests() if $self->{server};
        delay(1);
    }
}

sub terminate {
    my ($self, $signal) = @_;

    $self->{logger}->info("Signal SIG$signal received, exiting");
    $self->{task}->abort() if $self->{task};
}

sub handleControllers {
    my ($self, %params) = @_;

    my $time = time();
    foreach my $controller (@{$self->{controllers}}) {
        my $nextContactTime = $controller->getNextRunDate();
        if ($time < $nextContactTime) {
            if (!$params{force}) {
                $self->{logger}->debug(
                    "next contact time for $controller->{id} is %s, skipping",
                    localtime($nextContactTime)
                );
                next;
            }
        }

        eval {
            $self->_handleController(controller => $controller, fork => $params{fork});
        };
        $self->{logger}->error($EVAL_ERROR) if $EVAL_ERROR;

        $controller->resetNextRunDate();
    }
}

sub _handleController {
    my ($self, %params) = @_;

    my $controller = $params{controller};

    # create a single client object for this run
    my $client = FusionInventory::Agent::HTTP::Client::Fusion->new(
        logger       => $self->{logger},
        timeout      => $self->{timeout},
        user         => $self->{config}->{user},
        password     => $self->{config}->{password},
        proxy        => $self->{config}->{proxy},
        ca_cert_file => $self->{config}->{'ca-cert-file'},
        ca_cert_dir  => $self->{config}->{'ca-cert-dir'},
        no_ssl_check => $self->{config}->{'no-ssl-check'},
    );

    my @tasks;

    # get scheduled tasks, using legacy protocol
    $self->{logger}->info("sending prolog request to server $controller->{id}");

    my $prolog = $client->sendXML(
        url     => $controller->getUrl(),
        message => FusionInventory::Agent::Message::Outbound->new(
            query    => 'PROLOG',
            token    => '123456678',
            deviceid => $self->{deviceid},
        )
    );
    die "No answer to prolog request from the server" unless $prolog;
    push @tasks, $prolog->getTasks();

    # get scheduled tasks, using new protocol
    $self->{logger}->info("sending getConfig request to server $controller->{id}");

    my $config = $client->sendJSON(
        url  => $controller->getUrl(),
        args => {
            action    => "getConfig",
            machineid => $self->{deviceid},
            task      => $self->{tasks},
        }
    );
    die "No answer to getConfig request from the server" unless $config;
    my $schedule = $config->{schedule};
    push @tasks, @$schedule;

    # update controller
    my $maxDelay = $prolog->getMaxDelay();
    if ($maxDelay) {
        $controller->setMaxDelay($maxDelay * 3600);
    }

    my $target = FusionInventory::Agent::Target::Server->new(
        url    => $controller->getURL(),
        client => $client
    );

    foreach my $spec (@tasks) {
        eval {
            $self->_handleTask(
                spec   => $spec,
                target => $target,
                client => $client,
                fork   => $params{fork}
            );
        };
        $self->{logger}->error($EVAL_ERROR) if $EVAL_ERROR;
        $self->{status} = 'waiting';
    }
}

sub _handleTask {
    my ($self, %params) = @_;

    my $spec   = $params{spec};
    my $client = $params{client};
    my $target = $params{target};

    $self->{status} = "running task $spec->{task}";

    if ($params{fork}) {
        # run each task in a child process
        if (my $pid = fork()) {
            # parent
            while (waitpid($pid, WNOHANG) == 0) {
                $self->{server}->handleRequests() if $self->{server};
                delay(1);
            }
        } else {
            # child
            die "fork failed: $ERRNO" unless defined $pid;

            $self->{logger}->debug("forking process $PID to handle task $spec->{task}");
            $self->_handleTaskReal(spec => $spec, target => $target, client => $client);
            exit(0);
        }
    } else {
        # run each task directly
        $self->_handleTaskReal(spec => $spec, target => $target, client => $client);
    }
}

sub _handleTaskReal {
    my ($self, %params) = @_;

    my $spec   = $params{spec};
    my $client = $params{client};
    my $target = $params{target};

    my $class = "FusionInventory::Agent::Task::$spec->{task}";

    $class->require();

    my $task = $class->new(
        confdir      => $self->{setup}->{confdir},
        datadir      => $self->{setup}->{datadir},
        logger       => $self->{logger},
        deviceid     => $self->{deviceid},
    );

    my %configuration = $task->getConfiguration(
        client => $client,
        spec   => $spec
    );
    if (!%configuration) {
        $self->{logger}->debug("no $spec->{task} task execution requested");
        return;
    }

    $task->configure(
        tag                => $self->{config}->{tag},
        timeout            => $self->{config}->{'execution-timeout'},
        additional_content => $self->{config}->{'additional-content'},
        scan_homedirs      => $self->{config}->{'scan-homedirs'},
        no_category        => $self->{config}->{'no-category'},
        %configuration
    );

    $self->{logger}->info("running task $spec->{task}");
    $self->{task} = $task;

    $task->run(
        target => $target,
        client => $client
    );

    delete $self->{task};
}

sub getId {
    my ($self) = @_;
    return $self->{deviceid};
}

sub getStatus {
    my ($self) = @_;
    return $self->{status};
}

sub getControllers {
    my ($self) = @_;
    return @{$self->{controllers}};
}

sub getModules {
    my ($self) = @_;
    return %{$self->{modules}};
}

sub _loadModules {
    my ($self, %params) = @_;

    my %modules;
    my %disabled  = map { lc($_) => 1 } @{$params{disabled}};

    # tasks may be located only in agent libdir
    my $directory = $self->{setup}->{libdir};
    $directory =~ s,\\,/,g;
    my $subdirectory = "FusionInventory/Agent/Task";
    # look for all perl modules here
    foreach my $file (File::Glob::glob("$directory/$subdirectory/*.pm")) {
        next unless $file =~ m{($subdirectory/(\S+)\.pm)$};
        my $module = file2module($1);
        my $name = file2module($2);

        next if $disabled{lc($name)};

        my $version;
        if ($params{fork}) {
            # check each task version in a child process
            my ($reader, $writer);
            pipe($reader, $writer);
            $writer->autoflush(1);

            if (my $pid = fork()) {
                # parent
                close $writer;
                $version = <$reader>;
                close $reader;
                waitpid($pid, 0);
            } else {
                # child
                die "fork failed: $ERRNO" unless defined $pid;

                close $reader;
                $version = $self->_getModuleVersion($module);
                print $writer $version if $version;
                close $writer;
                exit(0);
            }
        } else {
            # check each task version directly
            $version = $self->_getModuleVersion($module);
        }

        # no version means non-functionning task
        next unless $version;

        $modules{$name} = $version;
    }

    return \%modules;
}

sub _getModuleVersion {
    my ($self, $module) = @_;

    my $logger = $self->{logger};

    if (!$module->require()) {
        $logger->debug2("module $module does not compile: $@") if $logger;
        return;
    }

    if (!$module->isa('FusionInventory::Agent::Task')) {
        $logger->debug2("module $module is not a task") if $logger;
        return;
    }

    my $version;
    {
        no strict 'refs';  ## no critic
        $version = ${$module . '::VERSION'};
    }

    return $version;
}

sub _loadState {
    my ($self) = @_;

    my $data = $self->{storage}->restore(name => 'FusionInventory-Agent');

    $self->{deviceid} = $data->{deviceid} if $data->{deviceid};
}

sub _saveState {
    my ($self) = @_;

    $self->{storage}->save(
        name => 'FusionInventory-Agent',
        data => {
            deviceid => $self->{deviceid},
        }
    );
}

# compute an unique agent identifier, based on host name and current time
sub _computeDeviceId {
    my $hostname = getHostname();

    my ($year, $month , $day, $hour, $min, $sec) =
        (localtime (time))[5, 4, 3, 2, 1, 0];

    return sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
        $hostname, $year + 1900, $month + 1, $day, $hour, $min, $sec;
}

1;
__END__

=head1 NAME

FusionInventory::Agent - Fusion Inventory agent

=head1 DESCRIPTION

This is the agent object.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<confdir>

the configuration directory.

=item I<datadir>

the read-only data directory.

=item I<vardir>

the read-write data directory.

=item I<options>

the options to use.

=back

=head2 init()

Initialize the agent.

=head2 run()

Run the agent.

=head2 terminate()

Terminate the agent.

=head2 getId()

Get the agent identifier.

=head2 getStatus()

Get the agent status.

=head2 getControllers()

Get the agent controllers.

=head2 getModules()

Get the agent modules, as a list of module / version pairs:

(
    'Foo' => x,
    'Bar' => y,
);

=head1 LICENSE

This software is licensed under the terms of GPLv2+, see LICENSE file for
details.
