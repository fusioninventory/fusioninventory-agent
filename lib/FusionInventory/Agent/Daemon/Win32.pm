package FusionInventory::Agent::Daemon::Win32;

use strict;
use warnings;

use threads;
use threads 'exit' => 'threads_only';

use File::Spec;
use Cwd qw(abs_path);

use constant SERVICE_SLEEP_TIME => 200; # in milliseconds

use Win32;
use Win32::Daemon;

use FusionInventory::Agent::Version;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Tools::Win32;

use parent qw(FusionInventory::Agent::Daemon);

my $PROVIDER = $FusionInventory::Agent::Version::PROVIDER;

sub SERVICE_NAME        { lc($PROVIDER) . "-agent"; }
sub SERVICE_DISPLAYNAME { "$PROVIDER Agent"; }

my %default_callbacks = (
    start       => \&cb_start,
    timer       => \&cb_running,
    stop        => \&cb_stop,
    shutdown    => \&cb_shutdown,
    interrogate => \&cb_interrogate
);

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{last_state} = SERVICE_START_PENDING;

    bless $self, $class;

    return $self;
}

sub name  {
    my ($self, $name) = @_;

    $self->{_name} = $name if $name;

    return $self->{_name} || SERVICE_NAME;
}

sub displayname  {
    my ($self, $displayname) = @_;

    $self->{_displayname} = $displayname if $displayname;

    return $self->{_displayname} || SERVICE_DISPLAYNAME;
}

sub RegisterService {
    my ($self, %options) = @_;

    my $libdir = $options{libdir} || $self->{libdir} ;
    my $params = '"' . $options{program} . '"';

    # Try to compute libdir from this module file if still not absolute
    $libdir = abs_path(File::Spec->rel2abs('../../../../..', __FILE__))
        unless ($libdir && File::Spec->file_name_is_absolute($libdir) && -d $libdir);

    # Add path to lib if setup
    $params = '-I"' . $libdir . '" ' . $params
        if ($libdir && -d $libdir);

    my $service = {
        name       => $self->name( $options{name} ),
        display    => $self->displayname( $options{displayname} ),
        path       => "$^X",
        parameters => $params
    };

    if (!Win32::Daemon::CreateService($service)) {
        my $lasterr = Win32::Daemon::GetLastError();
        if ($lasterr == 1073) {
            warn "Service still registered\n";

        } elsif ($lasterr == 1072) {
            warn "Service marked for deletion.\n" .
                "Computer must be rebooted to register the same service name\n";
            return 1;

        } else {
            my $error = Win32::FormatMessage($lasterr);
            warn "Service not registered: $lasterr: $error\n";
            return 2;
        }
    }

    return 0;
}

sub DeleteService {
    my ($self, %options) = @_;

    if (!Win32::Daemon::DeleteService("",$self->name( $options{name} ))) {
        my $lasterr = Win32::Daemon::GetLastError();
        if ($lasterr == 1060) {
            warn "Service not found\n";

        } elsif ($lasterr == 1072) {
            warn "Service still marked for deletion. Computer must be rebooted\n";
            return 1;

        } else {
            my $error = Win32::FormatMessage($lasterr);
            warn "Service not removed $lasterr: $error\n";
            return 2;
        }
    }

    return 0;
}

sub RegisterCallbacks {
    my ($self, $callbacks) = @_;

    $callbacks = {} unless (defined($callbacks));

    # Use default callback while not set
    foreach my $callback (keys(%default_callbacks)) {
        next if $callbacks->{$callback};
        $callbacks->{$callback} = $default_callbacks{$callback};
    }

    # Finally register callbacks using Win32::Daemon API
    Win32::Daemon::RegisterCallbacks($callbacks);
}

sub StartService {
    my ($self, $delay_ms) = @_;

    # Use default service timer if necessary
    $delay_ms = SERVICE_SLEEP_TIME
        unless ( $delay_ms && $delay_ms>= 20 );

    Win32::Daemon::StartService($self, $delay_ms);
}

sub AcceptedControls {
    my ($self, $controls) = @_;

    $controls = SERVICE_ACCEPT_STOP | SERVICE_ACCEPT_SHUTDOWN
        unless $controls;

    Win32::Daemon::AcceptedControls($controls);
}

sub cb_start {
    my( $event, $service ) = @_;

    # Start service dedicated thread only if required
    unless ($service->{agent_thread}) {
        # First start a thread dedicated to Win32::OLE calls
        FusionInventory::Agent::Tools::Win32::start_Win32_OLE_Worker();

        # Start agent in a dedicated thread
        $service->{agent_thread} = threads->create(sub {
            $service->init(options => { service => 1 });
            $service->run()
        });
    }

    Win32::Daemon::CallbackTimer(SERVICE_SLEEP_TIME);

    $service->{last_state} = SERVICE_RUNNING;

    Win32::Daemon::State(SERVICE_RUNNING);
}

sub cb_running {
    my( $event, $service ) = @_;

    if (!$service->{agent_thread}) {
        if ($service->{last_state} == SERVICE_STOP_PENDING) {
            $service->{last_state} = SERVICE_STOPPED;
            Win32::Daemon::State(SERVICE_STOPPED);
            Win32::Daemon::StopService();
        } else {
            Win32::Daemon::State($service->{last_state});
        }

    } elsif (!$service->{agent_thread}->is_running()) {
        if ($service->{agent_thread}->is_joinable()) {
            $service->{agent_thread}->join();

            delete $service->{agent_thread};

            $service->{last_state} = SERVICE_STOPPED;
            Win32::Daemon::State(SERVICE_STOPPED);
            Win32::Daemon::StopService();
        } else {
            $service->{last_state} = SERVICE_STOP_PENDING;
            Win32::Daemon::State(SERVICE_STOP_PENDING);
        }

    } else {
        Win32::Daemon::State($service->{last_state});
    }
}

sub cb_stop {
    my( $event, $service ) = @_;

    if ($service->{agent_thread} && $service->{agent_thread}->is_running()) {
        $service->{agent_thread}->kill('SIGINT');
    }

    $service->{last_state} = SERVICE_STOP_PENDING;
    Win32::Daemon::State(SERVICE_STOP_PENDING, 10000);
}

sub cb_shutdown {
    my( $event, $service ) = @_;

    if ($service->{agent_thread} && $service->{agent_thread}->is_running()) {
        $service->{agent_thread}->kill('SIGTERM');
    }

    $service->{last_state} = SERVICE_STOP_PENDING;
    Win32::Daemon::State(SERVICE_STOP_PENDING, 25000);
}

sub cb_interrogate {
    my( $event, $service ) = @_;

    Win32::Daemon::State($service->{last_state});
}

sub ApplyServiceOptimizations {
    my ($self) = @_;

    $self->SUPER::ApplyServiceOptimizations();

    # Win32 only service optimization

    # Preload is64bit result to avoid a lot of WMI calls
    is64bit();
}

sub RunningServiceOptimization {
    my ($self) = @_;

    # win32 platform needs optimization
    if ($self->{logger}->{verbosity} >= LOG_DEBUG) {
        my $runmem = getAgentMemorySize();
        $self->{logger}->debug("Agent memory usage before freeing memory: $runmem");
    }

    # Free some memory
    FreeAgentMem();

    my $current_mem = getAgentMemorySize();
    $self->{logger}->info("$PROVIDER Agent memory usage: $current_mem");
}

sub terminate {
    my ($self) = @_;

    $self->SUPER::terminate();

    threads->exit();
}

1;
