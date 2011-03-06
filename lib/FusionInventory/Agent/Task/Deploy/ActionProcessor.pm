package FusionInventory::Agent::Task::Deploy::ActionProcessor;

use strict;
use warnings;

use Data::Dumper;
use Cwd;

use FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Move;
use FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Cmd;
use FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::MessageBox;

my %actionByType = (
    'move' => \&FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Move::do,
    'cmd' => \&FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Cmd::do,
    'messageBox' => \&FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::MessageBox::do,

);

sub new {
    my (undef, $params) = @_;
    
    my $self = {
        workdir => $params->{workdir}
    };

    die unless $params->{workdir};

    bless $self;
}

sub process {
    my ($self, $action) = @_;

    my $workdir = $self->{workdir};

    my ($actionType, $params) = %$action;
    print "run command: $actionType\n";

    my $cwd = getcwd();
    if (!defined($actionByType{$actionType})) {
        return {
            status => 0,
            log => [ "unknown action `$actionType'" ]
        }
    }
    chdir($workdir->{path});
    my $ret = &{$actionByType{$actionType}}($params);
    chdir($cwd);

    return $ret;
}

1;
