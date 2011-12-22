package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Copy;

use strict;
use warnings;

$File::Copy::Recursive::CPRFComp = 1;
use File::Copy::Recursive qw(rcopy);
use File::Glob;

sub do {
    my ($params) = @_;

    my $msg = [];
    my $status = 1;
    foreach (File::Glob::glob($params->{from})) {
        if (!File::Copy::Recursive::rcopy($_, $params->{to})) {
            push @$msg, "Failed to copy: `".$params->{from}."' to '".$params->{to};
            push @$msg, $!;

            $status = 0;
        }
    }
    return {
        status => $status,
        msg => $msg,
    };
}

1;
