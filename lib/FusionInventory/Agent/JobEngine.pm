package FusionInventory::Agent::JobEngine;

use strict;
use warnings;

use IPC::Run3;
use IO::Select;
use POSIX ":sys_wait_h";

use Data::Dumper; # to pass mod parameters

use FusionInventory::Agent::Network;

use English;

use POE qw( Wheel::Run );

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{config} = $params->{config};
    $self->{logger} = $params->{logger};
    $self->{target} = $params->{target};

    $self->{target_by_module} = {};

    # We can't have more than on task at the same time
    $self->{runningTask} = undef;

    print "JobEngine Created object!\n";

    bless $self;
}


sub run {
    my ($self, $params) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $target = $params->{target};

    POE::Session->create(
        inline_states => {
            _start => sub {
                $_[KERNEL]->alias_set("jobEngine");
                $_[KERNEL]->yield('prolog');
                $_[HEAP]->{modulesToRun} = [ 'Inventory', 'Ping', 'WakeOnLan' ];
                $_[HEAP]->{target} = $target;


                if ($target->{type} eq 'server') {
                    $_[HEAP]->{network} = FusionInventory::Agent::Network->new({
                            logger => $logger,
                            config => $config,
                            target => $target,
                        });


                    my $prolog = FusionInventory::Agent::XML::Query::Prolog->new({
                            accountinfo => $target->{accountinfo}, #? XXX
                            logger => $logger,
                            config => $config,
                            target => $target,
                            token => 'TODO'
                        });

                    # TODO Don't mix settings and temp value
                    $_[HEAP]->{prologresp} = $_[HEAP]->{network}->send({message => $prolog});

                    if (!$_[HEAP]->{prologresp}) {
                        $logger->error("No anwser from the server");
                        $target->setNextRunDate();
                        return;
                    }
                }

                $_[KERNEL]->yield('launchNextTask');

            },
            launchNextTask  => sub {
                my $logger = $self->{logger};
                my $config = $self->{config};
                my $target = $_[HEAP]->{target};

                if(!@{$_[HEAP]->{modulesToRun}}) {
                    $target->createNextAlarm();
                    return;
                }

                $_[HEAP]->{runningModule} = shift @{$_[HEAP]->{modulesToRun}};

                print "Launching module ".$_[HEAP]->{runningModule}."\n";

                my $cmd;
                $cmd .= "\"$EXECUTABLE_NAME\""; # The Perl binary path
                $cmd .= "  -Ilib" if $config->{devlib};
                $cmd .= " -MFusionInventory::Agent::Task::".$_[HEAP]->{runningModule};
                $cmd .= " -e \"FusionInventory::Agent::Task::".$_[HEAP]->{runningModule}."::main();\" --";
                $cmd .= " \"".$target->{vardir}."\"";

                my $child = POE::Wheel::Run->new(
                    Program => $cmd,
                    StdoutEvent  => "got_child_stdout",
                    StderrEvent  => "got_child_stderr",
                    CloseEvent   => "got_child_close",
                );

                $_[KERNEL]->sig_child($child->PID, "got_child_signal");

                # Wheel events include the wheel's ID.
                $_[HEAP]{children_by_wid}{$child->ID} = $child;

                $self->{target_by_module}{$_[HEAP]->{runningModule}} = $target;

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

                if ($stderr_line =~ s/(\w+):\s(.*)//) {
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

                print "module: ".$_[HEAP]->{runningModule}." terminé\n";
                print "pid ", $child->PID, " closed all pipes.\n";
                delete $_[HEAP]{children_by_pid}{$child->PID};
                print Dumper($self->{target_by_module});
                delete $self->{target_by_module}{$_[HEAP]->{runningModule}};
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


1;
