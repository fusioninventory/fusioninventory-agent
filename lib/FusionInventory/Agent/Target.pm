package FusionInventory::Agent::Target;

use strict;
use warnings;
use threads;
use threads::shared;

use Carp;
use English qw(-no_match_vars);
use File::Path qw(make_path);

use FusionInventory::Agent::JobEngine;

use POE;

# resetNextTaskStartupDate() can also be call from another thread (RPC)
my $lock :shared;

sub new {
    my ($class, $params) = @_;

    if ($params->{type} !~ /^(server|local|stdout)$/ ) {
        croak 'bad type';
    }

    my $self = {
        config          => $params->{config},
        logger          => $params->{logger},
        type            => $params->{type},
        path            => $params->{path} || '',
        deviceid        => $params->{deviceid},
        debugPrintTimer => 0
    };
    bless $self, $class;

    lock($lock);

    $self->{nextTaskStartupDate} = {};

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $type   = $self->{type};


    $self->{format} = $self->{type} eq 'local' && $config->{html} ?
        'HTML' : 'XML';

    $self->init();

    $self->{storage} = FusionInventory::Agent::Storage->new({
        target => $self
    });

    $self->{enabledTaskList} = [ 'Inventory', 'WakeOnLan', 'Ping' ];

    my $storage = $self->{storage};
    if ($self->{type} eq 'server') {
        $self->{accountinfo} = FusionInventory::Agent::AccountInfo->new({
            logger => $logger,
            config => $config,
            storage => $storage,
            target => $self,
        });
    
        my $accountinfo = $self->{accountinfo};

        if ($config->{tag}) {
            if ($accountinfo->get("TAG")) {
                $logger->debug(
                    "A TAG seems to already exist in the server for this ".
                    "machine. The -t paramter may be ignored by the server " .
                    "unless it has OCS_OPT_ACCEPT_TAG_UPDATE_FROM_CLIENT=1."
                );
            }
            $accountinfo->set("TAG", $config->{tag});
        }

        my $storage = $self->{storage};
        $self->{myData} = $storage->restore();

        if (ref($self->{myData}{nextTaskStartupDate}) eq 'HASH') {
            ${$self->{nextTaskStartupDate}} = $self->{myData}{nextTaskStartupDate};
        }
    }

    foreach my $taskName (@{$self->{enabledTaskList}}) {
        $self->createAlarm ({
                taskName => $taskName
            });
    }





    return $self;
}

sub init {
    my ($self) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};

    lock($lock);

    # The agent can contact different servers. Each server has it's own
    # directory to store data

    my $dir;
    if ($self->{type} eq 'server') {
        $dir = $self->{path};
        $dir =~ s/\//_/g;
        # On Windows, we can't have ':' in directory path
        $dir =~ s/:/../g if $OSNAME eq 'MSWin32';
    } else {
        $dir = '__LOCAL__';

    }
    $self->{vardir} = $config->{basevardir} . '/' . $dir;

    if (!-d $self->{vardir}) {
        make_path($self->{vardir}, {error => \my $err});
        if (@$err) {
            $logger->error("Failed to create $self->{vardir}");
        }
    }

    if (! -w $self->{vardir}) {
        croak "Can't write in $self->{vardir}";
    }

    $logger->debug("storage directory: $self->{vardir}");

    $self->{accountinfofile} = $self->{vardir} . "/ocsinv.adm";
    $self->{last_statefile} = $self->{vardir} . "/last_state";
}

sub setNextTaskStartupDate {

    my ($self, $args) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $storage = $self->{storage};
    my $taskName = $args->{taskName};


    if (!$taskName) {
        $logger->fault("setNextTaskStartupDate: taskName parameter is missing");
    }

    lock($lock);

    # taskFreq: is like the PROLOG_FREQ but for every task
    # it's the number max of minute between two call of the task
    my $taskFreq = $self->{myData}{taskFreq}{$taskName};

    lock($lock);

    my $max;
    if ($taskFreq) {
        $max = $taskFreq;
    } else {
        $max = $config->{delaytime};
        # If the PROLOG_FREQ has never been initialized, we force it at 1h
#        $self->setPrologFreq(1);
    }
    $max = 3600 unless $max;

    my $time = time + ($max/2) + int rand($max/2);

    $self->{myData}{nextTaskStartupDate}{$taskName} = $time;
    
    $self->{nextTaskStartupDate}{$taskName} = $self->{myData}{nextTaskStartupDate}{$taskName};

    $logger->debug (
        "[$self->{path}] Next server contact'd just been planned for ".
        localtime($self->{myData}{nextTaskStartupDate}{$taskName})
    );

    $storage->save({ data => $self->{myData} });
}

