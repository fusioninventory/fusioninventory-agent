package FusionInventory::Agent::Daemon;

use strict;
use warnings;

use Cwd;
use English qw(-no_match_vars);
use UNIVERSAL::require;
use POSIX ":sys_wait_h"; # WNOHANG

use parent 'FusionInventory::Agent';

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Version;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

my $PROVIDER = $FusionInventory::Agent::Version::PROVIDER;

sub init {
    my ($self, %params) = @_;

    $self->{lastConfigLoad} = time;

    $self->SUPER::init(%params);

    $self->createDaemon();

    # create HTTP interface if required
    $self->loadHttpInterface();

    $self->ApplyServiceOptimizations();

    # install signal handler to handle reload signal
    $SIG{HUP} = sub { $self->reinit(); };
    $SIG{USR1} = sub { $self->runNow(); }
        unless ($OSNAME eq 'MSWin32');
}

sub reinit {
    my ($self) = @_;

    # Update PID file modification time so we can expire it
    utime undef,undef,$self->{pidfile} if $self->{pidfile};

    $self->{logger}->debug('agent reinit');

    $self->{lastConfigLoad} = time;

    $self->{config}->reloadFromInputAndBackend();

    # Reload init from parent class
    $self->SUPER::init();

    # Reload HTTP interface if required
    $self->loadHttpInterface();

    $self->ApplyServiceOptimizations();

    $self->{logger}->debug('agent reinit done.');
}

sub run {
    my ($self) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};

    $self->setStatus('waiting');

    my @targets = $self->getTargets();

    if ($logger) {
        if ($config->{'no-fork'}) {
            $logger->debug2("Waiting in mainloop");
            foreach my $target (@targets) {
                my $date = $target->getFormatedNextRunDate();
                my $type = $target->getType();
                my $name = $target->getName();
                $logger->debug2("$type target next run: $date - $name");
            }
        } else {
            $logger->debug("Running in background mode");
        }
    }

    # background mode: work on a targets list copy, but loop while
    # the list really exists so we can stop quickly when asked for
    while ($self->getTargets()) {
        my $time = time();

        @targets = $self->getTargets() unless @targets;
        my $target = shift @targets;

        $self->_reloadConfIfNeeded();

        if ($target->paused()) {
            # Leave immediately if we passed in terminate method
            last unless $self->getTargets();

        } elsif ($time >= $target->getNextRunDate()) {

            my $net_error = 0;
            eval {
                $net_error = $self->runTarget($target);
            };
            $logger->error($EVAL_ERROR) if ($EVAL_ERROR && $logger);
            if ($net_error) {
                # Prefer to retry early on net error
                $target->setNextRunDateFromNow(60);
            } else {
                $target->resetNextRunDate();
            }

            if ($logger && $config->{'no-fork'}) {
                my $date = $target->getFormatedNextRunDate();
                my $type = $target->getType();
                $logger->debug2("$type target scheduled: $date");
            }

            # Leave immediately if we passed in terminate method
            last unless $self->getTargets();

            # Call service optimization after each target run
            $self->RunningServiceOptimization();
        }

        # This eventually check for http messages, default timeout is 1 second
        $self->sleep(1);
    }
}

sub runNow {
    my ($self) = @_;

    foreach my $target ($self->getTargets()) {
        $target->setNextRunDateFromNow();
    }

    $self->{logger}->info("$PROVIDER Agent requested to run all targets now");
}

sub _reloadConfIfNeeded {
    my ($self) = @_;

    my $reloadInterval = $self->{config}->{'conf-reload-interval'} || 0;

    return unless ($reloadInterval > 0);

    my $reload = time - $self->{lastConfigLoad} - $reloadInterval;

    $self->reinit() if ($reload > 0);
}

sub runTask {
    my ($self, $target, $name, $response) = @_;

    $self->setStatus("running task $name");

    # server mode: run each task in a child process
    if (my $pid = fork()) {

        # parent
        $self->{current_runtask} = $pid;

        while (waitpid($pid, WNOHANG) == 0) {
            # Wait but eventually handle http server requests
            $self->sleep(1);

            # Leave earlier while requested
            last unless $self->getTargets();
        }
        delete $self->{current_runtask};

    } else {
        # child
        die "fork failed: $ERRNO" unless defined $pid;

        # Don't handle HTTPD interface in forked child
        delete $self->{server};

        # Mostly to update process name on unix platforms
        $self->setStatus("task $name");

        $self->{logger}->debug("forking process $pid to handle task $name");

        $self->runTaskReal($target, $name, $response);

        exit(0);
    }
}

