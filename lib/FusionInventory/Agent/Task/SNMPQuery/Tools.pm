package FusionInventory::Agent::Task::SNMPQuery::Tools;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    lastSplitObject
    hex2stringValue
);

sub lastSplitObject {
    my $var = shift;

    my @array = split(/\./, $var);
    return $array[-1];
}

sub hex2stringValue {
    my ($hex) = @_;

    return unless $hex =~ /0x/;
    $hex =~ s/0x//;
    $hex =~ s/(\w{2})/chr(hex($1))/eg;

    return $hex;
}
