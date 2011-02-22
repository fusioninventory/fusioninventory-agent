package FusionInventory::Agent::Task::Deploy::File;

use strict;
use warnings;

sub new {
    my (undef, $sha512, $params) = @_;

    foreach my $sha512 (keys %{$params->{files}}) {
        print $sha512."\n";
    }

    bless {};
}


1;
