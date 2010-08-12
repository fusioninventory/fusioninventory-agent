package FusionInventory::Agent::JobEngine;

use strict;
use warnings;

use IPC::Run3;
use IO::Select;
use POSIX ":sys_wait_h";

use Data::Dumper; # to pass mod parameters

use English;

use POE;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{config} = $params->{config};
    $self->{logger} = $params->{logger};

    $self->{jobs} = [];

    # We can't have more than on task at the same time
    $self->{runningTask} = undef;

    bless $self;

print "Creation de JobEngine\n";

    POE::Session->create(
        inline_states => {
            _start => sub {
                $_[KERNEL]->alias_set("jobEngine");
            },
#            start => $start,
            start => sub {
                my $target = $_[ARG0];
                print "ok toto!\n";

            }
        });



}



1;
