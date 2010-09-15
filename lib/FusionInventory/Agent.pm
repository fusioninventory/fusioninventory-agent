package FusionInventory::Agent;

use strict;
use warnings;

use Cwd;
use English qw(-no_match_vars);
use File::Path qw(make_path);
use Sys::Hostname;
use XML::Simple;

use FusionInventory::Agent::Config;
use FusionInventory::Agent::Scheduler;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Target::Local;
use FusionInventory::Agent::Target::Stdout;
use FusionInventory::Agent::Target::Server;
use FusionInventory::Agent::Transmitter;
use FusionInventory::Agent::Receiver;
use FusionInventory::Agent::XML::Query::Prolog;
use FusionInventory::Logger;

our $VERSION = '2.1.2';
our $VERSION_STRING =
    "FusionInventory unified agent for UNIX, Linux and MacOSX ($VERSION)";
our $AGENT_STRING =
    "FusionInventory-Agent_v$VERSION";

$ENV{LC_ALL} = 'C'; # Turn off localised output for commands
$ENV{LANG} = 'C'; # Turn off localised output for commands

# THIS IS AN UGLY WORKAROUND FOR
# http://rt.cpan.org/Ticket/Display.html?id=38067
eval {XMLout("<a>b</a>");};
if ($EVAL_ERROR) {
    no strict 'refs'; ## no critic
    ${*{"XML::SAX::"}{HASH}{'parsers'}} = sub {
        return [ {
            'Features' => {
                'http://xml.org/sax/features/namespaces' => '1'
            },
            'Name' => 'XML::SAX::PurePerl'
        }
        ]
    };
}

# END OF THE UGLY FIX!

