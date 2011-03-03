package FusionInventory::Agent::Task::Deploy::ActionProcessor;

use strict;
use warnings;

use Data::Dumper;

use FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Move;
use FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Cmd;

my %actionByType = (
    'move' => \&FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Move::do,
    'cmd' => \&FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Cmd::do,

);

sub new {
    
    my $self = {};

    bless $self;
}

sub process {
    my ($self, $action) = @_;

    my ($actionType, $params) = %$action;
    print "run command: $actionType\n";

    if (!defined($actionByType{$actionType})) {
        print "unknown action `$actionType'\n";
        return;
    }
    return &{$actionByType{$actionType}}($params);
}

1;
