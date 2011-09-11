package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Copy;

use strict;
use warnings;

$File::Copy::Recursive::CPRFComp = 1;
use File::Copy::Recursive qw(rcopy);
use File::Glob;

sub do {
    my ($params) = @_;

    my $log = [];
    my $status = 1;
    foreach (File::Glob::glob($params->{from})) {
        if (!File::Copy::Recursive::rcopy($_, $params->{to})) {
            push @$log, "Failed to copy: `".$params->{from}."' to '".$params->{to};
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
