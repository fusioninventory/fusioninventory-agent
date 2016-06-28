#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';
use File::Temp qw(tempdir);

use Test::Exception;
use Test::More;
use Test::MockModule;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Task::Collect;
use FusionInventory::Agent::Target::Server;

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Fatal' ]
);

my $target = FusionInventory::Agent::Target::Server->new(
    url    => 'http://localhost/glpi-any',
    logger => $logger,
    basevardir => tempdir(CLEANUP => 1)
);

my $task = undef ;

my %params = ();

my $plan = 15;

plan tests => $plan;

# Redefine send API for testing to simulate server answer without really sending
# user & password params can be used to define the current test and simulate the expected answer
sub _send {
    my ($self, %params) = @_;
    my $test = $self->{user} || '' ;
    my $remtest = $self->{password} || '' ;
    die 'communication error' if ($test eq 'nocomm');
    die 'no arg to send' unless exists($params{args});
    if ($params{args}->{action} eq 'getConfig') {
        if ($test eq 'noschedule') {
            return {};
        } elsif ( $test eq 'emptyschedule' ) {
            return {
                schedule => []
            };
        } elsif ( $test eq 'badschedule' ) {
            return {
                schedule => [{}]
            };
        } elsif ( $test eq 'normalschedule' ) {
            return {
                schedule => [
                    {
                        task => 'Collect'
                    }
                ]
            };
        } elsif ( $test eq 'normalschedulewithremoteurl' ) {
            return {
                schedule => [
                    {
                        task   => 'Collect',
                        remote => 'xxx'
                    }
                ]
            };
        }
    } elsif ($params{args}->{action} eq 'getJobs') {
        if ( $remtest eq 'nojob' ) {
            return {};
        } elsif ( $remtest eq 'badjson-1' ) {
            return 'bad';
        } elsif ( $remtest eq 'badjson-2' ) {
            return {
                bad => ''
            };
        } elsif ( $remtest eq 'badjson-3' ) {
            return {
                jobs => ''
            };
        } elsif ( $remtest eq 'badjson-4' ) {
            return {
                jobs => [ {} ]
            };
        } elsif ( $remtest eq 'badjson-5' ) {
            return {
                jobs => [ {
                        uuid => ''
                    } ]
            };
        } elsif ( $remtest eq 'badjson-6' ) {
            return {
                jobs => [ {
                        uuid     => '',
                        function => ''
                    } ]
            };
        } elsif ( $remtest eq 'unexpected-nojob' ) {
            return {
                jobs => []
            };
        }
    }
}

my $module = Test::MockModule->new('FusionInventory::Agent::HTTP::Client::Fusion');
$module->mock('send',\&_send);

# Set greater verbosity to trigger tests on expected debug message
$logger->{verbosity} = LOG_DEBUG2;

lives_ok {
    $task = FusionInventory::Agent::Task::Collect->new(
        target => $target,
        logger => $logger,
        debug  => 1,
        config => {
            jobs => []
        }
    );
} "Collect object instanciation" ;
is( $target->getUrl(), 'http://localhost/glpi-any' );

throws_ok {
    $task->run( user => 'nocomm' );
} qr/communication error/, "Normal error if target is unavailable" ;

lives_ok {
    $task->run( user => 'noschedule' );
} "Normal return on no scheduled task found" ;

lives_ok {
    $task->run( user => 'emptyschedule' );
} "Normal return on empty schedule" ;

lives_ok {
    $task->run( user => 'badschedule' );
} "No nothing with bad job schedule" ;

lives_ok {
    $task->run( user => 'normalschedule' );
} "Normal schedule" ;

throws_ok {
    $task->run( user => 'normalschedulewithremoteurl', password => 'nojob' );
} qr/Nothing to do/, "No job scheduled" ;

throws_ok {
    $task->run( user => 'normalschedulewithremoteurl', password => 'badjson-1' );
} qr/Bad JSON.*Bad answer/, "Badly formatted job - case 1" ;

throws_ok {
    $task->run( user => 'normalschedulewithremoteurl', password => 'badjson-2' );
} qr/Bad JSON.*Missing jobs/, "Badly formatted job - case 2" ;

throws_ok {
    $task->run( user => 'normalschedulewithremoteurl', password => 'badjson-3' );
} qr/Bad JSON.*Missing jobs/, "Badly formatted job - case 3" ;

throws_ok {
    $task->run( user => 'normalschedulewithremoteurl', password => 'badjson-4' );
} qr/Bad JSON.*Missing key/, "Badly formatted job - case 4" ;

throws_ok {
    $task->run( user => 'normalschedulewithremoteurl', password => 'badjson-5' );
} qr/Bad JSON.*Missing key/, "Badly formatted job - case 5" ;

throws_ok {
    $task->run( user => 'normalschedulewithremoteurl', password => 'badjson-6' );
} qr/Bad JSON.*not supported 'function' key/, "Badly formatted job - case 6" ;

throws_ok {
    $task->run( user => 'normalschedulewithremoteurl', password => 'unexpected-nojob' );
} qr/no jobs provided/, "No job included in jobs key" ;

1
