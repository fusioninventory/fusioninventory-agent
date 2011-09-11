package FusionInventory::Agent::Task::SNMPQuery::Tools;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    getLastNumber
);

sub getLastNumber {
    my ($var) = @_;

    my @array = split(/\./, $var);
    return $array[-1];
}

__END__

=head1 NAME

FusionInventory::Agent::Task::Tools - Utility functions

=head1 DESCRIPTION

This is a module providing some utility functions

=head1 FUNCTIONS

=head2 getLastNumber($oid)

return the last number of an oid.
