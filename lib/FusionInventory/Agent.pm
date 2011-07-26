package FusionInventory::Agent;

use strict;
use warnings;

use Cwd;
use English qw(-no_match_vars);
use Sys::Hostname;
use UNIVERSAL::require;

use FusionInventory::Agent::Config;
use FusionInventory::Agent::HTTP::Client::OCS;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Scheduler;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Task;
use FusionInventory::Agent::Target::Local;
use FusionInventory::Agent::Target::Server;
use FusionInventory::Agent::Target::Stdout;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::XML::Query::Prolog;

our $VERSION = '2.2.0';
our $VERSION_STRING = 
    "FusionInventory unified agent for UNIX, Linux and MacOSX ($VERSION)";
our $AGENT_STRING =
    "FusionInventory-Agent_v$VERSION";

sub new {
    my ($class, %params) = @_;

    my $self = {
        status  => 'unknown',
        confdir => $params{confdir},
        datadir => $params{datadir},
        vardir  => $params{vardir},
    };
    bless $self, $class;

    my $config = FusionInventory::Agent::Config->new(
        confdir => $params{confdir},
        options => $params{options},
    );
    $self->{config} = $config;

    my $logger = FusionInventory::Agent::Logger->new(
        config   => $config,
        backends => $config->{logger},
        debug    => $config->{debug}
    );
    $self->{logger} = $logger;

    if ( $REAL_USER_ID != 0 ) {
        $logger->info("You should run this program as super-user.");
    }

    $logger->debug("Configuration directory: $self->{confdir}");
    $logger->debug("Data directory: $self->{datadir}");
    $logger->debug("Storage directory: $self->{vardir}");

    $self->{storage} = FusionInventory::Agent::Storage->new(
        logger    => $logger,
        directory => $self->{vardir}
    );

    # handle persistent state
    $self->_loadState() if $self->{storage}->has();

    $self->{deviceid} = _computeDeviceId() if !$self->{deviceid};
    $self->{token}    = _computeToken()    if !$self->{token};

    $self->_saveState();

    $self->{scheduler} = FusionInventory::Agent::Scheduler->new(
        logger     => $logger,
        lazy       => $config->{lazy},
        wait       => $config->{wait},
        background => $config->{daemon} || $config->{service}
    );
    my $scheduler = $self->{scheduler};

    # create target list
    if ($config->{stdout}) {
        $scheduler->addTarget(
            FusionInventory::Agent::Target::Stdout->new(
                logger     => $logger,
                deviceid   => $self->{deviceid},
                delaytime  => $config->{delaytime},
                basevardir => $self->{vardir},
            )
        );
    }

    if ($config->{local}) {
        $scheduler->addTarget(
            FusionInventory::Agent::Target::Local->new(
                logger     => $logger,
                deviceid   => $self->{deviceid},
                delaytime  => $config->{delaytime},
                basevardir => $self->{vardir},
                path       => $config->{local},
                html       => $config->{html},
            )
        );
    }

    if ($config->{server}) {
        foreach my $url (@{$config->{server}}) {
            $scheduler->addTarget(
                FusionInventory::Agent::Target::Server->new(
                    logger     => $logger,
                    deviceid   => $self->{deviceid},
                    delaytime  => $config->{delaytime},
                    basevardir => $self->{vardir},
                    url        => $url,
                    tag        => $config->{tag},
                )
            );
        }
    }

    if (!$scheduler->getTargets()) {
        $logger->error("No target defined. Please use ".
            "--server=SERVER or --local=/directory");
        exit 1;
    }

    if ($config->{daemon} && !$config->{'no-fork'}) {

        $logger->debug("Time to call Proc::Daemon");

        Proc::Daemon->require();
        if ($EVAL_ERROR) {
            $logger->error("Can't load Proc::Daemon. Is the module installed?");
            exit 1;
        }
        Proc::Daemon::Init();
        $logger->debug("Daemon started");
        if ($self->_isAlreadyRunning()) {
            $logger->debug("An agent is already runnnig, exiting...");
            exit 1;
        }
    }

    if (($config->{daemon} || $config->{service}) && !$config->{'no-httpd'}) {
        FusionInventory::Agent::HTTP::Server->require();
        if ($EVAL_ERROR) {
            $logger->debug("Failed to load HTTP server: $EVAL_ERROR");
        } else {
            # make sure relevant variables are shared between threads
            threads::shared::share($self->{status});
            threads::shared::share($self->{token});

            FusionInventory::Agent::HTTP::Server->new(
                logger          => $logger,
                scheduler       => $scheduler,
                agent           => $self,
                htmldir         => $self->{datadir} . '/html',
                ip              => $config->{'httpd-ip'},
                port            => $config->{'httpd-port'},
                trust_localhost => $config->{'httpd-trust-localhost'},
            );
        }
    }

    $logger->debug("FusionInventory Agent initialised");

    return $self;
}

