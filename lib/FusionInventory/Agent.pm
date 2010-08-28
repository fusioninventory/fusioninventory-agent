package FusionInventory::Agent;

use strict;
use warnings;

use Cwd;
use English qw(-no_match_vars);
use File::Path qw(make_path);
use Sys::Hostname;
use XML::Simple;

use FusionInventory::Agent::AccountInfo;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::Network;
use FusionInventory::Agent::Scheduler;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Receiver;
use FusionInventory::Agent::XML::Query::Inventory;
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

    my $self = {};

    my $config = $self->{config} = FusionInventory::Agent::Config->new($params);

    if ($config->{help}) {
        $config->help();
        exit 1;
    }
    if ($config->{version}) {
        print $VERSION_STRING . "\n";
        exit 0;
    }

    my $logger = $self->{logger} = FusionInventory::Logger->new({
        config => $config
    });

    if ( $REAL_USER_ID != 0 ) {
        $logger->info("You should run this program as super-user.");
    }

    if (! -d $config->{basevardir}) {
        make_path($config->{basevardir}, {error => \my $err});
        if (@$err) {
            $logger->error(
                "Failed to create $config->{basevardir} directory"
            );
        }
    }

    if (! -w $config->{basevardir}) {
        $logger->error(
            "Non-writable $config->{basevardir} directory. Either fix it, or " .
            "use --basevardir to point to a R/W directory."
        );
    }

    $logger->debug("base storage directory: $config->{basevardir}");

    if (!-d $config->{'share-dir'}) {
        $logger->error("share-dir doesn't existe $config->{'share-dir'}");
    }

    #my $hostname = Encode::from_to(hostname(), "cp1251", "UTF-8");
    my $hostname;
  

    if ($OSNAME =~ /^MSWin/) {
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
        config => $config
    });
    my $myRootData = $rootStorage->restore();

    if (
        !defined($myRootData->{previousHostname}) ||
        $myRootData->{previousHostname} ne $hostname
    ) {
        my ($year, $month , $day, $hour, $min, $sec) =
            (localtime(time()))[5,4,3,2,1,0];
        $self->{deviceid} = sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
            $hostname, ($year + 1900), ($month + 1), $day, $hour, $min, $sec;

        $myRootData->{previousHostname} = $hostname;
        $myRootData->{deviceid} = $self->{deviceid};
        $rootStorage->save({ data => $myRootData });
    } else {
        $self->{deviceid} = $myRootData->{deviceid}
    }

    $self->{scheduler} = FusionInventory::Agent::Scheduler->new({
        logger => $logger,
        config => $config,
        deviceid => $self->{deviceid}
    });

    my $scheduler = $self->{scheduler};

    if (!$scheduler->numberOfTargets()) {
        $logger->fault(
            "No target defined. Please use --server or --local option."
        );
        exit 1;
    }

    if ($config->{scanhomedirs}) {
        $logger->debug("User directory scanning enabled");
    }

    if ($config->{daemon}) {

        $logger->debug("Daemon mode enabled");

        my $cwd = getcwd();
        eval { require Proc::Daemon; };
        if ($EVAL_ERROR) {
            $logger->fault("Can't load Proc::Daemon. Is the module installed?");
            exit 1;
        }
        Proc::Daemon::Init();
        $logger->debug("Daemon started");
        if ($self->isAgentAlreadyRunning()) {
            $logger->fault("An agent is already runnnig, exiting...");
            exit 1;
        }
        # If we are in dev mode, we want to stay in the source directory to
        # be able to access the 'lib' directory
        chdir $cwd if $config->{devlib};

    }

    # threads and HTTP::Daemon are optional and so this module
    # may fail to load.
    if (eval "use FusionInventory::Agent::Receiver;1;") {
        $self->{receiver} = FusionInventory::Agent::Receiver->new({
                logger => $logger,
                config => $config,
                scheduler => $scheduler,
            });
    } else {
        $logger->debug("Failed to load Receiver module: $EVAL_ERROR");
    }

    $logger->debug("FusionInventory Agent initialised");

    bless $self, $class;

    return $self;
}

sub isAgentAlreadyRunning {
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
        $receiver->setCurrentStatus("waiting") if $receiver;

        while (my $target = $scheduler->getNext()) {

            my $prologresp;
            if ($target->{type} eq 'server') {

                my $network = FusionInventory::Agent::Network->new({
                    logger => $logger,
                    config => $config,
                    target => $target,
                });

                my $prolog = FusionInventory::Agent::XML::Query::Prolog->new({
                    accountinfo => $target->{accountinfo}, #? XXX
                    logger => $logger,
                    config => $config,
                    target => $target,
                    token  => $receiver->getToken()
                });

                # ugly circular reference moved from Prolog::getContent() method
                $target->{accountinfo}->setAccountInfo($prolog);

                # TODO Don't mix settings and temp value
                $prologresp = $network->send({message => $prolog});

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

                $receiver->setCurrentStatus("running task $module") if $receiver;

                my $task = $package->new({
                    config => $config,
                    logger => $logger,
                    target => $target,
                    storage => $storage,
                    prologresp => $prologresp
                });

                if (
                    $config->{daemon}           ||
                    $config->{'daemon-no-fork'} ||
                    $config->{winService}
                ) {
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
                        $logger->debug("[task] end of $module");
                    }
                } else {
                    # standalone mode: run each task directly
                    $logger->debug("[task] executing $module");
                    $task->main();
                    $logger->debug("[task] end of $module");
                }
            }
            $receiver->setCurrentStatus("waiting") if $receiver;

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

1;
