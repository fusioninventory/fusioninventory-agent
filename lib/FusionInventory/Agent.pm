package FusionInventory::Agent;

use strict;
use warnings;

use Cwd;
use English qw(-no_match_vars);
use UNIVERSAL::require;
use File::Glob;
use IO::Handle;
use POSIX ":sys_wait_h"; # WNOHANG
use Storable 'dclone';

use FusionInventory::Agent::Version;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::HTTP::Client::OCS;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Target::Local;
use FusionInventory::Agent::Target::Server;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;
use FusionInventory::Agent::Tools::Hostname;
use FusionInventory::Agent::XML::Query::Prolog;

our $VERSION = $FusionInventory::Agent::Version::VERSION;
my $PROVIDER = $FusionInventory::Agent::Version::PROVIDER;
our $COMMENTS = $FusionInventory::Agent::Version::COMMENTS || [];
our $VERSION_STRING = _versionString($VERSION);
our $AGENT_STRING = "$PROVIDER-Agent_v$VERSION";
our $CONTINUE_WORD = "...";

sub _versionString {
    my ($VERSION) = @_;

    my $string = "$PROVIDER Agent ($VERSION)";
    if ($VERSION =~ /^\d+\.\d+\.(99\d\d|\d+-dev)$/) {
        unshift @{$COMMENTS}, "** THIS IS A DEVELOPMENT RELEASE **";
    }

    return $string;
}

sub new {
    my ($class, %params) = @_;

    my $self = {
        status  => 'unknown',
        confdir => $params{confdir},
        datadir => $params{datadir},
        libdir  => $params{libdir},
        vardir  => $params{vardir},
        sigterm => $params{sigterm},
        targets => [],
        tasks   => []
    };
    bless $self, $class;

    return $self;
}

sub init {
    my ($self, %params) = @_;

    my $config = FusionInventory::Agent::Config->new(
        confdir => $self->{confdir},
        options => $params{options},
    );
    $self->{config} = $config;

    my $verbosity = $config->{debug} && $config->{debug} == 1 ? LOG_DEBUG  :
                    $config->{debug} && $config->{debug} == 2 ? LOG_DEBUG2 :
                                                                LOG_INFO   ;

    my $logger = FusionInventory::Agent::Logger->new(
        config    => $config,
        backends  => $config->{logger},
        verbosity => $verbosity
    );
    $self->{logger} = $logger;

    $logger->debug("Configuration directory: $self->{confdir}");
    $logger->debug("Data directory: $self->{datadir}");
    $logger->debug("Storage directory: $self->{vardir}");
    $logger->debug("Lib directory: $self->{libdir}");

    $self->{storage} = FusionInventory::Agent::Storage->new(
        logger    => $logger,
        directory => $self->{vardir}
    );

    # handle persistent state
    $self->_loadState();

    $self->{deviceid} = _computeDeviceId() if !$self->{deviceid};

    $self->_saveState();

    $self->_createTargets();

    if (!$self->getTargets()) {
        $logger->error("No target defined, aborting");
        exit 1;
    }

    # compute list of allowed tasks
    my %available = $self->getAvailableTasks(disabledTasks => $config->{'no-task'});
    my @tasks = keys %available;
    my @plannedTasks = $self->computeTaskExecutionPlan(\@tasks);
    $self->{tasksExecutionPlan} = \@plannedTasks;

    my %available_lc = map { (lc $_) => $_ } keys %available;
    if (!@tasks) {
        $logger->error("No tasks available, aborting");
        exit 1;
    }

    $logger->debug("Available tasks:");
    foreach my $task (keys %available) {
        $logger->debug("- $task: $available{$task}");
    }
    $logger->debug("Planned tasks:");
    foreach my $task (@{$self->{tasksExecutionPlan}}) {
        my $task_lc = lc $task;
        $logger->debug("- $task: " . $available{$available_lc{$task_lc}});
    }

    $self->{tasks} = \@tasks;

    if ($config->{daemon}) {
        $self->_createDaemon();
    }

    # create HTTP interface
    if (($config->{daemon} || $config->{service}) && !$config->{'no-httpd'}) {
        $self->_createHttpInterface();
    }

    # install signal handler to handle graceful exit
    $self->_installSignalHandlers();

    $self->{logger}->info("$PROVIDER Agent starting")
        if $self->{config}->{daemon} || $self->{config}->{service};

    $self->ApplyServiceOptimizations();

    $self->{logger}->info("Options 'no-task' and 'tasks' are both used. Be careful that 'no-task' always excludes tasks.")
        if ($self->{config}->isParamArrayAndFilled('no-task') && $self->{config}->isParamArrayAndFilled('tasks'));

    foreach my $comment (@{$COMMENTS}) {
        $self->{logger}->info($comment);
    }

    $self->resetLastConfigLoad();
}

