package FusionInventory::Agent::Task::Deploy::ActionProcessor;

use strict;
use warnings;

use English qw(-no_match_vars);

use Cwd;
use Data::Dumper;
use FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Move;
use FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Cmd;
use FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::MessageBox;
my %actionByType = (
    'move'       => '',
    'exec'       => '',
    'messageBox' => '',

);

sub new {
    my ( undef, $params ) = @_;

    my $self = { workdir => $params->{workdir} };

    die unless $params->{workdir};

    bless $self;
}

sub process {
    my ( $self, $actionName, $params ) = @_;

    my $workdir = $self->{workdir};
    print "run command: $actionName\n";

    if ( ( $OSNAME ne 'MSWin32' ) && ( $actionName eq 'messageBox' ) ) {
        return {
            status => 1,
            log    => ["not Windows: action `$actionName' ignored"]
        };
    }

    my $ret;
    my $cwd = getcwd();
    chdir( $workdir->{path} );
    if ( $actionName eq 'checks' ) {
        # not an action
    } elsif ( $actionName eq 'move' ) {
        $ret =
          FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Move::do(
            $params);
    } elsif ( $actionName eq 'cmd' ) {
        $ret =
          FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Cmd::do(
            $params);
    } elsif ( $actionName eq 'messageBox' ) {
        $ret =
          FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::MessageBox::do(
            $params);
    } else {
        print "Unknown action type: `$actionName'\n";
        chdir($cwd);
        return {
            status => 0,
            log    => ["unknown action `$actionName'"]
        };
    }
    print "chdir ## ".$cwd."\n";
    chdir($cwd);

    return $ret;
}

1;
