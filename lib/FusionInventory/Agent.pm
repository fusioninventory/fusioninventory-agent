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

use POE;

our $VERSION = '2.1_rc3';
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
    #my $config = $self->{config} = FusionInventory::Agent::Config::load();

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
    $rpc && $rpc->setCurrentStatus("waiting");

    foreach my $target ($targetsList->{targets}) {
        print "toto\n";
    }


    POE::Kernel->run();
    exit;
#####################################
################ MAIN ###############
#####################################


#######################################################
#######################################################
}

1;