sub reinit {
    my ($self) = @_;

    $self->{logger}->debug('agent reinit');

    $self->{config}->reloadFromInputAndBackend($self->{confdir});

    my $config = $self->{config};

    my $verbosity = $config->{debug} && $config->{debug} == 1 ? LOG_DEBUG  :
                    $config->{debug} && $config->{debug} == 2 ? LOG_DEBUG2 :
                                                                LOG_INFO   ;

    my $logger = undef;
    if (! defined($self->{logger})) {
        $logger = FusionInventory::Agent::Logger->new(
            config    => $config,
            backends  => $config->{logger},
            verbosity => $verbosity
        );
        $self->{logger} = $logger;
    } else {
        $logger = $self->{logger};
    }

    $logger->debug("Configuration directory: $self->{confdir}");
    $logger->debug("Data directory: $self->{datadir}");
    $logger->debug("Storage directory: $self->{vardir}");
    $logger->debug("Lib directory: $self->{libdir}");

    # handle persistent state
    $self->_loadState();

    $self->{deviceid} = _computeDeviceId() if !$self->{deviceid};

    $self->_saveState();

    if (!$self->getTargets()) {
        $logger->error("No target defined, aborting");
        exit 1;
    }

    # compute list of allowed tasks
    my %available = $self->getAvailableTasks(disabledTasks => $config->{'no-task'});
    my @tasks = keys %available;
    my @plannedTasks = $self->computeTaskExecutionPlan(\@tasks);
    $self->{tasksExecutionPlan} = \@plannedTasks;

    my %available_lc = map { (lc $_) => $_ } keys %available;
    if (!@tasks) {
        $logger->error("No tasks available, aborting");
        exit 1;
    }

    $logger->debug("Available tasks:");
    foreach my $task (keys %available) {
        $logger->debug("- $task: $available{$task}");
    }
    $logger->debug("Planned tasks:");
    foreach my $task (@{$self->{tasksExecutionPlan}}) {
        my $task_lc = lc $task;
        $logger->debug("- $task: " . $available{$available_lc{$task_lc}});
    }

    $self->{tasks} = \@tasks;

    $self->ApplyServiceOptimizations();

    $self->resetLastConfigLoad();

    $self->{logger}->debug('agent reinit done.');
}

sub resetLastConfigLoad {
    my ($self) = @_;

    $self->{lastConfigLoad} = time;
}

sub ApplyServiceOptimizations {
    my ($self) = @_;

    return unless ($self->{config}->{daemon} || $self->{config}->{service});

    # Preload all IDS databases to avoid reload them all the time during inventory
    if (grep { /^inventory$/i } @{$self->{tasksExecutionPlan}}) {
        getPCIDeviceVendor(datadir => $self->{datadir});
        getUSBDeviceVendor(datadir => $self->{datadir});
        getEDIDVendor(datadir => $self->{datadir});
    }

    # win32 platform optimization
    if ($OSNAME eq 'MSWin32') {
        # Preload is64bit result to avoid a lot of WMI calls
        FusionInventory::Agent::Tools::Win32->require();
        FusionInventory::Agent::Tools::Win32::is64bit();
    }
}

sub RunningServiceOptimization {
    my ($self) = @_;

    # win32 platform needs optimization
    if ($OSNAME eq 'MSWin32') {
        if ($self->{logger}->{verbosity} >= LOG_DEBUG) {
            my $runmem = FusionInventory::Agent::Tools::Win32::getAgentMemorySize();
            $self->{logger}->debug("Agent memory usage before freeing memory: $runmem");
        }

        FusionInventory::Agent::Tools::Win32::FreeAgentMem();

        my $current_mem = FusionInventory::Agent::Tools::Win32::getAgentMemorySize();
        $self->{logger}->info("Agent memory usage: $current_mem");
    }
}

