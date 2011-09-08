package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Delete;

use strict;
use warnings;

use File::Path;


sub do {
    my ($params) = @_;

    my $log = [];
    my $status = 1;
    foreach (@{$params->{list}}) {
        File::Path::remove_tree($_);
        $status = 0 if -e $_;
        push @$log, "Failed to delete $_";
    }
    return {
    status => $status,
    log => $log,
    };
}

1;
