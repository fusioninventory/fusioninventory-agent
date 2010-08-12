package FusionInventory::Agent::JobEngine;

use strict;
use warnings;

use IPC::Run3;
use IO::Select;
use POSIX ":sys_wait_h";

use Data::Dumper; # to pass mod parameters

use English;

use POE;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{config} = $params->{config};
    $self->{logger} = $params->{logger};

    $self->{jobs} = [];

    # We can't have more than on task at the same time
    $self->{runningTask} = undef;

    bless $self;

print "Creation de JobEngine\n";

    POE::Session->create(
        inline_states => {
            _start => sub {
                $_[KERNEL]->alias_set("jobEngine");
            },
#            start => $start,
            start => sub {
                $self->processTarget({ target => $_[ARG0] })
            }

            },
        );



}


sub processTarget {
    my ($self, $params) = @_;

    my $logger = $self->{logger};
    my $config = $self->{config};
    my $target = $params->{target};

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
                #token  => $rpc->getToken()
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
    $storage->save({
            data => {
                config => $config,
                target => $target,
                #logger => $logger, # XXX Needed?
                prologresp => $prologresp
            }
        });

    my @modulesToDo = qw/
    Inventory
    OcsDeploy
    WakeOnLan
    SNMPQuery
    NetDiscovery
    Ping
    /;

    while (@modulesToDo) {
#        next if $jobEngine->isATaskRunning();
        #
        my $module = shift @modulesToDo;
        print "starting: $module\n";
        $self->startTask({
                module => $module,
                network => $network,
                target => $target,
            });
        print "Ok\n";
        #$rpc->setCurrentStatus("running task $module");
        #
    }
    #$rpc->setCurrentStatus("waiting");
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

}

sub startTask {
use Data::Dumper;
#print Dumper(\@_);

}

1;