sub new {
    my ($class, $params) = @_;

    my $self = {
        status => 'unknown',
        token  => _computeNewToken()
    };
    bless $self, $class;

    my $config = $self->{config} = FusionInventory::Agent::Config->new($params);

    if ($config->{help}) {
        $config->help();
        exit 0;
    }
    if ($config->{version}) {
        print $VERSION_STRING . "\n";
        exit 0;
    }

    my $logger = $self->{logger} = FusionInventory::Logger->new({
        config => $config
    });

    if (!$config->{server} && !$config->{local} && !$config->{stdout}) {
        $logger->fault(
            "No target defined. Use at least one of --server, --local or " .
            "--stdout option"
        );
        exit 1;
    }

    if ($REAL_USER_ID != 0) {
        $logger->info("You should run this program as super-user.");
    }

    if (! -d $config->{basevardir}) {
        make_path($config->{basevardir}, {error => \my $err});
        if (@$err) {
            $logger->fault(
                "Failed to create storage directory $config->{basevardir}."
            );
            exit 1;
        }
    }

    if (! -w $config->{basevardir}) {
        $logger->fault("Non-writable storage directory $config->{basevardir}.");
        exit 1;
    }

    $logger->debug("Storage directory: $config->{basevardir}");

    if (! -d $config->{'share-dir'}) {
        $logger->fault("Non-existing data directory $config->{'share-dir'}.");
        exit 1;
    }

    $logger->debug("Data directory: $config->{'share-dir'}");

    #my $hostname = Encode::from_to(hostname(), "cp1251", "UTF-8");
    my $hostname;
  
    if ($OSNAME eq 'MSWin32') {
        eval {
            require Encode;
            require Win32::API;
            Encode->import();

            my $GetComputerName = Win32::API->new(
                "kernel32", "GetComputerNameExW", ["I", "P", "P"], "N"
            );
            my $lpBuffer = "\x00" x 1024;
            my $N = 1024; #pack ("c4", 160,0,0,0);

            my $return = $GetComputerName->Call(3, $lpBuffer,$N);

            # GetComputerNameExW returns the string in UTF16, we have to change
            # it # to UTF8
            $hostname = encode(
                "UTF-8", substr(decode("UCS-2le", $lpBuffer),0,ord $N)
            );
        };
    } else {
        $hostname = hostname();
    }

    # $storage save/read data in 'basevardir', not in a target directory!
    my $storage = FusionInventory::Agent::Storage->new({
        config => $config
    });
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

    $self->{scheduler} = FusionInventory::Agent::Scheduler->new({
        logger     => $logger,
        lazy       => $config->{lazy},
        wait       => $config->{wait},
        background => $config->{daemon} || $config->{service}
    });

    if ($config->{stdout}) {
        $self->{scheduler}->addTarget(
            FusionInventory::Agent::Target::Stdout->new({
                logger     => $logger,
                deviceid   => $deviceid,
                delaytime  => $config->{delaytime},
                basevardir => $config->{basevardir},
            })
        );
    }

    if ($config->{local}) {
        $self->{scheduler}->addTarget(
            FusionInventory::Agent::Target::Local->new({
                logger     => $logger,
                deviceid   => $deviceid,
                delaytime  => $config->{delaytime},
                basevardir => $config->{basevardir},
                path       => $config->{local},
            })
        );
    }

    if ($config->{server}) {
        foreach my $val (split(/,/, $config->{server})) {
            my $url;
            if ($val !~ /^https?:\/\//) {
                $logger->debug(
                    "no explicit protocol for url $url, assume http as default"
                );
                $url = "http://$val/ocsinventory";
            } else {
                $url = $val;
            }
            $self->{scheduler}->addTarget(
                FusionInventory::Agent::Target::Server->new({
                    logger     => $logger,
                    deviceid   => $deviceid,
                    delaytime  => $config->{delaytime},
                    basevardir => $config->{basevardir},
                    path       => $url,
                })
            );
        }
    }

    if ($config->{scanhomedirs}) {
        $logger->debug("User directory scanning enabled");
    }

    if ($config->{daemon} && !$config->{'no-fork'}) {

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

    if (($config->{daemon} || $config->{service}) && ! $config->{'no-rpc'}) {
        FusionInventory::Agent::Receiver->require();
        if ($EVAL_ERROR) {
            $logger->debug("Failed to load Receiver module: $EVAL_ERROR");
        } else {
            # make sure relevant variables are shared between threads
            threads::shared::share($self->{status});
            threads::shared::share($self->{token});
            foreach my $target ($self->{scheduler}->getTargets()) {
                threads::shared::share($target->{nextRunUpdate});
            }
            $self->{receiver} = FusionInventory::Agent::Receiver->new({
                logger    => $logger,
                scheduler => $self->{scheduler},
                agent     => $self,
                devlib    => $config->{devlib},
                share_dir => $config->{'share-dir'},
                rpc_ip    => $config->{'rpc-ip'},
                rpc_trust_localhost => $config->{'rpc-trust-localhost'},
            });
        }
    }

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

sub main {
    my ($self) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $scheduler = $self->{scheduler};
    my $receiver = $self->{receiver};

    eval {
        $self->{status} = 'waiting';

        while (my $target = $scheduler->getNextTarget()) {

            my $prologresp;
            my $transmitter;
            if ($target->isa('FusionInventory::Agent::Target::Server')) {

                $transmitter = FusionInventory::Agent::Transmitter->new({
                    logger       => $logger,
                    url          => $target->{path},
                    proxy        => $config->{proxy},
                    user         => $config->{user},
                    password     => $config->{password},
                    no_ssl_check => $config->{'no-ssl-check'},
                    ca_cert_file => $config->{'ca-cert-file'},
                    ca_cert_dir  => $config->{'ca-cert-dir'},
                });

                my $prolog = FusionInventory::Agent::XML::Query::Prolog->new({
                    logger => $logger,
                    config => $config,
                    target => $target,
                    token  => $self->{token}
                });

                if ($config->{tag}) {
                    $prolog->setAccountInfo({'TAG', $config->{tag}});
                }

                # TODO Don't mix settings and temp value
                $prologresp = $transmitter->send({message => $prolog});

                if (!$prologresp) {
                    $logger->error("No anwser from the server");
                    $target->setNextRunDate();
                    next;
                }

                # update target
                my $parsedContent = $prologresp->getParsedContent();
                $target->setPrologFreq($parsedContent->{PROLOG_FREQ});
            }

            my $storage = FusionInventory::Agent::Storage->new({
                config => $config,
                logger => $logger,
                target => $target,
            });

            my @tasks = qw/
                Inventory
                OcsDeploy
                WakeOnLan
                SNMPQuery
                NetDiscovery
                Ping
                /;

            foreach my $module (@tasks) {

                next if $config->{'no-'.lc($module)};

                my $package = "FusionInventory::Agent::Task::$module";
                if (!$package->require()) {
                    $logger->info("Module $package is not installed.");
                    next;
                }

                $self->{status} = "running task $module";

                my $task = $package->new({
                    config => $config,
                    logger => $logger,
                    target => $target,
                    storage => $storage,
                    prologresp => $prologresp,
                    transmitter =>  $transmitter
                });

                if ($config->{daemon} || $config->{service}) {
                    # daemon mode: run each task in a childprocess
                    if (my $pid = fork()) {
                        # parent
                        waitpid($pid, 0);
                    } else {
                        # child
                        die "fork failed: $ERRNO" unless defined $pid;

                        $logger->debug(
                            "[task] executing $module in process $PID"
                        );
                        if ($task->can('run')) {
                            $task->run();
                        } else {
                            $logger->info(
                                "[task] $module use deprecated interface"
                            );
                            $task->main();
                        }
                        $logger->debug("[task] end of $module");
                    }
                } else {
                    # standalone mode: run each task directly
                    $logger->debug("[task] executing $module");
                    if ($task->can('run')) {
                        $task->run();
                    } else {
                        # old interface
                        $logger->info(
                            "[task] $module use deprecated interface"
                        );
                        $task->main();
                    }
                    $logger->debug("[task] end of $module");
                }
            }
            $self->{status} = 'waiting';

            if (!$config->{debug}) {
                # In debug mode, I do not clean the FusionInventory-Agent.dump
                # so I can replay the sub task directly
                $storage->remove();
            }
            $target->setNextRunDate();

            sleep(5);
        }
    };
    if ($EVAL_ERROR) {
        $logger->fault($EVAL_ERROR);
        exit 1;
    }
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

sub getStatus {
    my ($self) = @_;
    return $self->{status};
}

1;

__END__

=head1 NAME

FusionInventory::Agent - Fusion Inventory agent

=head1 DESCRIPTION

This is the agent object.

=head1 METHODS

=head2 new()

The constructor. No arguments allowed.

=head2 getToken()

Get the current authentication token.

=head2 resetToken()

Reset the current authentication token to a new random value.

=head2 getStatus()

Get the current agent status.
