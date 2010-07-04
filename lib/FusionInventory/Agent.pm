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
use FusionInventory::Agent::TargetsList;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::RPC;
use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Agent::XML::Query::Prolog;
use FusionInventory::Logger;

# reap child processes automatically
$SIG{CHLD} = 'IGNORE';

our $VERSION = '2.1beta1';
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

    # This is a hack to add the perl binary directory
    # in the $PATH env.
    # This is useful for the Windows installer.
    # You probably don't need this feature
    if ($config->{'perl-bin-dir-in-path'}) {
        if ($EXECUTABLE_NAME =~ /(^.*(\\|\/))/) {
            $ENV{PATH} .= $Config::Config{path_sep}.$1;
        } else {
            $logger->error(
                "Failed to parse $EXECUTABLE_NAME to get the directory for " .
                "--perl-bin-dir-in-path"
            );
        }
    }
    my $hostname = hostname();

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

    $self->{targetsList} = FusionInventory::Agent::TargetsList->new({
        logger => $logger,
        config => $config,
        deviceid => $self->{deviceid}
    });
    my $targetsList = $self->{targetsList};

    if (!$targetsList->numberOfTargets()) {
        $logger->fault("No target defined. Please use ".
            "--server=SERVER or --local=/directory");
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
        }
        Proc::Daemon::Init();
        $logger->debug("Daemon started");
        if (isAgentAlreadyRunning({ logger => $logger })) {
            $logger->fault("An agent is already runnnig, exiting...");
        }
        # If we are in dev mode, we want to stay in the source directory to
        # be able to access the 'lib' directory
        chdir $cwd if $config->{devlib};

    }
    $self->{rpc} = FusionInventory::Agent::RPC->new({
        logger      => $logger,
        config      => $config,
        targetsList => $targetsList,
    });

    $logger->debug("FusionInventory Agent initialised");

    bless $self, $class;

    return $self;
}

sub isAgentAlreadyRunning {
    my $params = shift;
    my $logger = $params->{logger};

    # TODO add a workaround if Proc::PID::File is not installed
    eval {
        require Proc::PID::File;
        $logger->debug('Proc::PID::File avalaible, checking for pid file');
        if (Proc::PID::File->running()) {
            $logger->debug('parent process already exists');
            return 1;
        }
    };

    return 0;
}

sub main {
    my ($self) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $targetsList = $self->{targetsList};
    my $rpc = $self->{rpc};
    $rpc->setCurrentStatus("waiting");

    while (my $target = $targetsList->getNext()) {

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
                rpc => $rpc,
                target => $target
            });

            # TODO Don't mix settings and temp value
            $prologresp = $network->send({message => $prolog});

            if (!$prologresp) {
                $logger->error("No anwser from the server");
                $target->setNextRunDate();
                next;
            }

            $target->setCurrentDeviceID ($self->{deviceid});
        }


        my $storage = FusionInventory::Agent::Storage->new({
            config => $config,
            logger => $logger,
            target => $target,
        });
        $storage->save({
            data => {
                config => $config,
                target => $target,
                #logger => $logger, # XXX Needed?
                prologresp => $prologresp
            }
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

            # launch task
            if (my $pid = fork()) {
                # parent
                $rpc->setCurrentStatus("running task $module");
            } else {
               die "fork failed: $ERRNO" unless defined $pid;
               # child
                $logger->debug("[task] executing $module in process $PID");

                my $task = $package->new({
                    config => $config,
                    logger => $logger,
                    target => $target,
                    storage => $storage,
                    prologresp => $prologresp
                });
                $task->main();

                $logger->debug("[task] end of $module");
                exit 0;
            }

        }
        $rpc->setCurrentStatus("waiting");

        if (!$config->{debug}) {
            # In debug mode, I do not clean the FusionInventory-Agent.dump
            # so I can replay the sub task directly
            $storage->remove();
        }
        $target->setNextRunDate();

        sleep(5);
    }
}

1;
