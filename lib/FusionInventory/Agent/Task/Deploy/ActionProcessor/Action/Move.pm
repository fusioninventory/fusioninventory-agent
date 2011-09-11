package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Move;

use strict;
use warnings;

$File::Copy::Recursive::CPRFComp = 1;
use File::Copy::Recursive;
use File::Glob;


sub do {
    my ($params) = @_;

    my $log = [];
    my $status = 1;
    foreach (File::Glob::glob($params->{from})) {
        if (!File::Copy::Recursive::rmove($_, $params->{to})) {
            push @$log, "Failed to move: `".$params->{from}."' to '".$params->{to};
            push @$log, $!;

            $status = 0;
        }
    }
    return {
        status => $status,
        log => $log,
    };
}

1;