sub getNextTaskStartupDate {
    my ($self, $args) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $taskName = $args->{taskName};


    if (!$taskName) {
        $logger->fault("setNextTaskStartupDate: task parameter is missing");
    }

    lock($lock);

    if ($self->{nextTaskStartupDate}{$taskName}) {
      
        if ($self->{debugPrintTimer} < time) {
            $self->{debugPrintTimer} = time + 600;
        }; 

        return ${$self->{nextTaskStartupDate}{$taskName}};
    }

    $self->setNextTaskStartupDate({ taskName => $taskName });

    if (!$self->{nextTaskStartupDate}{$taskName}) {
        croak 'nextTaskStartupDate not set!';
    }

    return $self->{myData}{nextTaskStartupDate}{$taskName};

}

sub resetNextTaskStartupDate {
    my ($self) = @_;

    my $logger = $self->{logger};
    my $storage = $self->{storage};

    lock($lock);
    $logger->debug("Force run now");
    
    $self->{myData}{nextTaskStartupDate} = 1;
    $storage->save({ data => $self->{myData} });
    
    ${$self->{nextTaskStartupDate}} = $self->{myData}{nextTaskStartupDate};
}

sub setPrologFreq {

    my ($self, $prologFreq) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $storage = $self->{storage};

    return unless $prologFreq;

    if ($self->{myData}{prologFreq} && ($self->{myData}{prologFreq}
            eq $prologFreq)) {
        return;
    }
    if (defined($self->{myData}{prologFreq})) {
        $logger->info(
            "PROLOG_FREQ has changed since last process ". 
            "(old=$self->{myData}{prologFreq},new=$prologFreq)"
        );
    } else {
        $logger->info("PROLOG_FREQ has been set: $prologFreq");
    }

    $self->{myData}{prologFreq} = $prologFreq;
    $storage->save({ data => $self->{myData} });

}

sub setCurrentDeviceID {

    my ($self, $deviceid) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $storage = $self->{storage};

    return unless $deviceid;

    if ($self->{myData}{currentDeviceid} &&
        ($self->{myData}{currentDeviceid} eq $deviceid)) {
        return;
    }

    if (!$self->{myData}{currentDeviceid}) {
        $logger->debug("DEVICEID initialized at $deviceid");
    } else {
        $logger->info(
            "DEVICEID has changed since last process ". 
            "(old=$self->{myData}{currentDeviceid},new=$deviceid"
        );
    }

    $self->{myData}{currentDeviceid} = $deviceid;
    $storage->save({ data => $self->{myData} });
}

sub createAlarm {
    my ($self, $args) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $taskName = $args->{taskName};

    my $nextTaskStartupDate = $self->getNextTaskStartupDate({ taskName => $taskName });
    $logger->debug("$taskName will be launched @ ".localtime($nextTaskStartupDate));
    POE::Session->create(
        inline_states => {
            _start => sub {
                $_[KERNEL]->alarm( start => $nextTaskStartupDate, 'server1', $taskName );
            },
            start => sub {
                print "Time up\n";
#                $_[KERNEL]->post( 'jobEngine', 'start', $self );
#                $_[KERNEL]->alarm( start => $self->getNextTaskStartupDate(), 'server1' );
                my $jobEngine = FusionInventory::Agent::JobEngine->new({
                        config => $config,
                        logger => $logger,
                        target => $self,
                        taskName => $taskName
                    });
                $jobEngine->run();
                print "engine Started!\n";
            }
        });





}

1;
