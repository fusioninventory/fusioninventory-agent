package FusionInventory::Agent;

use strict;
use warnings;

use Cwd;
use English qw(-no_match_vars);

use File::Path;

use XML::Simple;
use Sys::Hostname;

our $VERSION = '2.1.6';
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
#use Sys::Hostname;
use FusionInventory::Logger;
use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Agent::XML::Query::Prolog;

use FusionInventory::Agent::Network;
use FusionInventory::Agent::Task;
#use FusionInventory::Agent::Task::Inventory;
use FusionInventory::Agent::AccountInfo;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::Targets;

sub new {
    my ($class, $params) = @_;

    my $self = {};
    my $config = $self->{config} = FusionInventory::Agent::Config::load();

    if ($params->{winService}) {
        $config->{winService} = 1;
    }

    # TODO: should be in Config.pm
    if ($config->{logfile}) {
        $config->{logger} .= ',File';
    }

    my $logger = $self->{logger} = FusionInventory::Logger->new({
        config => $config
    });

    if ( $REAL_USER_ID != 0 ) {
        $logger->info("You should run this program as super-user.");
    }

    if (!-d $config->{basevardir} && !mkpath($config->{basevardir}, {error => undef})) {
        $logger->error(
            "Failed to create ".$config->{basevardir}.
            " Please use --basevardir to point to a R/W directory."
        );
    }

    if (not $config->{'scan-homedirs'}) {
        $logger->debug("--scan-homedirs missing. Don't scan user directories");
    }

    if ($config->{nosoft} || $config->{nosoftware}) {
        $logger->info("the parameter --nosoft and --nosoftware are ".
            "deprecated and may be removed in a future release, ".
            "please use --no-software instead.");
        $config->{'no-software'} = 1
    }

    if (!-d $config->{'share-dir'}) {
        $logger->error("share-dir doesn't existe ".
            "(".$config->{'share-dir'}.")");
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

    $self->{targets} = FusionInventory::Agent::Targets->new({
        logger => $logger,
        config => $config,
        deviceid => $self->{deviceid}
    });
    my $targets = $self->{targets};

    if (!$targets->numberOfTargets()) {
        $logger->error("No target defined. Please use ".
            "--server=SERVER or --local=/directory");
        exit 1;
    }

    if ($config->{daemon}) {

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

    # threads and HTTP::Daemon are optional and so this module
    # may fail to load.
    if (eval "use FusionInventory::Agent::RPC;1;") {
        $self->{rpc} = FusionInventory::Agent::RPC->new({
                logger => $logger,
                config => $config,
                targets => $targets,
            });
    } else {
        $logger->debug("Failed to load RPC module: $EVAL_ERROR");
    }

    $logger->debug("FusionInventory Agent initialised");

    bless $self, $class;

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
    my $targets = $self->{targets};
    my $rpc = $self->{rpc};
    $rpc && $rpc->setCurrentStatus("waiting");

    while (my $target = $targets->getNext()) {

        my $exitcode = 0;
        my $wait;

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
            my $task = FusionInventory::Agent::Task->new({
                config => $config,
                logger => $logger,
                module => $module,
                target => $target,
            });

            $rpc && $rpc->setCurrentStatus("running task $module");
            next unless $task;
            $task->run();
        }
        $rpc && $rpc->setCurrentStatus("waiting");

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

