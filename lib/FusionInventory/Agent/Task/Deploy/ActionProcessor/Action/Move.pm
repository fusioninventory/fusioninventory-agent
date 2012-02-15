package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Move;

use strict;
use warnings;

$File::Copy::Recursive::CPRFComp = 1;
use English qw(-no_match_vars);
use File::Copy::Recursive;
use File::Glob;


sub do {
    my ($params, $logger) = @_;

    my $msg = [];
    my $status = 1;
    foreach (File::Glob::glob($params->{from})) {
        if (!File::Copy::Recursive::rmove($_, $params->{to})) {
            my $m = "Failed to move: `".$params->{from}."' to '".$params->{to};
            push @$msg, $m;
            push @$msg, $ERRNO;
            $logger->debug($m);

            $status = 0;
        }
    }
    return {
        status => $status,
        msg => $msg,
    };
}

1;
