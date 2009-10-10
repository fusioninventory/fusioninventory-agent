#!/usr/bin/perl

package Ocsinventory::Agent;

use strict;
use warnings;

# THIS IS AN UGLY WORKAROUND FOR
# http://rt.cpan.org/Ticket/Display.html?id=38067
use XML::Simple;
use File::Path;

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
use Ocsinventory::Logger;
use Ocsinventory::Agent::XML::Inventory;
use Ocsinventory::Agent::XML::Prolog;

use Ocsinventory::Agent::Network;
use Ocsinventory::Agent::Backend;
use Ocsinventory::Agent::AccountConfig;
use Ocsinventory::Agent::AccountInfo;
#use Ocsinventory::Agent::Pid;
use Ocsinventory::Agent::Config;

sub new {
    my (undef, $this) = @_;

############################
#### CLI parameters ########
############################
    my $config = $this->{config} = Ocsinventory::Agent::Config::load();

    # TODO: should be in Config.pm
    if ($config->{logfile}) {
        $config->{logger} = 'File';
    }

    my $logger = $this->{logger} = new Ocsinventory::Logger ({
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
        $logger->info("the parameter --nosoft is deprecated and may be removed in a futur release, please use --nosoftware instead.");
        $config->{nosoftware} = 1
    }

# TODO put that in Ocsinventory::Agent::Config
    if (!$config->{'stdout'} && !$config->{'local'} && $config->{server} !~ /^http(|s):\/\//) {
        $logger->debug("the --server passed doesn't have a protocle, assume http as default");
        $config->{server} = "http://".$config->{server}.'/ocsinventory';
    }

############################
#### Objects initilisation
############################

# The agent can contact different servers. Each server accountconfig is
# stored in a specific file:
    if (!-d $config->{basevardir} && !mkpath ($config->{basevardir})) {

        if (! -d $ENV{HOME}."/.ocsinventory/var") {
            $logger->info("Failed to create ".$config->{basevardir}." directory: $!. ".
                "I'm going to use the home directory instead (~/.ocsinventory/var).");
        }

        $config->{basevardir} = $ENV{HOME}."/.ocsinventory/var";
        if (!-d $config->{basevardir} && !mkpath ($config->{basevardir})) {
            $logger->error("Failed to create ".$config->{basedir}." directory: $!".
                "The HOSTID will not be written on the harddrive. You may have duplicated ".
                "entry of this computer in your OCS database");
        }
        $logger->debug("var files are stored in ".$config->{basevardir});
    }

    if (defined($config->{server}) && $config->{server}) {
        my $dir = $config->{server};
        $dir =~ s/\//_/g;
        $config->{vardir} = $config->{basevardir}."/".$dir;
        if (defined ($config->{local}) && $config->{local}) {
            $logger->debug ("--server ignored since you also use --local");
            $config->{server} = undef;
        }
    } elsif (defined($config->{local}) && $config->{local}) {
        $config->{vardir} = $config->{basevardir}."/__LOCAL__";
    }

    if (!-d $config->{vardir} && mkpath ($config->{vardir})) {
        $logger->error("Failed to create ".$config->{vardir}." directory: $!");
    }

    if (-d $config->{vardir}) {
        $config->{accountconfig} = $config->{vardir}."/ocsinv.conf";
        $config->{accountinfofile} = $config->{vardir}."/ocsinv.adm";
        $config->{last_statefile} = $config->{vardir}."/last_state";
        $config->{next_timefile} = $config->{vardir}."/next_timefile";
    }
######


# load CFG files
    my $accountconfig = $this->{accountconfig} = new Ocsinventory::Agent::AccountConfig({
            logger => $logger,
            config => $config,
        });

    my $srv = $accountconfig->get('OCSFSERVER');
    $config->{server} = $srv if $srv;
    $config->{deviceid}   = $accountconfig->get('DEVICEID');

# Should I create a new deviceID?
    chomp(my $hostname = `uname -n| cut -d . -f 1`);
    if ((!$config->{deviceid}) || $config->{deviceid} !~ /\Q$hostname\E-(?:\d{4})(?:-\d{2}){5}/) {
        my ($YEAR, $MONTH , $DAY, $HOUR, $MIN, $SEC) = (localtime
            (time))[5,4,3,2,1,0];
        $config->{old_deviceid} = $config->{deviceid};
        $config->{deviceid} =sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
        $hostname, ($YEAR+1900), ($MONTH+1), $DAY, $HOUR, $MIN, $SEC;
        $accountconfig->set('DEVICEID',$config->{deviceid});
        $accountconfig->write();
    }

    my $accountinfo = $this->{accountinfo} = new Ocsinventory::Agent::AccountInfo({
            logger => $logger,
            # TODOparams => $params,
            config => $config,
        });

# --lazy
    if ($config->{lazy}) {
        my $nexttime = (stat($config->{next_timefile}))[9];

        if ($nexttime && $nexttime > time) {
            $logger->info("[Lazy] Must wait until ".localtime($nexttime)." exiting...");
            exit 0;
        }
    }


    if ($config->{tag}) {
        if ($accountinfo->get("TAG")) {
            $logger->debug("A TAG seems to already exist in the server for this ".
                "machine. The -t paramter may be ignored by the server useless it ".
                "has OCS_OPT_ACCEPT_TAG_UPDATE_FROM_CLIENT=1.");
        }
        $accountinfo->set("TAG",$config->{tag});
    }

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

    $logger->debug("OCS Agent initialised");


    bless $this;
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
    my ($this) = @_;

# Load setting from the config file
    my $config = $this->{config};
    my $accountinfo = $this->{accountinfo};
    my $accountconfig = $this->{accountconfig};
    my $logger = $this->{logger};


##########################################
##########################################
##########################################
##########################################

    # Local mode, no need to contact the server
    if ($config->{stdout} || $config->{local}) { # Local mode

        # TODO, avoid to create Backend a two different place
        my $backend = new Ocsinventory::Agent::Backend ({

                accountinfo => $accountinfo,
                accountconfig => $accountconfig,
                logger => $logger,
                config => $config,

            });

        my $inventory = new Ocsinventory::Agent::XML::Inventory ({

                # TODO, check if the accoun{info,config} are needed in localmode
                accountinfo => $accountinfo,
                accountconfig => $accountinfo,
                backend => $backend,
                config => $config,
                logger => $logger,

            });

        if ($config->{stdout}) {
            $inventory->printXML();
        } elsif ($config->{local}) {
            $inventory->writeXML();
        }
        exit (0);
    }
    # Local mode, no need to continue



#####################################
################ MAIN ###############
#####################################


#######################################################
#######################################################
    while (1) {

        my $exitcode = 0;
        my $wait;
        if ($config->{daemon} || $config->{wait}) {
            my $serverdelay;
            if(($config->{wait} eq 'server') || ($config->{wait}!~/^\d+$/)){
                $serverdelay = $accountconfig->get('PROLOG_FREQ')*3600;
            }
            else{
                $serverdelay = $config->{wait};
            }
            $wait = int rand($serverdelay?$serverdelay:$config->{delaytime});
            $logger->info("Going to sleep for $wait second(s)");
            sleep ($wait);

        }



        my $network = new Ocsinventory::Agent::Network ({

                accountconfig => $accountconfig,
                accountinfo => $accountinfo,
                logger => $logger,
                config => $config,

            });

        my $sendInventory = 1;
        my $prologresp;
        if (!$config->{force}) {
            my $prolog = new Ocsinventory::Agent::XML::Prolog({

                    accountinfo => $accountinfo,
                    logger => $logger,
                    config => $config,

                });

            $prologresp = $network->send({message => $prolog});

            if (!$prologresp) { # Failed to reach the server
                if ($config->{lazy}) {
                    # To avoid flooding a heavy loaded server
                    my $previousPrologFreq;
                    if( ! ($previousPrologFreq = $accountconfig->get('PROLOG_FREQ') ) ){
                        $previousPrologFreq = $config->{delaytime};
                        $logger->info("No previous PROLOG_FREQ found - using fallback delay(".$config->{delaytime}." seconds)");
                    }
                    else{
                        $logger->info("Previous PROLOG_FREQ found ($previousPrologFreq)");
                        $previousPrologFreq = $previousPrologFreq*3600;
                    }
                    my $time = time + $previousPrologFreq;
                    utime $time,$time,$config->{next_timefile};
                }
                exit 1 unless $config->{daemon};
                $sendInventory = 0;
            } elsif (!$prologresp->isInventoryAsked()) {
                $sendInventory = 0;
            }
        }

        if (!$sendInventory) {

            $logger->info("Don't send the inventory");

        } else { # Send the inventory!

            my $backend = new Ocsinventory::Agent::Backend ({

                    accountinfo => $accountinfo,
                    accountconfig => $accountconfig,
                    logger => $logger,
                    config => $config,
                    network => $network,
                    prologresp => $prologresp,

                });

            my $inventory = new Ocsinventory::Agent::XML::Inventory ({

                    # TODO, check if the accoun{info,config} are needed in localmode
                    accountinfo => $accountinfo,
                    accountconfig => $accountinfo,
                    backend => $backend,
                    config => $config,
                    logger => $logger,

                });

            $backend->feedInventory ({inventory => $inventory});

            if (my $response = $network->send({message => $inventory})) {
                #if ($response->isAccountUpdated()) {
                $inventory->saveLastState();
                #}
            } else {
                exit (1) unless $config->{daemon};
            }

            # Start the built in HTTP daemon if --allow-rpc is enabled
            #    $backend->runRpc() if $config->{allowRpc};
            $backend->runRpc();

            # call the postExec() function in the Backend
            $backend->doPostInventorys({
                    config => $config,
                    logger => $logger
                });


            $logger->debug("Sleeping...ZzZZZ");
            sleep(15);
            # Break the loop if needed 
            exit (0) unless $config->{daemon};
        }
    }
}
1;

