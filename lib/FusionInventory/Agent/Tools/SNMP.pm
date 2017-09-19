package FusionInventory::Agent::Tools::SNMP;

use strict;
use warnings;
use base 'Exporter';

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    getCanonicalSerialNumber
    getCanonicalString
);

sub getCanonicalSerialNumber {
    my ($value) = @_;

    $value = hex2char($value);
    return unless $value;

    $value =~ s/[[:^print:]]//g;
    $value =~ s/^\s+//;
    $value =~ s/\s+$//;
    $value =~ s/\.{2,}//g;
    return unless $value;

    return $value;
}

sub getCanonicalString {
    my ($value) = @_;

    $value = hex2char($value);
    return unless defined $value;

    # unquote string
    $value =~ s/^\\?["']//;
    $value =~ s/\\?["']$//;

    return unless defined $value;

    # Be sure to work on utf-8 string
    $value = getUtf8String($value);

    # reduce linefeeds which can be found in descriptions or comments
    $value =~ s/\p{Control}+\n/\n/g;

    # truncate after first invalid character but keep newline as valid
    $value =~ s/[^\p{Print}\n].*$//;

    return $value;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::SNMP - SNMP Hardware-related functions

=head1 DESCRIPTION

This module provides some hardware-related functions for SNMP devices.

=head1 FUNCTIONS

=head2 getCanonicalSerialNumber($serial)

return a clean serial number string.

=head2 getCanonicalString($string)

return a clean generic string.
