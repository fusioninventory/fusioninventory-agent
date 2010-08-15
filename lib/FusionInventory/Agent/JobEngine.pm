package FusionInventory::Agent::JobEngine;

use strict;
use warnings;

use IPC::Run3;
use IO::Select;
use POSIX ":sys_wait_h";

use Data::Dumper; # to pass mod parameters

use English;

use POE qw( Wheel::Run );

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{config} = $params->{config};
    $self->{logger} = $params->{logger};
    $self->{target} = $params->{target};

    $self->{jobs} = [];

    # We can't have more than on task at the same time
    $self->{runningTask} = undef;

    print "JobEngine Created object!\n";

    bless $self;
}


sub run {
    my ($self) = @_;

    POE::Session->create(
        inline_states => {
            _start => sub {
                $_[KERNEL]->alias_set("jobEngine");
                $_[KERNEL]->yield('prolog');
            },
            prolog  => sub {

                print "Prolog!\n";
                $_[KERNEL]->yield('launch');
            },
            launch  => sub {
                my $logger = $self->{logger};
                my $config = $self->{config};
                my $target = $self->{target};

                my $module = "Inventory";

                my $cmd;
                $cmd .= "\"$EXECUTABLE_NAME\""; # The Perl binary path
                $cmd .= "  -Ilib" if $config->{devlib};
                $cmd .= " -MFusionInventory::Agent::Task::".$module;
                $cmd .= " -e \"FusionInventory::Agent::Task::".$module."::main();\" --";
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

                # Signal events include the process ID.
                $_[HEAP]{children_by_pid}{$child->PID} = $child;

                print(
                    "Child pid ", $child->PID,
                    " started as wheel ", $child->ID, ".\n"
                );


            },
            got_child_stdout => \&on_child_stdout,
            got_child_stderr => \&on_child_stderr,
            got_child_close  => \&on_child_close,
            got_child_signal => \&on_child_signal,
        }
    );




}

#
#sub processTarget {
#    my ($self, $params) = @_;
#
#    my $logger = $self->{logger};
#    my $config = $self->{config};
#    my $target = $params->{target};
#
#    my $exitcode = 0;
#    my $wait;
#
#    my $network;
#    my $prologresp;
#    if ($target->{type} eq 'server') {
#
#
#
#        my $network = FusionInventory::Agent::Network->new({
#                logger => $logger,
#                config => $config,
#                target => $target,
#            });
#
#        my $prolog = FusionInventory::Agent::XML::Query::Prolog->new({
#                accountinfo => $target->{accountinfo}, #? XXX
#                logger => $logger,
#                config => $config,
#                target => $target,
#                #token  => $rpc->getToken()
#            });
#
#        # ugly circular reference moved from Prolog::getContent() method
#        $target->{accountinfo}->setAccountInfo($prolog);
#
#        # TODO Don't mix settings and temp value
#        $prologresp = $network->send({message => $prolog});
#
#        if (!$prologresp) {
#            $logger->error("No anwser from the server");
#            $target->setNextRunDate();
#            next;
#        }
#
#        $target->setCurrentDeviceID ($self->{deviceid});
#    }
#
#    my $storage = FusionInventory::Agent::Storage->new({
#            config => $config,
#            logger => $logger,
#            target => $target,
#        });
#    $storage->save({
#            data => {
#                config => $config,
#                target => $target,
#                #logger => $logger, # XXX Needed?
#                prologresp => $prologresp
#            }
#        });
#
#    my @modulesToDo = qw/
#    Inventory
#    OcsDeploy
#    WakeOnLan
#    SNMPQuery
#    NetDiscovery
#    Ping
#    /;
#
#    while (@modulesToDo) {
##        next if $jobEngine->isATaskRunning();
#        #
#        my $module = shift @modulesToDo;
#        print "starting: $module\n";
#        $self->startTask({
#                module => $module,
#                network => $network,
#                target => $target,
#            });
#        print "Ok\n";
#
#        if (!$config->{debug}) {
#            # In debug mode, I do not clean the FusionInventory-Agent.dump
#            # so I can replay the sub task directly
#            $storage->remove();
#        }
#        $target->setNextRunDate();
#
#    }
#}
#
#sub startTask {
#    use Data::Dumper;
#
#    my ($self, $params) = @_;
#
#
#    my $config = $params->{config};
#    my $module = $params->{module};
#    my $target = $params->{target};
#
#    print "--".$module."\n";
#
#    POE::Session->create(
#        inline_states => {
#
#    );
#
#
#
#}

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
