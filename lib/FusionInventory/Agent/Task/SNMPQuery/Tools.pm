package FusionInventory::Agent::Task::SNMPQuery::Tools;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    getLastNumber
    hex2string
);

sub getLastNumber {
    my $var = shift;

    my @array = split(/\./, $var);
    return $array[-1];
}

sub hex2ascii {
    my ($hex) = @_;

    return unless $hex =~ /0x/;
    $hex =~ s/0x//;
    $hex =~ s/(\w{2})/chr(hex($1))/eg;

    return $hex;
}
__END__

=head1 NAME

FusionInventory::Agent::Task::Tools - Utility functions

=head1 DESCRIPTION

This is a module providing some utility functions

=head1 FUNCTIONS

=head2 getLastNumber($oid)

return the last number of an oid.

=head2 hex2ascii($hex)

convert a string from hex to ascii.
