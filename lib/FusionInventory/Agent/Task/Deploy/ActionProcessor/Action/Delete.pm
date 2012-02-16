package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Delete;

use strict;
use warnings;

use File::Path;


sub do {
    my ($params, $logger) = @_;

    my $msg = [];
    my $status = 1;
    foreach (@{$params->{list}}) {
        File::Path::remove_tree($_);
        $status = 0 if -e $_;
        my $m = "Failed to delete $_";
        push @$msg, $m;
        $logger->debug($m);
    }
    return {
    status => $status,
    msg => $msg,
    };
}

1;
