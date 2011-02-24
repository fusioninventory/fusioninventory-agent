package FusionInventory::Agent::Task::Deploy::ActionProcessor;

use strict;
use warnings;

use Data::Dumper;

use File::Copy::Recursive qw(dirmove);

my %actionByType = (
    'move' => sub {
        print "dirmove($_[0]->[0], $_[0]->[1])\n";
        return dirmove($_[0]->[0], $_[0]->[1]);
    },


);

sub new {
    
    my $self = {};

    bless $self;
}

sub process {
    my ($self, $action) = @_;

    my ($actionType, $params) = %$action;
    print "run command: $actionType\n";
    print Dumper($params);

    return $actionByType{$actionType}($params);
}

1;
