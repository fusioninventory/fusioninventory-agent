package FusionInventory::Agent::Tools;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use File::stat;
use Memoize;
use Sys::Hostname;
use File::Spec;

our @EXPORT = qw(
    getCanonicalManufacturer
);

memoize('getCanonicalManufacturer');

sub getCanonicalManufacturer {
    my ($model) = @_;

    return unless $model;

    my $manufacturer;
    if ($model =~ /(
        maxtor    |
        sony      |
        compaq    |
        ibm       |
        toshiba   |
        fujitsu   |
        lg        |
        samsung   |
        nec       |
        transcend |
        matshita  |
        pioneer
    )/xi) {
        $manufacturer = ucfirst(lc($1));
    } elsif ($model =~ /^(hp|HP|hewlett packard)/) {
        $manufacturer = "Hewlett Packard";
    } elsif ($model =~ /^(WDC|[Ww]estern)/) {
        $manufacturer = "Western Digital";
    } elsif ($model =~ /^(ST|[Ss]eagate)/) {
        $manufacturer = "Seagate";
    } elsif ($model =~ /^(HD|IC|HU)/) {
        $manufacturer = "Hitachi";
    }

    return $manufacturer;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools - OS-independant generic functions

=head1 DESCRIPTION

This module provides some OS-independant generic functions.

This module is a backported from the master git branch.

=head1 FUNCTIONS

=head2 getCanonicalManufacturer($manufacturer)

Returns a normalized manufacturer value for given one.

