package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Move;

use strict;
use warnings;

$File::Copy::Recursive::CPRFComp = 1;
use File::Copy::Recursive qw(dirmove);


sub do {
    my $log = [];
    print "dirmove($_[0]->[0], $_[0]->[1])\n";
    my $status = dirmove($_[0]->[0], $_[0]->[1]);
    push @$log, $! unless $status;

    return {
    status => $status,
    log => $log,
    };
}

1;
