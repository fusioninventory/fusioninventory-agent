package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Mkdir;

use strict;
use warnings;

use File::Path;


sub do {
    my ($params) = @_;

    my $log = [];
    my $status = 1;
    foreach (@{$params->{list}}) {
        File::Path::make_path($_);
        $status = 0 unless -d $_;
        push @$log, "Failed to create $_ directory";
    }
    return {
    status => $status,
    log => $log,
    };
}

1;