sub _isAlreadyRunning {
    my ($self) = @_;

    eval {
        require Proc::PID::File;
        return Proc::PID::File->running();
    };

    if ($EVAL_ERROR) {
        $self->{logger}->debug(
            'Proc::PID::File unavailable, unable to check for running agent'
        );
    }

    return 0;
}

sub _getHostname {

    # use hostname directly under Unix
    return hostname() if $OSNAME ne 'MSWin32';

    # otherwise, use Win32 API
    eval {
        require Encode;
        require Win32::API;
        Encode->import();

        my $getComputerName = Win32::API->new(
            "kernel32", "GetComputerNameExW", ["I", "P", "P"], "N"
        );
        my $lpBuffer = "\x00" x 1024;
        my $N = 1024; #pack ("c4", 160,0,0,0);

        $getComputerName->Call(3, $lpBuffer, $N);

        # GetComputerNameExW returns the string in UTF16, we have to change
        # it to UTF8
        return encode(
            "UTF-8", substr(decode("UCS-2le", $lpBuffer), 0, ord $N)
        );
    };
}

sub _loadState {
    my ($self) = @_;

    my $data = $self->{storage}->restore();

    $self->{token}    = $data->{token}    if $data->{token};
    $self->{deviceid} = $data->{deviceid} if $data->{deviceid};
}

sub _saveState {
    my ($self) = @_;

    $self->{storage}->save(
        data => {
            token    => $self->{token},
            deviceid => $self->{deviceid},
        }
    );
}

