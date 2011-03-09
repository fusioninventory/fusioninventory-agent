package FusionInventory::Agent::Task::Deploy::ActionProcessor;

use strict;
use warnings;

use English qw(-no_match_vars);

use Data::Dumper;
use Cwd;

my %actionByType = (
        'move' => 'FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Move',
        'cmd' => 'FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Cmd',
        'messageBox' => 'FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::MessageBox',

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

    if (($OSNAME ne 'MSWin32') && ($actionType eq 'messageBox')) {
        return {
            status => 1,
                   log => [ "not Windows: action `$actionType' ignored" ]
        }
    }

    my $cwd = getcwd();
    if (!defined($actionByType{$actionType})) {
        return {
            status => 0,
                   log => [ "unknown action `$actionType'" ]
        }
    }
    eval ("use ".$actionByType{$actionType}."; 1;");
    if ($@) {
        return {
            status => 0,
                   log => [ "failed to load action `$actionType': $@" ]
        }
    }
    chdir($workdir->{path});
    my $funcName = $actionByType{$actionType}."::do";
    my $ret;
    {
        no strict 'refs';
        $ret = &$funcName($params);
    }
    chdir($cwd);

    return $ret;
}

1;
