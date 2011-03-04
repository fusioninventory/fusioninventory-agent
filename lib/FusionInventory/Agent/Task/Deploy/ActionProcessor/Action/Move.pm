package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Move;

use strict;
use warnings;

use Data::Dumper;

$File::Copy::Recursive::CPRFComp = 1;
use File::Copy::Recursive qw(dirmove);


sub do {
    print "dirmove($_[0]->[0], $_[0]->[1])\n";
    return dirmove($_[0]->[0], $_[0]->[1]);
}

1;