sub run {
    my ($self) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $scheduler = $self->{scheduler};
    $self->{status} = 'waiting';

    my $status = 0;

    while (my $target = $scheduler->getNextTarget()) {
        eval {
            my $prologresp;
            my $client;
            if ($target->isa('FusionInventory::Agent::Target::Server')) {

                $client = FusionInventory::Agent::HTTP::Client::OCS->new(
                    logger       => $logger,
                    user         => $self->{config}->{user},
                    password     => $self->{config}->{password},
                    proxy        => $self->{config}->{proxy},
                    ca_cert_file => $self->{config}->{'ca-cert-file'},
                    ca_cert_dir  => $self->{config}->{'ca-cert-dir'},
                    no_ssl_check => $self->{config}->{'no-ssl-check'},
                );

                my $prolog = FusionInventory::Agent::XML::Query::Prolog->new(
                    token    => $self->{token},
                    deviceid => $self->{deviceid},
                );

                # Add target ACCOUNTINFO values to the prolog
                #$prolog->setAccountInfo($target->getAccountInfo());

                $prologresp = $client->send(
                    url     => $target->getUrl(),
                    message => $prolog
                );

                if (!$prologresp) {
                    $logger->error("No anwser from the server");
                    $target->resetNextRunDate();
                    next;
                }

                # update target
                my $content = $prologresp->getContent();
                $target->setMaxDelay($content->{PROLOG_FREQ} * 3600);
            }

            my @tasks = qw/
                OcsDeploy
                Inventory
                WakeOnLan
                SNMPQuery
                NetDiscovery
            /;

            foreach my $module (@tasks) {

                next if $config->{'no-'.lc($module)};

                my $package = "FusionInventory::Agent::Task::$module";
                if (!$package->require()) {
                    $logger->info("task $module is not available");
                    next;
                }
                if (!$package->isa('FusionInventory::Agent::Task')) {
                    $logger->info(
                        "task $module is not compatible with this agent"
                    );
                    next;
                }

                $self->{status} = "running task $module";

                my $task;
                eval {
                    $task = $package->new(
                        config      => $config,
                        confdir     => $self->{confdir},
                        datadir     => $self->{datadir},
                        logger      => $logger,
                        target      => $target,
                        prologresp  => $prologresp,
                        client      => $client,
                        deviceid    => $self->{deviceid}
                    );
                };
                if (!$task) {
                    $logger->info("task $module can't be initialized: ".$EVAL_ERROR);
                    next;
                }

                if ($config->{daemon} || $config->{service}) {
                    # daemon mode: run each task in a child process
                    if (my $pid = fork()) {
                        # parent
                        waitpid($pid, 0);
                    } else {
                        # child
                        die "fork failed: $ERRNO" unless defined $pid;

                        $logger->debug(
                            "[task] executing $module in process $PID"
                        );
                        $task->run();
                    }
                } else {
                    # standalone mode: run each task directly
                    $logger->debug("[task] executing $module");
                    $task->run();
                }
            }

            $self->{status} = 'waiting';

            $target->setNextRunDate();
        };
        if ($EVAL_ERROR) {
            $logger->fault($EVAL_ERROR);
            $status++;
        }
    }

    exit $status;
}

sub getToken {
    my ($self) = @_;
    return $self->{token};
}

sub resetToken {
    my ($self) = @_;
    $self->{token} = _computeToken();
}

# compute a random token
sub _computeToken {
    my @chars = ('A'..'Z');
    return join('', map { $chars[rand @chars] } 1..8);
}

# compute an unique agent identifier, based on host name and current time
sub _computeDeviceId {
    my $hostname = _getHostname();

    my ($year, $month , $day, $hour, $min, $sec) =
        (localtime (time))[5, 4, 3, 2, 1, 0];

    return sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
        $hostname, $year + 1900, $month + 1, $day, $hour, $min, $sec;
}

sub getStatus {
    my ($self) = @_;
    return $self->{status};
}

sub getAvailableTasks {
    my ($self) = @_;

    my %tasks;

    # tasks may be dispatched in every directory referenced in @INC
    foreach my $directory (@INC) {
        # look for a suitable subdirectory
        my $subdirectory = "FusionInventory/Agent/Task";
        next unless -d "$directory/$subdirectory";

        # look for all perl modules here
        foreach my $file (glob("$directory/$subdirectory/*.pm")) {
            next unless $file =~ m{($subdirectory/\S+\.pm)$};
            my $module = file2module($1);

            # check module
            # todo: use a child process when running as a server to save memory
            next unless $module->require();
            next unless $module->isa('FusionInventory::Agent::Task');

            # only the first seen will be loaded
            next if defined $tasks{$module};
            
            # retrieve version
            my $version;
            {
                no strict 'refs';  ## no critic
                $version = ${$module . '::VERSION'};
            }

            $tasks{$module} = $version;
        }
    }

    return %tasks;
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

=head2 run()

Run the agent.

=head2 getToken()

Get the current authentication token.

=head2 resetToken()

Set the current authentication token to a random value.

=head2 getStatus()

Get the current agent status.

=head2 getAvailableTasks()

Get all available tasks, as a list of module / version pairs:

%tasks = (
    'FusionInventory::Agent::Task::Foo' => x,
    'FusionInventory::Agent::Task::Bar' => y,
);
