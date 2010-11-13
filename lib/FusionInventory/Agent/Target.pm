package FusionInventory::Agent::Target;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Storage;

use POE;
use POE::Wheel::Run;

sub new {
    my ($class, $params) = @_;

    die 'no basevardir parameter' unless $params->{basevardir};

    my $self = {
        maxOffset       => $params->{maxOffset} || 3600,
        logger          => $params->{logger},
        deviceid        => $params->{deviceid},
        config          => $params->{config},
        nextRunDate     => undef,
	# the list of module the target has to run now.
	modulenamesToRun    => [],
	modulenameRunning  => undef,
	class  => $class,
    };

    bless $self, $class;
    
    return $self;
}

sub _init {
    my ($self, $params) = @_;

    # target identity
    $self->{id} = $params->{id};
    $self->{vardir} = $params->{vardir};

    # target storage
    $self->{storage} = FusionInventory::Agent::Storage->new({
        logger    => $self->{logger},
        directory => $self->{vardir}
    });

    # restore previous state
    $self->_loadState();

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

    # initialize next run date if needed
    $self->scheduleNextRun() unless $self->getNextRunDate();

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
                $_[HEAP]{alarm_id} = $_[KERNEL]->alarm_set(runNow => $nextRunDate);
                $self->{logger}->info("Next launch planned for ".
                $self->getDescriptionString().
                " at ".
                localtime($nextRunDate));
            },
            runNow => sub {
                print "runNow\n";
                if ($_[HEAP]{alarm_id}) {
                    $_[KERNEL]->alarm_remove($_[HEAP]{alarm_id});
                }
                $self->run();
                $self->scheduleNextRun();
                $_[KERNEL]->yield("setAlarm");
            } 
        },
    );

}


sub run {
    my ($self, $params) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $target = $params->{target};

    POE::Session->create(
        inline_states => {
            _start => sub {
	    # We use the target alias to identify the target who is running
	    # task. So if from the task I request throught the IKC interface
	    # target/get/something, I will get the information from the running
	    # target.
                $_[KERNEL]->alias_set("target");
                $_[KERNEL]->yield('prolog');
                $self->{modulesToRun} = [ 'Inventory', 'Ping', 'WakeOnLan' ];
                $_[HEAP]->{target} = $target;

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
                    $_[HEAP]->{prologresp} = $transmitter->send({message => $prolog});

                    if (!$_[HEAP]->{prologresp}) {
                        $logger->error("No anwser from the server");
                        $target->setNextRunDate();
                        return;
                    }
                }

                $_[KERNEL]->yield('launchNextTask');

            },
	    get => sub {
		my ($kernel, $heap, $args) = @_[KERNEL, HEAP, ARG0, ARG1];
		my $req = $args->[0];
		my $rsvp = $args->[1];
#print "value: ".$self->{$req->{key}}."\n";
	    },
            launchNextTask  => sub {
                my $logger = $self->{logger};
                my $config = $self->{config};
                my $target = $_[HEAP]->{target};

                if(!@{$self->{modulesToRun}}) {
		    $_[KERNEL]->alias_remove("target");
		    print "remove target alias\n";
                    $self->scheduleNextRun();
		    $_[KERNEL]->post(scheduler => 'targetIsDone');
                    return;
                }

                $self->{modulenameRunning} = shift @{$self->{modulesToRun}};

                #print "Launching module ".$_[HEAP]->{runningModuleName}."\n";

                my $cmd;
                $cmd = "\"$EXECUTABLE_NAME\""; # The Perl binary path
                $cmd .= "  -Ilib" if $INC[0] eq './lib';
                $cmd .= " -MFusionInventory::Agent::Task::".$self->{modulenameRunning};
                $cmd .= " -e ".
                "\"FusionInventory::Agent::Task::".
                $self->{modulenameRunning}.
                "->main();\" --";
                $cmd .= " \"".
                $self->{modulenameRunning}."\"";

                my $child = POE::Wheel::Run->new(
                    Program => $cmd,
                    StdoutEvent  => "got_child_stdout",
                    StderrEvent  => "got_child_stderr",
                    CloseEvent   => "got_child_close",
                );

                $_[KERNEL]->sig_child($child->PID, "got_child_signal");

                # Wheel events include the wheel's ID.
                $_[HEAP]{children_by_wid}{$child->ID} = $child;

                # Signal events include the process ID.
                $_[HEAP]{children_by_pid}{$child->PID} = $child;

                print(
                    "Child pid ", $child->PID,
                    " started as wheel ", $child->ID, ".\n"
                );


            },
#            got_child_stdout => \&on_child_stdout,
            got_child_stderr => sub {
                my ($stderr_line, $wheel_id) = @_[ARG0, ARG1];

                my $logger = $self->{logger};

                my $child = $_[HEAP]{children_by_wid}{$wheel_id};
                if ($stderr_line =~ /^(debug|info|error|fault):\s(.*)/) {
		    $logger->$1("t) ".$2);
                } else {
                    $logger->error($stderr_line);
                }
            },
            got_child_stdout => sub {
                my ($line, $wheel_id) = @_[ARG0, ARG1];

                print "→ ".$line."\n";
            },
            got_child_close  => sub {
                my $wheel_id = $_[ARG0];
                my $child = delete $_[HEAP]{children_by_wid}{$wheel_id};

                # May have been reaped by on_child_signal().
                unless (defined $child) {
                    print "wid $wheel_id closed all pipes.\n";
                    return;
                }

                print "module: ".$self->{modulenameRunning}." finished\n";
                print "pid ", $child->PID, " closed all pipes.\n";
                delete $_[HEAP]{children_by_pid}{$child->PID};
		$self->{modulenameRunning} = undef;
                $_[KERNEL]->yield('launchNextTask');
            },
            got_child_signal => sub {
                    print "pid $_[ARG1] exited with status $_[ARG2].\n";
                    my $child = delete $_[HEAP]{children_by_pid}{$_[ARG1]};

                    # May have been reaped by on_child_close().
                    return unless defined $child;

                    delete $_[HEAP]{children_by_wid}{$child->ID};
                }


        }
    );



}






sub runFork {
    my ($self, $params) = @_;

    print "run\n";
    my $config = $self->{config};
    my $logger = $self->{logger};
    my $target = $self;

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


sub getStatusString {
    my ($self, $params) = @_;

    my $string = '';
    if ($self->{modulenameRunning}) {
	$string .= "running module ".$self->{modulenameRunning};
    } else {
	$string .= "waiting";
    }

    my $cpt = @{$self->{modulenamesToRun}};
    if ($cpt) {
	$string .= " module run queue: ";
	foreach(0..$cpt) {
	    $string .= " ".$self->{modulenamesToRun}[$cpt];
	    $string .= "," if $cpt;
	}
    }

    return $string;
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

=head2 run()

Run the tasks (inventory, snmp scan, etc) on the target

=head2 getDescriptionString()

Return a string to display to user in a 'target' field.

