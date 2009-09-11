#!/usr/bin/perl

package Ocsinventory::Agent;

use strict;
use warnings;

# THIS IS AN UGLY WORKAROUND FOR
# http://rt.cpan.org/Ticket/Display.html?id=38067
use XML::Simple;

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

use Ocsinventory::Agent::CompatibilityLayer;


sub run {

# Load setting from the config file
    my $config = new Ocsinventory::Agent::Config;
#$params->{$_} = $config->{$_} foreach (keys %$config);

    $ENV{LC_ALL} = 'C'; # Turn off localised output for commands
    $ENV{LANG} = 'C'; # Turn off localised output for commands

##########################################
##########################################
##########################################
##########################################
    sub recMkdir {
        my $dir = shift;

        my @t = split /\//, $dir;
        shift @t;
        return unless @t;

        my $t;
        foreach (@t) {
            $t .= '/'.$_;
            if ((!-d $t) && (!mkdir $t)) {
                return;
            }
        }
        1;
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


#####################################
################ MAIN ###############
#####################################


############################
#### CLI parameters ########
############################
    $config->loadUserParams();

# I close STDERR to avoid error message during the module execution
# at the begining I was doing shell redirection:
#  my @ret = `cmd 2> /dev/null`;
# but this syntax is not supported on (at least) FreeBSD and Solaris
# c.f: http://www.perlmonks.org/?node_id=571072
#my $tmp;
#open ($tmp, ">&STDERR");
#$params->{"savedstderr"} = $tmp;
#if($params->{debug}) {
#  $params->{verbose} = 1;
#} else {
#  close(STDERR);
#}

    if ($config->{config}{logfile}) {
        $config->{config}{logger} = 'File';
    }

    my $logger = new Ocsinventory::Logger ({
            config => $config->{config}
        });

# $< == $REAL_USER_ID
    if ( $< ne '0' ) {
        $logger->info("You should run this program as super-user.");
    }

    if ($config->{config}{nosoft}) {
        $logger->info("the parameter --nosoft is deprecated and may be removed in a futur release, please use --nosoftware instead.");
        $config->{config}{nosoftware} = 1
    }

# TODO put that in Ocsinventory::Agent::Config
    if (!$config->{config}{'stdout'} && !$config->{config}{'local'} && $config->{config}{server} !~ /^http(|s):\/\//) {
        $logger->debug("the --server passed doesn't have a protocle, assume http as default");
        $config->{config}{server} = "http://".$config->{config}{server}.'/ocsinventory';
    }

############################
#### Objects initilisation
############################

# The agent can contact different servers. Each server accountconfig is
# stored in a specific file:
    if (!recMkdir ($config->{config}{basevardir})) {

        if (! -d $ENV{HOME}."/.ocsinventory/var") {
            $logger->info("Failed to create ".$config->{config}{basevardir}." directory: $!. ".
                "I'm going to use the home directory instead (~/.ocsinventory/var).");
        }

        $config->{config}{basevardir} = $ENV{HOME}."/.ocsinventory/var";
        if (!recMkdir ($config->{config}{basevardir})) {
            $logger->error("Failed to create ".$config->{config}{basedir}." directory: $!".
                "The HOSTID will not be written on the harddrive. You may have duplicated ".
                "entry of this computer in your OCS database");
        }
        $logger->debug("var files are stored in ".$config->{config}{basevardir});
    }

    if (defined($config->{config}{server}) && $config->{config}{server}) {
        my $dir = $config->{config}{server};
        $dir =~ s/\//_/g;
        $config->{config}{vardir} = $config->{config}{basevardir}."/".$dir;
        if (defined ($config->{config}{local}) && $config->{config}{local}) {
            $logger->debug ("--server ignored since you also use --local");
            $config->{config}{server} = undef;
        }
    } elsif (defined($config->{config}{local}) && $config->{config}{local}) {
        $config->{config}{vardir} = $config->{config}{basevardir}."/__LOCAL__";
    }

    if (!recMkdir ($config->{config}{vardir})) {
        $logger->error("Failed to create ".$config->{config}{vardir}." directory: $!");
    }

    if (-d $config->{config}{vardir}) {
        $config->{config}{accountconfig} = $config->{config}{vardir}."/ocsinv.conf";
        $config->{config}{accountinfofile} = $config->{config}{vardir}."/ocsinv.adm";
        $config->{config}{last_statefile} = $config->{config}{vardir}."/last_state";
        $config->{config}{next_timefile} = $config->{config}{vardir}."/next_timefile";
    }
######


# load CFG files
    my $accountconfig = new Ocsinventory::Agent::AccountConfig({
            logger => $logger,
            config => $config->{config},
        });

    my $srv = $accountconfig->get('OCSFSERVER');
    $config->{config}{server} = $srv if $srv;
    $config->{config}{deviceid}   = $accountconfig->get('DEVICEID');

# Should I create a new deviceID?
    chomp(my $hostname = `uname -n| cut -d . -f 1`);
    if ((!$config->{config}{deviceid}) || $config->{config}{deviceid} !~ /\Q$hostname\E-(?:\d{4})(?:-\d{2}){5}/) {
        my ($YEAR, $MONTH , $DAY, $HOUR, $MIN, $SEC) = (localtime
            (time))[5,4,3,2,1,0];
        $config->{config}{old_deviceid} = $config->{config}{deviceid};
        $config->{config}{deviceid} =sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
        $hostname, ($YEAR+1900), ($MONTH+1), $DAY, $HOUR, $MIN, $SEC;
        $accountconfig->set('DEVICEID',$config->{config}{deviceid});
        $accountconfig->write();
    }

    my $accountinfo = new Ocsinventory::Agent::AccountInfo({
            logger => $logger,
            # TODOparams => $params,
            config => $config->{config},
        });

# --lazy
    if ($config->{config}{lazy}) {
        my $nexttime = (stat($config->{config}{next_timefile}))[9];

        if ($nexttime && $nexttime > time) {
            $logger->info("[Lazy] Must wait until ".localtime($nexttime)." exiting...");
            exit 0;
        }
    }


    if ($config->{config}{tag}) {
        if ($accountinfo->get("TAG")) {
            $logger->debug("A TAG seems to already exist in the server for this".
                "machine. The -t paramter may be ignored by the server useless it".
                "has OCS_OPT_ACCEPT_TAG_UPDATE_FROM_CLIENT=1.");
        }
        $accountinfo->set("TAG",$config->{config}{tag});
    }

# Create compatibility layer. It's used to keep compatibility with the
# linux_agent 1.x and below
    my $compatibilityLayer = new Ocsinventory::Agent::CompatibilityLayer({
            accountinfo => $accountinfo,
            accountconfig => $accountconfig,
            logger => $logger,
            config => $config->{config},
        });

    if ($config->{config}{daemon}) {

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
#######################################################
#######################################################
    while (1) {

        my $exitcode = 0;
        my $wait;
        if ($config->{config}{daemon} || $config->{config}{wait}) {
            my $serverdelay;
            if(($config->{config}{wait} eq 'server') || ($config->{config}{wait}!~/^\d+$/)){
                $serverdelay = $accountconfig->get('PROLOG_FREQ')*3600;
            }
            else{
                $serverdelay = $config->{config}{wait};
            }
            $wait = int rand($serverdelay?$serverdelay:$config->{config}{delaytime});
            $logger->info("Going to sleep for $wait second(s)");
            sleep ($wait);

        }

        $compatibilityLayer->hook({name => 'start_handler'});

#  my $inventory = new Ocsinventory::Agent::XML::Inventory ({
        #
#      accountinfo => $accountinfo,
#      accountconfig => $accountinfo,
#      config => $config->{config},
#      logger => $logger,
        #
#    });


        if ($config->{config}{stdout} || $config->{config}{local}) { # Local mode

            # TODO, avoid to create Backend a two different place
            my $backend = new Ocsinventory::Agent::Backend ({

                    accountinfo => $accountinfo,
                    accountconfig => $accountconfig,
                    logger => $logger,
                    config => $config->{config},

                });

            my $inventory = new Ocsinventory::Agent::XML::Inventory ({

                    # TODO, check if the accoun{info,config} are needed in localmode
                    accountinfo => $accountinfo,
                    accountconfig => $accountinfo,
                    backend => $backend,
                    config => $config->{config},
                    logger => $logger,

                });

            if ($config->{config}{stdout}) {
                $inventory->printXML();
            } elsif ($config->{config}{local}) {
                $inventory->writeXML();
            }

        } else { # I've to contact the server

            my $net = new Ocsinventory::Agent::Network ({

                    accountconfig => $accountconfig,
                    accountinfo => $accountinfo,
                    compatibilityLayer => $compatibilityLayer,
                    logger => $logger,
                    config => $config->{config},

                });

            my $sendInventory = 1;
            my $prologresp;
            if (!$config->{config}{force}) {
                my $prolog = new Ocsinventory::Agent::XML::Prolog({

                        accountinfo => $accountinfo,
                        logger => $logger,
                        config => $config->{config},

                    });

                $prologresp = $net->send({message => $prolog});

                if (!$prologresp) { # Failed to reach the server
                    if ($config->{config}{lazy}) {
                        # To avoid flooding a heavy loaded server
                        my $previousPrologFreq;
                        if( ! ($previousPrologFreq = $accountconfig->get('PROLOG_FREQ') ) ){
                            $previousPrologFreq = $config->{config}{delaytime};
                            $logger->info("No previous PROLOG_FREQ found - using fallback delay(".$config->{config}{delaytime}." seconds)");
                        }
                        else{
                            $logger->info("Previous PROLOG_FREQ found ($previousPrologFreq)");
                            $previousPrologFreq = $previousPrologFreq*3600;
                        }
                        my $time = time + $previousPrologFreq;
                        utime $time,$time,$config->{config}{next_timefile};
                    }
                    exit 1 unless $config->{config}{daemon};
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
                        config => $config->{config},
                        prologresp => $prologresp,

                    });

                my $inventory = new Ocsinventory::Agent::XML::Inventory ({

                        # TODO, check if the accoun{info,config} are needed in localmode
                        accountinfo => $accountinfo,
                        accountconfig => $accountinfo,
                        backend => $backend,
                        config => $config->{config},
                        logger => $logger,

                    });

                $backend->feedInventory ({inventory => $inventory});

                if (my $response = $net->send({message => $inventory})) {
                    #if ($response->isAccountUpdated()) {
                    $inventory->saveLastState();
                    #}
                } else {
                    exit (1) unless $config->{config}{daemon};
                }
            }

        }

        $compatibilityLayer->hook({name => 'end_handler'});
        exit (0) unless $config->{config}{daemon};

    }
}
1;
__END__

=head1 NAME

ocsinventory-agent - Unified client for OCS-Inventory

=head1 SYNOPSIS

B<ocsinventory-agent> S<[ B<-fhilpruw> ]> S<[ I<--server server> | I<--local /tmp> ]>...

=head1 EXAMPLES

    % ocsinventory-agent --server localhost
    # sent an inventory to the OCS server

    % ocsinventory-agent --server http://localhost/ocsinventory2
    # sent an inventory over http to a server with a non standard
    # virtual directory

    % ocsinventory-agent --server https://localhost/ocsinventory
    # sent an inventory over https to the OCS server

    % ocsinventory-agent --local /tmp
    # write an inventory in the /tmp directory

    % ocsinventory-agent --server localhost --user=toto --password=pw --realm="Restricted Area"
    # send a report to a server protected by a basic authentification
    % ocsinventory-agent --lazy
    # send an inventory only if the a random delay between 0 and PROLOG_FREQ had been run over. Usefull for package maintainer.

    % ocsinventory-agent --delaytime 60 -d
    # If NO PROLOG_FREQ has been preset, pick a time between execution and --delaytime for the agent to contact the server [default is 3600 seconds]

=head1 DESCRIPTION

F<ocsinventory-agent> creates inventory and sent or write them. This agent is the
successor of the former linux_agent which was release with OCS 1.01 and prior. It also
replaces the Solaris/AIX/BSD unofficial agents. The detailed list of supported
Operating System is avalaible in the Wiki.

=over 4

=item F<GNU/Linux>

=item F<Solaris>

=item F<FreeBSD>

=item F<NetBSD>

=item F<OpenBSD>

=item F<AIX>

=item F<MacOSX>

=item F<GNU/kFreeBSD>

=back

=head1 OPTIONS

Most of the options are available in a I<short> form and a I<long> form.  For
example, the two lines below are all equivalent:

    % ocsinventory-agent -s localhost
    % ocsinventory-agent --server localhost

=over 4

=item B<--backend-collect-timeout=SECONDS_BEFORE_KILL>

Time before OCS kill modules processing who don't end before the timeout.

=item B<--basevardir>=I<DIR>

Indicate the place where the agent should store its files.

=item B<-d>, B<--daemon>

Launch ocsinventory-agent in background. Proc::Daemon is needed.

=item B<--debug>

Turn the debug mode on.

=item B<--devlib>

This option is designed for backend module developer. With it enabled, ocsinventry-agent won't try to load the Backend module installed on the system. Instead it will scan the ./lib directory.

=item B<--delaytime=SECONDS_TO_WAIT>

This option defaults to waiting a random() time between 0 and 3600 before initially contacting the server assuming NO PROLOG_FREQ has been set. Once PROLOG_FREQ has been set, it uses that number at the top end of it's random setting. Useful for pre-setting a deployed agent's initial start time (so you don't jam the server all at once, but don't have to wait an hour to make sure the deployment worked).

=item B<-f>, B<--force>

The agent will first contact the server during the PROLOG period. If the server doesn't know the machin or have outdated information, it will ask for an inventory.
With this option, the agent doesn't run the PROLOG with the server first but directly send an inventory.

=item B<-i>, B<--info>

Turn the verbose mode on. The flag is ignored if B<--debug> is enable.

=item B<--lazy>

Do not contact the server more than one time during the PROLOG_FREQ. This option is useful for package. Thanks to it they can start the script regulary from the crontab.

=item B<-l>, B<--local>=I<DIR>

Write an inventory in the I<DIR> directory. A new file will be created if needed.

=item B<--logfile>=I<FILE>

Log message in I<FILE> and turn off STDERR

=item B<-p>, B<--password>=I<PASSWORD>

Use I<PASSWORD> for an HTTP identification with the server.

=item B<-P>, B<--proxy>=I<PROXY>

Use I<PROXY> to specify a proxy HTTP server. By default, the script use HTTP_PROXY environment variable. 

=item B<-r>, B<--realm>=I<REALM>

Use I<REALM> for an HTTP identification with the server. For example, the value can be 'Restricted Area'. You can find it in the login popup of your Internet browser.

=item B<-s>, B<--server>=I<URI>

The uri of the server. If I<URI> doesn't start with http:// or https://, the assume the parameter is a hostname and rewrite it like that:

    % http://servername/ocsinventory

If you want to use https or another virtual directory you need to enter the full path.

B<--server> is ignored if B<--local> is in use.

=item B<--stdout>

Print the inventory on stdout.

    % ocsinventory-agent --stdout > /tmp/report.xml
    # prepare an inventory and write it in the /tmp/report.xml file.
    # A file will be created.

=item B<--tag>=I<TAG>

Mark the machin with the I<TAG> tag. Once the initial inventory is accepted by the server this value is ignored and you've to change the information directly on the server. The server do so in order to centralize the administration of the machine.

=item B<-u> I<USER>, B<--user>=I<USER>

Use I<USER> for the server authentification.

=item B<--version>=I<USER>

Print the version and exit.

=item B<-w> I<DURATION>, B<--wait>=I<DURATION>

Wait before initializing the connexion with the server. If I<DURATION> equal I<server> the agent will use the PROLOG_FREQ of the server to determine the duration of this periode. Exactly like it would had done if it was in --daemon mode.
Else if duration is a numerical value, it will be used directly.

    % ocsinventory-agent --wait 5 --server localhost

=item B<--nosoftware>

Do not inventory the software installed on the machin. B<--nosoft> also
works but is deperecated.

=back

=head1 AUTHORS

The maintainer is Goneri LE BOUDER <goneri@rulezlan.org>

Please read the AUTHORS, Changes and THANKS files to see who is behind OCS
Inventory Agent.

=head1 SEE ALSO

=over 4

=item OCS-Inventory website,

 http://www.ocsinventory-ng.org/

=item LaunchPad project page,

 http://launchpad.net/ocsinventory-unix-agent

=item forum,

 http://forums.ocsinventory-ng.org/

=item and wiki

 http://wiki.ocsinventory-ng.org/

=back

=head1 BUGS

Please, use the forum as much as possible. You can open you bug.
Patches are welcome. You can also use LaunchPad bugtracker or
push your Bazaar branch on LaunchPad and do a merge request.

=head1 COPYRIGHT

Copyright (C) 2006-2009 OCS Inventory contributors

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

=cut
