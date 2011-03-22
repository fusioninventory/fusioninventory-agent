package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::MessageBox;

use English qw(-no_match_vars);
use Data::Dumper;

sub do {
    if ($OSNAME ne 'MSWin32') {
        return { status => 1, log => [ "No available on non Windows system." ] }
    }

    my $params = $_[0];

    my $timeout = $params->{timeout} || 0;
    my $title = $params->{title}{default} || 'FusionInventory';
    my $msg = $params->{msg}{default} || '';


    my $ret;

    if ($params->{type} eq 'info') {
        open(FUSINVFORM, '-|', "fusinvform info $timeout \"$title\" \"$msg\"");
        chomp(my $r = <FUSINVFORM>);
        close(FUSINVFORM);
        $ret = { status => 1, log => [] }
    } elsif ($params->{type} eq 'postpone') {
        open(FUSINVFORM, '-|', "fusinvform postpone $timeout  \"$title\" \"$msg\"");
        chomp(my $r = <FUSINVFORM>);
        close(FUSINVFORM);
        if ($r eq "ok") {
            $ret = { status => 1 == 1, log => [ 'accepted by user' ] }
        } elsif ($r eq "ok") {
            $ret = { status => 1 == 1, log => [ 'accepted because of timeout' ] }
        } else {
            $ret = { status => 0, log => [ 'rejected by user' ] }
        }
    } else {
        $ret = { status => 0, log => [ 'unknown message type' ] }
    }

    return $ret;
}

1;
