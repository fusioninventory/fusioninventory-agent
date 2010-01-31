#!/usr/bin/perl

package Ocsinventory::Agent;

use English;

use strict;
use warnings;

# THIS IS AN UGLY WORKAROUND FOR
# http://rt.cpan.org/Ticket/Display.html?id=38067
use XML::Simple;
use Sys::Hostname;

$ENV{LC_ALL} = 'C'; # Turn off localised output for commands
$ENV{LANG} = 'C'; # Turn off localised output for commands

eval {XMLout("<a>b</a>");};
if ($@){
    no strict 'refs';
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
#use Sys::Hostname;
use Ocsinventory::Logger;
use Ocsinventory::Agent::XML::Query::Inventory;
use Ocsinventory::Agent::XML::Query::Prolog;

use Ocsinventory::Agent::Network;
use Ocsinventory::Agent::Task::Inventory;
use Ocsinventory::Agent::AccountInfo;
use Ocsinventory::Agent::Storage;
use Ocsinventory::Agent::Config;
use Ocsinventory::Agent::RPC;
use Ocsinventory::Agent::Targets;

sub new {
    my (undef, $self) = @_;

############################
#### CLI parameters ########
############################
    my $config = $self->{config} = Ocsinventory::Agent::Config::load();

    # TODO: should be in Config.pm
    if ($config->{logfile}) {
        $config->{logger} = 'File';
    }

    my $logger = $self->{logger} = new Ocsinventory::Logger ({
            config => $config
        });

# $< == $REAL_USER_ID
    if ( $< ne '0' ) {
        $logger->info("You should run this program as super-user.");
    }

    if (not $config->{scanhomedirs}) {
        $logger->debug("--scan-homedirs missing. Don't scan user directories");
    }

    if ($config->{nosoft}) {
        $logger->info("the parameter --nosoft is deprecated and may be removed in a future release, please use --nosoftware instead.");
        $config->{nosoftware} = 1
    }


    my $hostname = hostname; # Sys::Hostname

# /!\ $rootStorage save/read data in 'basevardir', not in a target directory!
    my $rootStorage = new Ocsinventory::Agent::Storage({
        config => $config
    });
    my $myRootData = $rootStorage->restore();

    if (!defined($myRootData->{previousHostname}) || defined($myRootData->{previousHostname}) &&  ($myRootData->{previousHostname} ne $hostname)) {
        my ($YEAR, $MONTH , $DAY, $HOUR, $MIN, $SEC) = (localtime
            (time))[5,4,3,2,1,0];
        $self->{deviceid} =sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
        $hostname, ($YEAR+1900), ($MONTH+1), $DAY, $HOUR, $MIN, $SEC;

        $myRootData->{previousHostname} = $hostname;
        $myRootData->{deviceid} = $self->{deviceid};
        $rootStorage->save($myRootData);
    } else {
        $self->{deviceid} = $myRootData->{deviceid}
    }


############################
#### Objects initilisation
############################


######
    $self->{targets} = new Ocsinventory::Agent::Targets({

            logger => $logger,
            config => $config,
            deviceid => $self->{deviceid}
            
        });
    my $targets = $self->{targets};

    if ($config->{daemon}) {

        $logger->debug("Time to call Proc::Daemon");
        eval { require Proc::Daemon; };
        if ($@) {
            print "Can't load Proc::Daemon. Is the module installed?";
            exit 1;
        }
        Proc::Daemon::Init();
        $logger->debug("Daemon started");
        if (isAgentAlreadyRunning({
                    logger => $logger,
                })) {
            $logger->debug("An agent is already runnnig, exiting...");
            exit 1;
        }

    }
    $self->{rpc} = new Ocsinventory::Agent::RPC ({
          
            logger => $logger,
            config => $config,
            targets => $targets,
  
        });

    $logger->debug("OCS Agent initialised");

    bless $self;

}

sub isAgentAlreadyRunning {
    my $params = shift;
    my $logger = $params->{logger};
    # TODO add a workaround if Proc::PID::File is not installed
    eval { require Proc::PID::File; };
    if(!$@) {
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
    my $targets = $self->{targets};
    my $rpc = $self->{rpc};



#####################################
################ MAIN ###############
#####################################


#######################################################
#######################################################
    while (my $target = $targets->getNext()) {

        my $exitcode = 0;
        my $wait;

        my $prologresp;
        if ($target->{type} eq 'server') {

            my $network = new Ocsinventory::Agent::Network ({

                    logger => $logger,
                    config => $config,
                    target => $target,

                });

            my $prolog = new Ocsinventory::Agent::XML::Query::Prolog({

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

    
        my $storage = new Ocsinventory::Agent::Storage({

                config => $config,
                logger => $logger,
                target => $target,

            });
        $storage->save({

            config => $config,
            target => $target,
            #logger => $logger, # XXX Needed?
            prologresp => $prologresp

            });


        my @tasks;
        push @tasks, 'Inventory' unless $config->{'noinventory'};
        push @tasks, 'Deploy' unless $config->{'nodeploy'};
	push @tasks, 'SNMPQuery' unless $config->{'nosnmpquery'};
	push @tasks, 'NetDiscovery' unless $config->{'nonetdiscovery'};

        foreach my $task (@tasks) {
            $logger->debug("[task]start of ".$task);


            my $cmd;
            $cmd .= $EXECUTABLE_NAME; # The Perl binary path
            $cmd .= " -Ilib" if $config->{devlib};
            $cmd .= " -MOcsinventory::Agent::Task::".$task;
            $cmd .= " -e 'Ocsinventory::Agent::Task::".$task."::main();' --";
            $cmd .= " ".$target->{vardir};

            system($cmd);

            $logger->debug("[task] end of ".$task);
        }

        $storage->remove();
        $target->setNextRunDate();

        sleep(5);
    }
}
1;