sub run {
    my ($self) = @_;

    $self->{status} = 'waiting';

    my @targets = $self->getTargets();

    if ($self->{config}->{daemon} || $self->{config}->{service}) {

        $self->{logger}->debug2("Running in background mode");

        # background mode: work on a targets list copy, but loop while
        # the list really exists so we can stop quickly when asked for
        while ($self->getTargets()) {
            my $time = time();

            @targets = $self->getTargets() unless @targets;
            my $target = shift @targets;

            $self->_reloadConfIfNeeded();

            if ($time >= $target->getNextRunDate()) {

                my $net_error = 0;
                eval {
                    $net_error = $self->_runTarget($target);
                };
                $self->{logger}->error($EVAL_ERROR) if $EVAL_ERROR;
                if ($net_error) {
                    # Prefer to retry early on net error
                    $target->setNextRunDateFromNow(60);
                } else {
                    $target->resetNextRunDate();
                }

                # Leave immediately if we passed in terminate method
                last unless $self->getTargets();

                # Call service optimization after each target run
                $self->RunningServiceOptimization();
            }

            if ($self->{server}) {
                # check for http interface messages, default timeout is 1 second
                $self->{server}->handleRequests() or delay(1);
            } else {
                delay(1);
            }
        }
    } else {

        $self->{logger}->debug2("Running in foreground mode");

        # foreground mode: check each targets once
        my $time = time();
        while ($self->getTargets() && @targets) {
            my $target = shift @targets;
            if ($self->{config}->{lazy} && $time < $target->getNextRunDate()) {
                $self->{logger}->info(
                    "$target->{id} is not ready yet, next server contact " .
                    "planned for " . localtime($target->getNextRunDate())
                );
                next;
            }

            eval {
                $self->_runTarget($target);
            };
            $self->{logger}->error($EVAL_ERROR) if $EVAL_ERROR;

            # Reset next run date to support --lazy option with foreground mode
            $target->resetNextRunDate();
        }
    }
}

sub terminate {
    my ($self) = @_;

    # Forget our targets
    $self->{targets} = [];

    # Kill current running task
    if ($self->{current_runtask}) {
        kill 'TERM', $self->{current_runtask};
        delete $self->{current_runtask};
    }

    $self->{logger}->info("$PROVIDER Agent exiting")
        if $self->{config}->{daemon} || $self->{config}->{service};
    $self->{current_task}->abort() if $self->{current_task};

    # Handle sigterm callback
    &{$self->{sigterm}}() if $self->{sigterm};
}

sub _runTarget {
    my ($self, $target) = @_;

    $self->{logger}->debug('_runTarget') if defined $self->{logger};
    # the prolog dialog must be done once for all tasks,
    # but only for server targets
    my $response;
    if ($target->isa('FusionInventory::Agent::Target::Server')) {
        my $client = FusionInventory::Agent::HTTP::Client::OCS->new(
            logger       => $self->{logger},
            timeout      => $self->{timeout},
            user         => $self->{config}->{user},
            password     => $self->{config}->{password},
            proxy        => $self->{config}->{proxy},
            ca_cert_file => $self->{config}->{'ca-cert-file'},
            ca_cert_dir  => $self->{config}->{'ca-cert-dir'},
            no_ssl_check => $self->{config}->{'no-ssl-check'},
            no_compress  => $self->{config}->{'no-compression'},
        );

        my $prolog = FusionInventory::Agent::XML::Query::Prolog->new(
            deviceid => $self->{deviceid},
        );

        $self->{logger}->info("sending prolog request to server $target->{id}");
        $response = $client->send(
            url     => $target->getUrl(),
            message => $prolog
        );
        unless ($response) {
            $self->{logger}->error("No answer from server at ".$target->getUrl());
            # Return true on net error
            return 1;
        }

        # update target
        my $content = $response->getContent();
        if (defined($content->{PROLOG_FREQ})) {
            $target->setMaxDelay($content->{PROLOG_FREQ} * 3600);
        }
    }

    foreach my $name (@{$self->{tasksExecutionPlan}}) {
        eval {
            $self->_runTask($target, $name, $response);
        };
        $self->{logger}->error($EVAL_ERROR) if $EVAL_ERROR;
        $self->{status} = 'waiting';

        # Leave earlier while requested
        last unless $self->getTargets();
    }

    return 0;
}

