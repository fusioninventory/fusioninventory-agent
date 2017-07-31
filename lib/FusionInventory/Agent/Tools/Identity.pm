package FusionInventory::Agent::Tools::Identity;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    applyIdentityStrategy
);

my %strategies = (
    grepLoop => \&grepLoop
);


sub applyIdentityStrategy {
    my (%params) = @_;

    return unless (
        $params{strategyName}
        && $params{hash}
        && $params{hashList}
        && $strategies{$params{strategyName}}
    );

    return $strategies{$params{strategyName}}->(%params);
}

sub grepLoop {
    my (%params) = @_;

    return unless (
        ref $params{callbackList} eq 'ARRAY'
            && scalar $params{callbackList} > 0
    );

    my @retrievedEntries;
    while (scalar @retrievedEntries != 1 && scalar @{$params{callbackList}} > 0) {
        my $func = shift @{$params{callbackList}};
        @retrievedEntries = grep { &$func($params{hash}, $_); } @{$params{hashList}};
    }

    return $retrievedEntries[0] if (scalar @retrievedEntries == 1);
}

1;