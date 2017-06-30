package FusionInventory::Agent;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;
use File::Glob;
use IO::Handle;
use Storable 'dclone';

use FusionInventory::Agent::Version;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::HTTP::Client::OCS;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Target::Local;
use FusionInventory::Agent::Target::Server;
use FusionInventory::Agent::Tools;
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

    # Rename process, mostly for unix platforms
    $0 = lc($PROVIDER) . "-agent";
    $0 .= " (tag $config->{tag})" if $config->{tag};

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

    if ($config->{daemon} || $config->{service}) {
        FusionInventory::Agent::Daemon->require();
        if ($EVAL_ERROR) {
            $logger->error("Failed to create FusionInventory::Agent::Daemon: $EVAL_ERROR");
            exit 1;
        }

        # Inherit from dedicated run, runTask & terminate methods
        bless $self, "FusionInventory::Agent::Daemon";

        $logger->info("$PROVIDER Agent starting");

        $self->createDaemon();

        # create HTTP interface if required
        $self->loadHttpInterface();

        $self->ApplyServiceOptimizations();
    }

    # install signal handler to handle graceful exit
    $self->_installSignalHandlers();

    $logger->info("Options 'no-task' and 'tasks' are both used. Be careful that 'no-task' always excludes tasks.")
        if ($self->{config}->isParamArrayAndFilled('no-task') && $self->{config}->isParamArrayAndFilled('tasks'));

    foreach my $comment (@{$COMMENTS}) {
        $logger->info($comment);
    }

    $self->resetLastConfigLoad();
}

sub reinit {
    my ($self) = @_;

    $self->{logger}->debug('agent reinit');

    $self->{config}->reloadFromInputAndBackend($self->{confdir});

    my $config = $self->{config};

    # Rename process, mostly for unix platforms
    $0 = lc($PROVIDER) . "-agent";
    $0 .= " (tag $config->{tag})" if $config->{tag};

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

    $self->resetLastConfigLoad();

    $self->{logger}->debug('agent reinit done.');
}

sub resetLastConfigLoad {
    my ($self) = @_;

    $self->{lastConfigLoad} = time;
}

sub run {
    my ($self) = @_;

    # API overrided in daemon or service mode

    $self->{status} = 'waiting';

    my @targets = $self->getTargets();

    $self->{logger}->debug("Running in foreground mode");

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
            $self->runTarget($target);
        };
        $self->{logger}->error($EVAL_ERROR) if $EVAL_ERROR;

        # Reset next run date to support --lazy option with foreground mode
        $target->resetNextRunDate();
    }
}

sub terminate {
    my ($self) = @_;

    # Forget our targets
    $self->{targets} = [];

    # Abort realtask running in that forked process or thread
    $self->{current_task}->abort()
        if ($self->{current_task});

    # Kill current forked task
    if ($self->{current_runtask}) {
        kill 'TERM', $self->{current_runtask};
        delete $self->{current_runtask};
    }

}

sub runTarget {
    my ($self, $target) = @_;

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
            $self->runTask($target, $name, $response);
        };
        $self->{logger}->error($EVAL_ERROR) if $EVAL_ERROR;
        $self->{status} = 'waiting';

        # Leave earlier while requested
        last unless $self->getTargets();
    }

    return 0;
}

sub runTask {
    my ($self, $target, $name, $response) = @_;

    # API overrided in daemon or service mode

    $self->{status} = "running task $name";

    # standalone mode: run each task directly
    $self->runTaskReal($target, $name, $response);
}

sub runTaskReal {
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

    my $logger = $self->{logger};

    my %tasks;
    my %disabled  = map { lc($_) => 1 } @{$params{disabledTasks}};

    # tasks may be located only in agent libdir
    my $directory = $self->{libdir};
    $directory =~ s,\\,/,g;
    my $subdirectory = "FusionInventory/Agent/Task";
    # look for all Version perl modules around here
    foreach my $file (File::Glob::bsd_glob("$directory/$subdirectory/*/Version.pm")) {
        next unless $file =~ m{($subdirectory/(\S+)/Version\.pm)$};
        my $module = file2module($1);
        my $name = file2module($2);

        next if $disabled{lc($name)};

        my $version;
        if (!$module->require()) {
            $logger->debug2("module $module does not compile: $@") if $logger;

            # Don't keep trace of module, only really needed to fix perl 5.8 issue
            delete $INC{module2file($module)};

            next;
        }

        {
            no strict 'refs';  ## no critic
            $version = &{$module . '::VERSION'};
        }

        # no version means non-functionning task
        next unless $version;

        $tasks{$name} = $version;
        $logger->debug2("getAvailableTasks() : add of task $name version $version")
            if $logger;
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
