package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::MessageBox; 

use English qw(-no_match_vars);
use Data::Dumper;

use lib 'lib';
use FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::MessageBox::Wx;

sub do {
    print Dumper(\@_);

    if ($OSNAME ne 'MSWin32') {    
        return { status => 1, log => [ "No available on non Windows system." ] }
    }

    my $params = $_[0];
    print Dumper($params);

    my $title = $params->{title}{default} || 'FusionInventory';
    my $msg = $params->{msg}{default} || '';


    my $ret;

    if ($params->{type} eq 'info') { 
        my $r = FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::MessageBox::Wx::createInfoBox({ timeout => 5, title => $title, "msg" => $msg });
        print "r info: $r\n";
        $ret = { status => 1, log => [] }
    } elsif ($params->{type} eq 'postpone') { 
        my $r = FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::MessageBox::Wx::createPostponeBox({ timeout => undef, title => $title, "msg" => $msg });
        print "r postphone: $r\n";
        if ($r eq "ok") {
            $ret = { status => 1 == 1, log => [ 'user accepts the job' ] }
        } else {
            $ret = { status => 0, log => [ 'user rejects the job' ] }
        }
    } else {
        $ret = { status => 0, log => [ 'unknown message type' ] }
    }

    return $ret; 
}

1;
