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

our $VERSION = '2.1_rc2';
our $VERSION_STRING =
"FusionInventory unified agent for UNIX, Linux and MacOSX ($VERSION)";
our $AGENT_STRING =
"FusionInventory-Agent_v$VERSION";

$ENV{LC_ALL} = 'C'; # Turn off localised output for commands
$ENV{LANG} = 'C'; # Turn off localised output for commands

#use Sys::Hostname;
use FusionInventory::Logger;
use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Agent::XML::Query::Prolog;

use FusionInventory::Agent::Network;
#use FusionInventory::Agent::Task::Inventory;
use FusionInventory::Agent::AccountInfo;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::RPC;
use FusionInventory::Agent::TargetsList;
use FusionInventory::Agent::JobEngine;

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
        $logger->fault(
            "No target defined. Please use --server or --local option."
        );
        exit 1;
    }

    $self->{jobEngine} = new FusionInventory::Agent::JobEngine({

            logger => $logger,
            config => $config,

        });
    my $jobFactory = $self->{jobFactory};

    if ($config->{'scan-homedirs'}) {
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
    my $targetsList = $self->{targetsList};
    my $rpc = $self->{rpc};
    my $jobEngine = $self->{jobEngine};
    $rpc->setCurrentStatus("waiting");

#####################################
################ MAIN ###############
#####################################


#######################################################
#######################################################

    while (my $target = $targetsList->getNext()) {

        my $exitcode = 0;
        my $wait;

        my $network;
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
                        token  => $rpc->getToken()
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

                $target->setCurrentDeviceID ($self->{deviceid});
            }

            my $storage = FusionInventory::Agent::Storage->new({
                    config => $config,
                    logger => $logger,
                    target => $target,
                });



                my @modulesToDo = qw/
                Inventory
                OcsDeploy
                WakeOnLan
                SNMPQuery
                NetDiscovery
                Ping
                /;

        while (@modulesToDo && $jobEngine->beat()) {
            next if $jobEngine->isATaskRunning();
                #
            my $module = shift @modulesToDo;
            print "starting: $module\n";
            $jobEngine->startTask({
                    module => $module,
                    network => $network,
                    target => $target,
                });
            print "Ok\n";
            $rpc->setCurrentStatus("running task $module");
                #
        }
        $rpc->setCurrentStatus("waiting");
#=======
#                my $package = "FusionInventory::Agent::Task::$module";
#                if (!$package->require()) {
#                    $logger->info("Module $package is not installed.");
#                    next;
#                }
#
#                $rpc->setCurrentStatus("running task $module");
#
#                my $task = $package->new({
#                        config => $config,
#                        logger => $logger,
#                        target => $target,
#                        storage => $storage,
#                        prologresp => $prologresp
#                    });
#
#                if (
#                    $config->{daemon}           ||
#                    $config->{'daemon-no-fork'} ||
#                    $config->{winService}
#                ) {
#                    # daemon mode: run each task in a childprocess
#                    if (my $pid = fork()) {
#                        # parent
#                        waitpid($pid, 0);
#                    } else {
#                        # child
#                        die "fork failed: $ERRNO" unless defined $pid;
#
#                        $logger->debug(
#                            "[task] executing $module in process $PID"
#                        );
#                        $task->main();
#                        $logger->debug("[task] end of $module");
#                    }
#                } else {
#                    # standalone mode: run each task directly
#                    $logger->debug("[task] executing $module");
#                    $task->main();
#                    $logger->debug("[task] end of $module");
#                }
#            }
#            $rpc->setCurrentStatus("waiting");
#>>>>>>> guillomovitch/master

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