sub createDaemon {
    my ($self) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};

    # Don't try to create a daemon if configured as a service
    return $logger->info("$PROVIDER Agent service starting")
        if $config->{service};

    $logger->info("$PROVIDER Agent starting");

    my $pidfile = $config->{pidfile};

    if (defined($pidfile) && $pidfile eq "") {
        # Set to default pidfile only when needed
        $pidfile = $self->{vardir} . '/'. lc($PROVIDER). '-agent.pid';
        $logger->debug("Using $pidfile as default PID file") if $logger;
    } elsif (!$pidfile) {
        $logger->debug("Skipping running daemon control based on PID file checking") if $logger;
    }

    # Expire PID file if daemon is not running while conf-reload-interval is
    # in use and PID file has not been update since, including a minute safety gap
    if ($pidfile && -e $pidfile && $self->{config}->{'conf-reload-interval'}) {
        my $mtime = (stat($pidfile))[9];
        if ($mtime && $mtime < time - $self->{config}->{'conf-reload-interval'} - 60) {
            $logger->info("$pidfile PID file expired") if $logger;
            unlink $pidfile;
        }
    }

    my $daemon;

    Proc::Daemon->require();
    if ($EVAL_ERROR) {
        $logger->debug("Failed to load recommended Proc::Daemon library: $EVAL_ERROR") if $logger;

        # Eventually check running process from pid found in pid file
        if ($pidfile) {
            my $pid = getFirstLine(file => $pidfile);

            if ($pid && int($pid)) {
                $logger->debug2("Last running daemon started with PID $pid") if $logger;
                if ($pid != $$ && kill(0, $pid)) {
                    $logger->error("$PROVIDER Agent is already running, exiting...") if $logger;
                    exit 1;
                }
                $logger->debug("$PROVIDER Agent with PID $pid is dead") if $logger;
            }
        }

    } else {
        # If we use relative path, we must stay in the current directory
        my $workdir = substr($self->{libdir}, 0, 1) eq '/' ? '/' : getcwd();

        # Be sure to keep libdir in includes or we can fail to load need libraries
        unshift @INC, $self->{libdir}
            if ($workdir eq '/' && ! first { $_ eq $self->{libdir} } @INC);

        $daemon = Proc::Daemon->new(
            work_dir => $workdir,
            pid_file => $pidfile
        );

        # Use Proc::Daemon API to check daemon status but it always return false
        # if pidfile is not used
        if ($daemon->Status()) {
            $logger->error("$PROVIDER Agent is already running, exiting...") if $logger;
            exit 1;
        }
    }

    if ($config->{'no-fork'} || !$daemon) {
        # Still keep current PID in PID file to permit Proc::Daemon to check status
        if ($pidfile) {
            if (open(my $pid, ">", $pidfile)) {
                print $pid "$$\n";
                close($pid);
            } elsif ($logger) {
                $logger->debug("Can't write PID file: $!");
                undef $pidfile;
            }
        }
        $logger->debug("$PROVIDER Agent started in foreground") if $logger;

    } elsif (my $pid = $daemon->Init()) {
        $logger->debug("$PROVIDER Agent daemonized with PID $pid") if $logger;
        exit 0;
    }

    # From here we can enable our pidfile deletion on terminate
    $self->{pidfile} = $pidfile;
}

sub sleep {
    my ($self, $delay) = @_;

    eval {
        local $SIG{CHLD} = sub { die ; };
        if ($self->{server}) {
            # Check for http interface messages, default timeout is 1 second
            $self->{server}->handleRequests() or delay($delay || 1);
        } else {
            delay($delay || 1);
        }
    };
}

sub loadHttpInterface {
    my ($self) = @_;

    my $config = $self->{config};

    if ($config->{'no-httpd'}) {
        # Handle re-init case
        $self->{server}->stop() if ($self->{server});
        return;
    }

    my $logger = $self->{logger};

    my %server_config = (
        logger  => $logger,
        agent   => $self,
        htmldir => $self->{datadir} . '/html',
        ip      => $config->{'httpd-ip'},
        port    => $config->{'httpd-port'},
        trust   => $config->{'httpd-trust'}
    );

    # Handle re-init, don't restart httpd interface unless config changed
    if ($self->{server}) {
        return unless $self->{server}->needToRestart(%server_config);
        $self->{server}->stop();
    }

    FusionInventory::Agent::HTTP::Server->require();
    if ($EVAL_ERROR) {
        $logger->error("Failed to load HTTP server: $EVAL_ERROR");
    } else {
        $self->{server} = FusionInventory::Agent::HTTP::Server->new(%server_config);
        $self->{server}->init();
    }
}

sub ApplyServiceOptimizations {
    my ($self) = @_;

    # Preload all IDS databases to avoid reload them all the time during inventory
    my @planned = map { $_->plannedTasks() } $self->getTargets();
    if (grep { /^inventory$/i } @planned) {
        my %datadir = ( datadir => $self->{datadir} );
        getPCIDeviceVendor(%datadir);
        getUSBDeviceVendor(%datadir);
        getEDIDVendor(%datadir);
    }
}

sub RunningServiceOptimization {
    my ($self) = @_;
}

sub terminate {
    my ($self) = @_;

    # Still stop HTTP interface
    $self->{server}->stop() if ($self->{server});

    $self->{logger}->info("$PROVIDER Agent exiting")
        unless ($self->{current_task});

    $self->SUPER::terminate();

    # Kill current forked task
    if ($self->{current_runtask}) {
        kill 'TERM', $self->{current_runtask};
        delete $self->{current_runtask};
    }

    # Remove pidfile
    unlink $self->{pidfile} if $self->{pidfile};
}

1;
