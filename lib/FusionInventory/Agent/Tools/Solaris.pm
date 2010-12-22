package FusionInventory::Agent::Tools::Solaris;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use Memoize;

our @EXPORT = qw(
    getZone
);

memoize('getZone');

sub getZone {

    my $OSLevel = `uname -r`;
    return 'global' if $OSLevel =~ /5.8/;

    my ($zone) = getFirstMatch(
        command => "zoneadm list -p",
        pattern => qr/^0:([a-z]+):/
    );

    return $zone;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Solaris - Solaris generic functions

=head1 DESCRIPTION

This module provides some generic functions for Solaris.

=head1 FUNCTIONS

=head2 getZone()

Returns system zone.
