package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Mkdir;

use strict;
use warnings;

use File::Path;


sub do {
    my ($params) = @_;

    my $msg = [];
    my $status = 1;
    foreach (@{$params->{list}}) {
        File::Path::mkpath($_);
        $status = 0 unless -d $_;
        push @$msg, "Failed to create $_ directory";
    }
    return {
    status => $status,
    msg => $msg,
    };
}

1;
