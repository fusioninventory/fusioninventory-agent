package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Move;

use strict;
use warnings;

$File::Copy::Recursive::CPRFComp = 1;
use File::Copy::Recursive;


sub do {
    my ($params) = @_;

    my $log = [];
    my $status;
    $status = File::Copy::Recursive::rmove_glob($params->{from}, $params->{to});
print $!;
    if (!$status) {
        $log = [ "Failed to move file: `".$params->{from}."' to '".$params->{to}, $! ];
    }
    return {
    status => $status,
    log => $log,
    };
}

1;
