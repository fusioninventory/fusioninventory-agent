package FusionInventory::Agent::Server::Run;

use POE;
use POE qw( Wheel::Run );
use FusionInventory::Agent::Logger::Parsable;

sub run {
    my ($logger, $job) = @_;


    POE::Session->create(
            inline_states => {
            _start           => sub {

            print $_[KERNEL]->alias_resolve("job")."\n";
            if (defined $_[KERNEL]->alias_resolve("job")) {
            print "a job is already running.\n";
            return;
            }


            $_[KERNEL]->alias_set("job");

            my $child = POE::Wheel::Run->new(
                Program => sub {

                
                my $taskPkg = "FusionInventory::Agent::Task::".$job->{task};
                $taskPkg->require();
                my $task = $taskPkg->new();
                $task->run(
                    logger => FusionInventory::Agent::Logger->new(
                        backends => ['Parsable'],
# DEBUG on, BTW, the main logger will filter the result
                        debug => 1
                        ),
                    target => $job->{target},
                    deviceid => $self->{deviceid}
                    );
                },
                StdoutEvent  => "got_child_stdout",
                StderrEvent  => "got_child_stderr",
                CloseEvent   => "got_child_close",
                );

            $_[KERNEL]->sig_child($child->PID, "got_child_signal");
            $_[HEAP]{children_by_wid}{$child->ID} = $child;
            $_[HEAP]{children_by_pid}{$child->PID} = $child;

            print(
                    "Child pid ", $child->PID,
                    " started as wheel ", $child->ID, ".\n"
                 );
            },
#      got_child_stdout => \&on_child_stdout,
      got_child_stderr => sub {
                my ($stderr_line, $wheel_id) = @_[ARG0, ARG1];

                my $child = $_[HEAP]{children_by_wid}{$wheel_id};
                if ($stderr_line =~ /^(debug|info|error|fault):\s(.*)/) {
                    $logger->$1("t) ".$2);
                } else {
                    $logger->error($stderr_line);
                }
            },
                             got_child_close  => \&on_child_close,
                             got_child_signal => \&on_child_signal,
            }
    );

}



# Wheel event, including the wheel's ID.
sub on_child_stdout {
    my ($stdout_line, $wheel_id) = @_[ARG0, ARG1];
    my $child = $_[HEAP]{children_by_wid}{$wheel_id};
    print "pid ", $child->PID, " STDOUT: $stdout_line\n";
}

# Wheel event, including the wheel's ID.
sub on_child_stderr {
    my ($stderr_line, $wheel_id) = @_[ARG0, ARG1];
    my $child = $_[HEAP]{children_by_wid}{$wheel_id};
    print "pid ", $child->PID, " STDERR: $stderr_line\n";
}

# Wheel event, including the wheel's ID.
sub on_child_close {
    my $wheel_id = $_[ARG0];
    $_[KERNEL]->alias_remove("job");
    my $child = delete $_[HEAP]{children_by_wid}{$wheel_id};

# May have been reaped by on_child_signal().
    unless (defined $child) {
        print "wid $wheel_id closed all pipes.\n";
        return;
    }

    print "pid ", $child->PID, " closed all pipes.\n";
    delete $_[HEAP]{children_by_pid}{$child->PID};
}

sub on_child_signal {
    print "pid $_[ARG1] exited with status $_[ARG2].\n";
    my $child = delete $_[HEAP]{children_by_pid}{$_[ARG1]};

# May have been reaped by on_child_close().
    return unless defined $child;
    delete $_[HEAP]{children_by_wid}{$child->ID};
}




1;