sub _runTask {
    my ($self, $target, $name, $response) = @_;

    $self->{status} = "running task $name";

    if ($self->{config}->{daemon} || $self->{config}->{service}) {
        # server mode: run each task in a child process
        if (my $pid = fork()) {
            # parent
            $self->{current_runtask} = $pid;
            while (waitpid($pid, WNOHANG) == 0) {
                if ($self->{server}) {
                    $self->{server}->handleRequests() or delay(1);
                } else {
                    delay(1);
                }

                # Leave earlier while requested
                last unless $self->getTargets();
            }
            delete $self->{current_runtask};
        } else {
            # child
            die "fork failed: $ERRNO" unless defined $pid;

            $self->{logger}->debug("forking process $PID to handle task $name");
            $self->_runTaskReal($target, $name, $response);
            exit(0);
        }
    } else {
        # standalone mode: run each task directly
        $self->_runTaskReal($target, $name, $response);
    }
}

sub _runTaskReal {
    my ($self, $target, $name, $response) = @_;

    my $class = "FusionInventory::Agent::Task::$name";

    $class->require();

    my $task = $class->new(
        config       => $self->{config},
        confdir      => $self->{confdir},
        datadir      => $self->{datadir},
        logger       => $self->{logger},
        target       => $target,
        deviceid     => $self->{deviceid},
    );

    return if !$task->isEnabled($response);

    $self->{logger}->info("running task $name");
    $self->{current_task} = $task;

    $task->run(
        user         => $self->{config}->{user},
        password     => $self->{config}->{password},
        proxy        => $self->{config}->{proxy},
        ca_cert_file => $self->{config}->{'ca-cert-file'},
        ca_cert_dir  => $self->{config}->{'ca-cert-dir'},
        no_ssl_check => $self->{config}->{'no-ssl-check'},
        no_compress  => $self->{config}->{'no-compression'},
    );
    delete $self->{current_task};
}

sub getStatus {
    my ($self) = @_;
    return $self->{status};
}

sub getTargets {
    my ($self) = @_;

    return @{$self->{targets}};
}

sub getAvailableTasks {
    my ($self, %params) = @_;

    my %tasks;
    my %disabled  = map { lc($_) => 1 } @{$params{disabledTasks}};

    # tasks may be located only in agent libdir
    my $directory = $self->{libdir};
    $directory =~ s,\\,/,g;
    my $subdirectory = "FusionInventory/Agent/Task";
    # look for all Version perl modules around here
    foreach my $file (File::Glob::glob("$directory/$subdirectory/*/Version.pm")) {
        next unless $file =~ m{($subdirectory/(\S+)/Version\.pm)$};
        my $module = file2module($1);
        my $name = file2module($2);

        next if $disabled{lc($name)};

        my $version;
        if ($self->{config}->{daemon} || $self->{config}->{service}) {
            # server mode: check each task version in a child process
            my ($reader, $writer);
            pipe($reader, $writer);
            $writer->autoflush(1);

            if (my $pid = fork()) {
                # parent
                close $writer;
                $version = <$reader>;
                close $reader;
                waitpid($pid, 0);
            } else {
                # child
                die "fork failed: $ERRNO" unless defined $pid;

                close $reader;
                $version = $self->_getTaskVersion($module);
                print $writer $version if $version;
                close $writer;
                exit(0);
            }
        } else {
            # standalone mode: check each task version directly
            $version = $self->_getTaskVersion($module);
        }

        # no version means non-functionning task
        next unless $version;

        $tasks{$name} = $version;
        if (defined $self->{logger}) {
            $self->{logger}->debug2( "getAvailableTasks() : add of task ".$name.' version '.$version );
        }
    }

    return %tasks;
}

