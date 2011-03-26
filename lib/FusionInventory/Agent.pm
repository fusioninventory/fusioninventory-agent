package FusionInventory::Agent;

use strict;
use warnings;

use Cwd;
use English qw(-no_match_vars);
use File::Path;
use Sys::Hostname;
use UNIVERSAL::require;
use XML::Simple;

use FusionInventory::Logger;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::Network;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Task;
use FusionInventory::Agent::Targets;
use FusionInventory::Agent::XML::Query::Prolog;

our $VERSION = '2.1.8';
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

    my $self = {
        status => 'unknown',
        token  => _computeNewToken()
    };
    bless $self, $class;

    my $config = $self->{config} = FusionInventory::Agent::Config->new($params);

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

    if (!-d $config->{'share-dir'}) {
        $logger->error("share-dir doesn't existe ".
            "(".$config->{'share-dir'}.")");
    }

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

    if (!$config->{'no-httpd'}) {
        FusionInventory::Agent::HTTPD->require();
        if ($EVAL_ERROR) {
            $logger->debug("Failed to load HTTPD module: $EVAL_ERROR");
        } else {
            # make sure relevant variables are shared between threads
            threads::shared::share($self->{status});
            threads::shared::share($self->{token});

            FusionInventory::Agent::RPC->new({
                logger => $logger,
                config => $config,
                targets => $targets,
                agent   => $self,
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
    my $targets = $self->{targets};
    $self->{status} = 'waiting';

    while (my $target = $targets->getNext()) {

        my $exitcode = 0;
        my $wait;

        my $prologresp;
        my $network;
        if ($target->{type} eq 'server') {

            $network = FusionInventory::Agent::Network->new({
                logger => $logger,
                config => $config,
                target => $target,
            });

            my $prolog = FusionInventory::Agent::XML::Query::Prolog->new({
                accountinfo => $target->{accountinfo}, #? XXX
                logger => $logger,
                config => $config,
                token  => $self->{token},
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
                logger      => $logger,
                target      => $target,
                prologresp  => $prologresp,
                network     => $network,
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

        sleep(5);
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
