package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Mkdir;

use strict;
use warnings;

use File::Path;


sub do {
    my ($params, $logger) = @_;

    my $msg = [];
    my $status = 1;
    foreach (@{$params->{list}}) {
        my $dir = $_;
        if (-d $dir) {
            my $m = "Directory $dir already exists";
            push @$msg, $m;
            $logger->debug($m);
        } else {
            File::Path::mkpath($dir);
            $status = 0 unless -d $dir;
            my $m = "Failed to create $dir directory";
            push @$msg, $m;
            $logger->debug($m);
        }
    }
    return {
    status => $status,
    msg => $msg,
    };
}

1;
