package FusionInventory::Agent::Target;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Storage;
use FusionInventory::Logger;

use POE;

sub new {
    my ($class, $params) = @_;

    die 'no basevardir parameter' unless $params->{basevardir};

    my $self = {
        maxOffset       => $params->{maxOffset} || 3600,
        logger          => $params->{logger} || FusionInventory::Logger->new(),
        deviceid        => $params->{deviceid},
        config          => $params->{config},
        nextRunDate     => undef,
    };
    bless $self, $class;

    return $self;
}

sub _init {
    my ($self, $params) = @_;

    # target identity
    $self->{id} = $params->{id};

    # target storage
    $self->{storage} = FusionInventory::Agent::Storage->new({
        logger    => $self->{logger},
        directory => $params->{vardir}
    });

    # restore previous state
    $self->_loadState();

    # initialize next run date if needed
    $self->scheduleNextRun() unless $self->getNextRunDate();
}

sub getStorage {
    my ($self) = @_;

    return $self->{storage};
}

sub getNextRunDate {
    my ($self) = @_;

    return $self->{nextRunDate};
}

sub setNextRunDate {
    my ($self, $nextRunDate) = @_;

    $self->{nextRunDate} = $nextRunDate;
}

sub scheduleNextRun {
    my ($self, $offset) = @_;

    if (! defined $offset) {
        $offset = ($self->{maxOffset} / 2) + int rand($self->{maxOffset} / 2);
    }
    my $time = time() + $offset;
    $self->setNextRunDate($time);

    $self->{logger}->debug(
        "[target $self->{id}]" . 
        defined $offset ?
            "Next run scheduled for " . localtime($time + $offset) :
            "Next run forced now"
    );

}

sub getMaxOffset {
    my ($self) = @_;

    return $self->{maxOffset};
}

sub setMaxOffset {
    my ($self, $maxOffset) = @_;

    $self->{maxOffset} = $maxOffset;
}

sub _loadState {
    my ($self) = @_;

    my $data = $self->{storage}->restore();
    $self->{nextRunDate} = $data->{nextRunDate} if $data->{nextRunDate};
    $self->{maxOffset}   = $data->{maxOffset} if $data->{maxOffset};
}

sub saveState {
    my ($self) = @_;

    $self->{storage}->save({
        data => {
            nextRunDate => $self->{nextRunDate},
            maxOffset   => $self->{maxOffset},
        }
    });
}

sub createSession {
    my ($self) = @_;

    $self->{session} = POE::Session->create(
        inline_states => {
            _start => sub {
                print "_start...\n";
                $_[KERNEL]->yield("setAlarm");
            },
            setAlarm => sub {
                print "setAlarm\n";
                if ($_[HEAP]{alarm_id}) {
                    $_[KERNEL]->alarm_remove($_[HEAP]{alarm_id});
                }
                my $nextRunDate = $self->getNextRunDate();
                $_[HEAP]{alarm_id} = $_[KERNEL]->alarm_set(callRun => $nextRunDate);
                print "Next launch planned for ".localtime($nextRunDate)."\n";
            },
            callRun => sub {
                $self->runTarget({ target => $self });
                $self->scheduleNextRun();
                $_[KERNEL]->yield("setAlarm");
            },
            runNow => sub {
                print "runNow\n";
                if ($_[HEAP]{alarm_id}) {
                    $_[KERNEL]->alarm_remove($_[HEAP]{alarm_id});
                }
                $self->runTarget({ target => $self });
                $self->scheduleNextRun();
                $_[KERNEL]->yield("setAlarm");
            } 
        },
    );

}


sub runTarget {
    my ($self, $params) = @_;

    print "runTarget\n";
    my $config = $self->{config};
    my $logger = $self->{logger};
    my $target = $params->{target};

    eval {
        $self->{status} = 'waiting';

        my $prologresp;
        my $transmitter;
        if ($self->isa('FusionInventory::Agent::Target::Server')) {

            $transmitter = FusionInventory::Agent::Transmitter->new({
                    logger       => $logger,
                    url          => $self->{url},
                    proxy        => $config->{proxy},
                    user         => $config->{user},
                    password     => $config->{password},
                    no_ssl_check => $config->{'no-ssl-check'},
                    ca_cert_file => $config->{'ca-cert-file'},
                    ca_cert_dir  => $config->{'ca-cert-dir'},
                });

                my $prolog = FusionInventory::Agent::XML::Query::Prolog->new({
                    logger   => $logger,
                    deviceid => $self->{deviceid},
                    token    => $self->{token}
                });

            if ($config->{tag}) {
                $prolog->setAccountInfo({'TAG', $config->{tag}});
            }

            # TODO Don't mix settings and temp value
            $prologresp = $transmitter->send({message => $prolog});

            if (!$prologresp) {
                $logger->error("No anwser from the server");
                $self->scheduleNextRun();
                next;
            }
        }

        my @tasks = qw/
            Inventory
            OcsDeploy
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
                    target      => $self,
                    prologresp  => $prologresp,
                    transmitter => $transmitter,
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
                    if ($task->can('run')) {
                        $task->run();
                    } else {
                        $logger->info(
                            "[task] $module use deprecated interface"
                        );
                        $task->main();
                    }
                    $logger->debug("[task] end of $module");
                }
            } else {
                # standalone mode: run each task directly
                $logger->debug("[task] executing $module");
                if ($task->can('run')) {
                    $task->run();
                } else {
                    # old interface
                    $logger->info(
                        "[task] $module use deprecated interface"
                    );
                    $task->main();
                }
                $logger->debug("[task] end of $module");
            }
            $self->{status} = 'waiting';

            $target->scheduleNextRun();

            $target->saveState();

            sleep(5);
        }
        $target->scheduleNextRun();

    };
    if ($EVAL_ERROR) {
        $logger->fault($EVAL_ERROR);
        exit 1;
    }
}




1;

__END__

=head1 NAME

FusionInventory::Agent::Target - Abstract target

=head1 DESCRIPTION

This is an abstract class for execution targets.

=head1 METHODS

=head2 new($params)

The constructor. The following parameters are allowed, as keys of the $params
hashref:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<maxOffset>

the maximum delay in seconds when rescheduling the target randomly
(default: 3600)

=item I<nextRunDate>

the next execution date, as a unix timestamp

=item I<basevardir>

the base directory of the storage area (mandatory)

=back

=head2 getMaxOffset()

Get maxOffset attribute.

=head2 setMaxOffset($maxOffset)

Set maxOffset attribute.

=head2 getNextRunDate()

Get nextRunDate attribute.

=head2 setNextRunDate($nextRunDate)

Set nextRunDate attribute.

=head2 scheduleNextRun($offset)

Re-schedule the target to current time + given offset. If offset is not given,
it's computed randomly as: (maxOffset / 2) + rand(maxOffset / 2)

=head2 getStorage()

Return the storage object for this target.

=head2 saveState()

Save persistant part of current state.

=head2 runTarget()

Run the tasks (inventory, snmp scan, etc) on the target

=head2 getDescriptionString()

Return a string to display to user in a 'target' field.