sub _getTaskVersion {
    my ($self, $module) = @_;

    my $logger = $self->{logger};

    if (!$module->require()) {
        $logger->debug2("module $module does not compile: $@") if $logger;

        # Don't keep trace of module, only really needed to fix perl 5.8 issue
        delete $INC{module2file($module)};

        return;
    }

    my $version;
    {
        no strict 'refs';  ## no critic
        $version = &{$module . '::VERSION'};
    }

    return $version;
}

sub _isAlreadyRunning {
    my ($self, $pidfile) = @_;

    Proc::PID::File->require();
    if ($EVAL_ERROR) {
        $self->{logger}->debug(
            'Proc::PID::File unavailable, unable to check for running agent'
        );
        return 0;
    }

    my $pid = Proc::PID::File->new();
    $pid->{path} = $pidfile;
    return $pid->alive();
}

sub _loadState {
    my ($self) = @_;

    my $data = $self->{storage}->restore(name => "$PROVIDER-Agent");

    $self->{deviceid} = $data->{deviceid} if $data->{deviceid};
}

sub _saveState {
    my ($self) = @_;

    $self->{storage}->save(
        name => "$PROVIDER-Agent",
        data => {
            deviceid => $self->{deviceid},
        }
    );
}

# compute an unique agent identifier, based on host name and current time
sub _computeDeviceId {
    my $hostname = getHostname();

    my ($year, $month , $day, $hour, $min, $sec) =
        (localtime (time))[5, 4, 3, 2, 1, 0];

    return sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
        $hostname, $year + 1900, $month + 1, $day, $hour, $min, $sec;
}

sub _appendElementsNotAlreadyInList {
    my ($list, $elements, $logger) = @_;

    if (! UNIVERSAL::isa($list, 'ARRAY')) {
        $logger->error('_appendElementsNotAlreadyInList(): first argument is not an ARRAY ref') if defined $logger;
        return $list;
    }
    if (UNIVERSAL::isa($elements, 'HASH')) {
        @$elements = keys %$elements;
    } elsif (! UNIVERSAL::isa($elements, 'ARRAY')) {
        $logger->error('_appendElementsNotAlreadyInList(): second argument is neither an ARRAY ref nor a HASH ref') if defined $logger;
        return $list;
    }

    my %list = map { $_ => $_ } @$list;
    # we want to add elements only once, so we ensure that there are no duplicates
    my %elements = map { $_ => 1 } @$elements;
    @$elements = keys %elements;

    # union of list AND elements which are NOT in list
    my @newList = (@$list, grep( !defined($list{$_}), @$elements));

    return @newList;
}

sub computeTaskExecutionPlan {
    my ($self, $availableTasksNames) = @_;

    if (! defined($self->{config}) || !(UNIVERSAL::isa($self->{config}, 'FusionInventory::Agent::Config'))) {
        $self->{logger}->error( "no config found in agent. Can't compute tasks execution plan" ) if (defined $self->{logger});
        return;
    }

    my @executionPlan = ();
    if ($self->{config}->isParamArrayAndFilled('tasks')) {
        $self->{logger}->debug2('isParamArrayAndFilled(\'tasks\') : true') if (defined $self->{logger});
        @executionPlan = _makeExecutionPlan($self->{config}->{'tasks'}, $availableTasksNames, $self->{logger});
    } else {
        $self->{logger}->debug2('isParamArrayAndFilled(\'tasks\') : false') if (defined $self->{logger});
        @executionPlan = @$availableTasksNames;
    }

    return @executionPlan;
}

sub _makeExecutionPlan {
    my ($sortedTasks, $availableTasksNames, $logger) = @_;

    my $sortedTasksCloned = dclone $sortedTasks;
    my @executionPlan = ();
    my %available = map { (lc $_) => $_ } @$availableTasksNames;

    my $task = shift @$sortedTasksCloned;
    while (defined $task) {
        if ($task eq $CONTINUE_WORD) {
            last;
        }
        $task = lc $task;
        if ( defined($available{$task})) {
            push @executionPlan, $available{$task};
        }
        $task = shift @$sortedTasksCloned;
    }
    if ( defined($task) && $task eq $CONTINUE_WORD) {
        # we append all other available tasks
        @executionPlan = _appendElementsNotAlreadyInList(\@executionPlan, $availableTasksNames, $logger);
    }

    return @executionPlan;
}

sub getTasksExecutionPlan {
    my ($self) = @_;

    return $self->{tasksExecutionPlan};
}

