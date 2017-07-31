package FusionInventory::Agent::Tools::Merge;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    applyMergeStrategy
);

my %strategies = (
    takeJustMissingKeysOrWithEmptyValue => \&takeJustMissingKeysOrWithEmptyValue
);


sub applyMergeStrategy {
    my (%params) = @_;

    return unless (
        $params{strategyName}
        && $params{hash1}
        && $params{hash2}
        && $strategies{$params{strategyName}}
    );

    return $strategies{$params{strategyName}}->(%params);
}

# put data from hash2 in hash1 only if key does not exist in hash1 or if associated value is not defined or empty
sub takeJustMissingKeysOrWithEmptyValue {
    my (%params) = @_;

    # selecting keys that are not already set in hash1
    my @keysWithValueToInsert = grep { !$params{hash1}->{$_} } keys %{$params{hash2}};
    # merging
    @{$params{hash1}}{ @keysWithValueToInsert } = @{$params{hash2}}{ @keysWithValueToInsert };

    return $params{hash1};
}

1;
