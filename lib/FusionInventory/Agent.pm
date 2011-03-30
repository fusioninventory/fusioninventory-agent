package FusionInventory::Agent;

use strict;
use warnings;

use Cwd;
use English qw(-no_match_vars);
use Sys::Hostname;
use UNIVERSAL::require;

use FusionInventory::Agent::Config;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Scheduler;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Task;
use FusionInventory::Agent::Target::Local;
use FusionInventory::Agent::Target::Server;
use FusionInventory::Agent::Target::Stdout;
use FusionInventory::Agent::Transmitter;
use FusionInventory::Agent::XML::Query::Prolog;

our $VERSION = '2.2.0';
our $VERSION_STRING = 
    "FusionInventory unified agent for UNIX, Linux and MacOSX ($VERSION)";
our $AGENT_STRING =
    "FusionInventory-Agent_v$VERSION";

sub new {
    my ($class, $params) = @_;

    my $self = {
        status  => 'unknown',
        confdir => $params->{confdir},
        datadir => $params->{datadir},
        vardir  => $params->{vardir},
        token   => _computeNewToken()
    };
    bless $self, $class;

    my $config = FusionInventory::Agent::Config->new($params);
    $self->{config} = $config;

    my $logger = FusionInventory::Agent::Logger->new({
        config   => $config,
        backends => $config->{logger},
        debug    => $config->{debug}
    });
    $self->{logger} = $logger;

    if ( $REAL_USER_ID != 0 ) {
        $logger->info("You should run this program as super-user.");
    }

    $logger->debug("Configuration directory: $self->{confdir}");
    $logger->debug("Data directory: $self->{datadir}");
    $logger->debug("Storage directory: $self->{vardir}");

    #my $hostname = Encode::from_to(hostname(), "cp1251", "UTF-8");
    my $hostname;
  

    if ($OSNAME eq 'MSWin32') {
        eval '
use Encode;
use Win32::API;

	my $GetComputerName = new Win32::API("kernel32", "GetComputerNameExW", ["I", "P", "P"],
"N");
my $lpBuffer = "\x00" x 1024;
my $N=1024;#pack ("c4", 160,0,0,0);

my $return = $GetComputerName->Call(3, $lpBuffer,$N);

# GetComputerNameExW returns the string in UTF16, we have to change it
# to UTF8
$hostname = encode("UTF-8", substr(decode("UCS-2le", $lpBuffer),0,ord $N));';
    } else {
        $hostname = hostname();
    }

    # $rootStorage save/read data in 'basevardir', not in a target directory!
    my $rootStorage = FusionInventory::Agent::Storage->new({
        logger    => $logger,
        directory => $self->{vardir}
    });
    my $myRootData = $rootStorage->restore();

    if (
        !defined($myRootData->{previousHostname}) ||
        $myRootData->{previousHostname} ne $hostname
    ) {
        my ($YEAR, $MONTH , $DAY, $HOUR, $MIN, $SEC) = (localtime
            (time))[5,4,3,2,1,0];
        $self->{deviceid} =sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
        $hostname, ($YEAR+1900), ($MONTH+1), $DAY, $HOUR, $MIN, $SEC;

        $myRootData->{previousHostname} = $hostname;
        $myRootData->{deviceid} = $self->{deviceid};
        $rootStorage->save({ data => $myRootData });
    } else {
        $self->{deviceid} = $myRootData->{deviceid}
    }

    $self->{scheduler} = FusionInventory::Agent::Scheduler->new({
        logger     => $logger,
        lazy       => $config->{lazy},
        wait       => $config->{wait},
        background => $config->{server} || $config->{service}
    });
    my $scheduler = $self->{scheduler};

    if ($config->{stdout}) {
        $scheduler->addTarget(
            FusionInventory::Agent::Target::Stdout->new({
                logger     => $logger,
                deviceid   => $self->{deviceid},
                delaytime  => $config->{delaytime},
                basevardir => $self->{vardir},
            })
        );
    }

    if ($config->{local}) {
        $scheduler->addTarget(
            FusionInventory::Agent::Target::Local->new({
                logger     => $logger,
                deviceid   => $self->{deviceid},
                delaytime  => $config->{delaytime},
                basevardir => $self->{vardir},
                path       => $config->{local},
                html       => $config->{html},
            })
        );
    }

    if ($config->{server}) {
        foreach my $url (@{$config->{server}}) {
            $scheduler->addTarget(
                FusionInventory::Agent::Target::Server->new({
                    logger     => $logger,
                    deviceid   => $self->{deviceid},
                    delaytime  => $config->{delaytime},
                    basevardir => $self->{vardir},
                    url        => $url,
                    tag        => $config->{tag},
                })
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

        my $cwd = getcwd();
        eval { require Proc::Daemon; };
        if ($EVAL_ERROR) {
            print "Can't load Proc::Daemon. Is the module installed?";
            exit 1;
        }
        Proc::Daemon::Init();
        $logger->debug("Daemon started");
        if (isAgentAlreadyRunning({ logger => $logger })) {
            $logger->debug("An agent is already runnnig, exiting...");
            exit 1;
        }
        # If we are in dev mode, we want to stay in the source directory to
        # be able to access the 'lib' directory
        chdir $cwd if $config->{devlib};

    }

    if (($config->{daemon} || $config->{service}) && !$config->{'no-httpd'}) {
        FusionInventory::Agent::HTTPD->require();
        if ($EVAL_ERROR) {
            $logger->debug("Failed to load HTTPD module: $EVAL_ERROR");
        } else {
            # make sure relevant variables are shared between threads
            threads::shared::share($self->{status});
            threads::shared::share($self->{token});

            FusionInventory::Agent::HTTPD->new({
                logger          => $logger,
                scheduler       => $scheduler,
                agent           => $self,
                htmldir         => $self->{datadir} . '/html',
                ip              => $config->{'httpd-ip'},
                port            => $config->{'httpd-port'},
                trust_localhost => $config->{'httpd-trust-localhost'},
            });
        }
    }

    $logger->debug("FusionInventory Agent initialised");

    return $self;
}

sub isAgentAlreadyRunning {
    my $params = shift;
    my $logger = $params->{logger};
    # TODO add a workaround if Proc::PID::File is not installed
    eval { require Proc::PID::File; };
    if(!$EVAL_ERROR) {
        $logger->debug('Proc::PID::File avalaible, checking for pid file');
        if (Proc::PID::File->running()) {
            $logger->debug('parent process already exists');
            return 1;
        }
    }

    return 0;
}

sub main {
    my ($self) = @_;

# Load setting from the config file
    my $config = $self->{config};
    my $logger = $self->{logger};
    my $scheduler = $self->{scheduler};
    $self->{status} = 'waiting';

    eval {
        while (my $target = $scheduler->getNextTarget()) {

            my $prologresp;
            my $transmitter;
            if ($target->isa('FusionInventory::Agent::Target::Server')) {

                $transmitter = FusionInventory::Agent::Transmitter->new({
                    logger       => $logger,
                    user         => $self->{config}->{user},
                    password     => $self->{config}->{password},
                    proxy        => $self->{config}->{proxy},
                    ca_cert_file => $self->{config}->{'ca-cert-file'},
                    ca_cert_dir  => $self->{config}->{'ca-cert-dir'},
                    no_ssl_check => $self->{config}->{'no-ssl-check'},
                });

                my $prolog = FusionInventory::Agent::XML::Query::Prolog->new({
                    logger          => $logger,
                    token           => $self->{token},
                    deviceid        => $self->{target}->{deviceid},
                    currentDeviceid => $self->{target}->{currentDeviceid},
                });

                # Add target ACCOUNTINFO values to the prolog
                $prolog->setAccountInfo($target->getAccountInfo());

                # TODO Don't mix settings and temp value
                $prologresp = $transmitter->send({
                    url     => $self->{target}->getUrl(),
                    message => $prolog
                });

                if (!$prologresp) {
                    $logger->error("No anwser from the server");
                    $target->setNextRunDate();
                    next;
                }

                # update target
                my $parsedContent = $prologresp->getParsedContent();
                $target->setPrologFreq($parsedContent->{PROLOG_FREQ});
                $target->setCurrentDeviceID ($self->{deviceid});
            }

            my @tasks = qw/
                OcsDeploy
                Inventory
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
                    config      => $config,
                    confdir     => $self->{confdir},
                    datadir     => $self->{datadir},
                    logger      => $logger,
                    target      => $target,
                    prologresp  => $prologresp,
                    transmitter => $transmitter,
                    deviceid    => $self->{deviceid}
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
                        $task->main();
                    }
                } else {
                    # standalone mode: run each task directly
                    $logger->debug("[task] executing $module");
                    $task->main();
                }
            }

            $self->{status} = 'waiting';

            $target->setNextRunDate();
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