sub _createTargets {
    my ($self) = @_;

    my $config = $self->{config};
    # create target list
    if ($config->{local}) {
        foreach my $path (@{$config->{local}}) {
            push @{$self->{targets}},
                FusionInventory::Agent::Target::Local->new(
                    logger     => $self->{logger},
                    deviceid   => $self->{deviceid},
                    delaytime  => $config->{delaytime},
                    basevardir => $self->{vardir},
                    path       => $path,
                    html       => $config->{html},
                );
        }
    }

    if ($config->{server}) {
        foreach my $url (@{$config->{server}}) {
            push @{$self->{targets}},
                FusionInventory::Agent::Target::Server->new(
                    logger     => $self->{logger},
                    deviceid   => $self->{deviceid},
                    delaytime  => $config->{delaytime},
                    basevardir => $self->{vardir},
                    url        => $url,
                    tag        => $config->{tag},
                );
        }
    }
}

sub _createDaemon {
    my ($self) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $pidfile  = $config->{pidfile} ||
        $self->{vardir} . '/'.lc($PROVIDER).'.pid';
    if ($self->_isAlreadyRunning($pidfile)) {
        $logger->error("An agent is already running, exiting...");
        exit 1;
    }
    if (!$config->{'no-fork'}) {

        Proc::Daemon->require();
        if ($EVAL_ERROR) {
            $logger->error("Failed to load Proc::Daemon: $EVAL_ERROR");
            exit 1;
        }

        # If we use relative path, we must stay in the current directory
        my $workdir = substr($self->{libdir}, 0, 1) eq '/' ? '/' : getcwd();

        Proc::Daemon::Init({
                work_dir => $workdir,
                    pid_file => $pidfile
            });

        $self->{logger}->debug("Agent daemonized");
    }
}

sub _createHttpInterface {
    my ($self) = @_;

    my $logger = $self->{logger};
    my $config = $self->{config};
    FusionInventory::Agent::HTTP::Server->require();
    if ($EVAL_ERROR) {
        $logger->error("Failed to load HTTP server: $EVAL_ERROR");
    } else {
        $self->{server} = FusionInventory::Agent::HTTP::Server->new(
            logger          => $logger,
            agent           => $self,
            htmldir         => $self->{datadir} . '/html',
            ip              => $config->{'httpd-ip'},
            port            => $config->{'httpd-port'},
            trust           => $config->{'httpd-trust'}
        );
        $self->{server}->init();
    }
}

sub _installSignalHandlers {
    my ($self) = @_;

    $SIG{INT}     = sub { $self->terminate(); exit 0; };
    $SIG{TERM}    = sub { $self->terminate(); exit 0; };
}

sub _reloadConfIfNeeded {
    my ($self) = @_;

    if ($self->_isReloadConfNeeded()) {
        $self->{logger}->debug2('_reloadConfIfNeeded() is true, init agent now...');
        $self->reinit();
    }
}

sub _isReloadConfNeeded {
    my ($self) = @_;

    my $time = time;
    #$self->{logger}->debug2('_isReloadConfNeeded : ' . $self->{lastConfigLoad} . ' - ' . $time . ' > ' . $self->{config}->{'conf-reload-interval'} . ' ?');
    return ($self->{config}->{'conf-reload-interval'} > 0) && (($time - $self->{lastConfigLoad}) > $self->{config}->{'conf-reload-interval'});
}

1;
__END__

=head1 NAME

FusionInventory::Agent - FusionInventory agent

=head1 DESCRIPTION

This is the agent object.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<confdir>

the configuration directory.

=item I<datadir>

the read-only data directory.

=item I<vardir>

the read-write data directory.

=item I<options>

the options to use.

=back

=head2 init()

Initialize the agent.

=head2 run()

Run the agent.

=head2 terminate()

Terminate the agent.

=head2 getStatus()

Get the current agent status.

=head2 getTargets()

Get all targets.

=head2 getAvailableTasks()

Get all available tasks found on the system, as a list of module / version
pairs:

%tasks = (
    'Foo' => x,
    'Bar' => y,
);

=head1 LICENSE

This software is licensed under the terms of GPLv2+, see LICENSE file for
details.
