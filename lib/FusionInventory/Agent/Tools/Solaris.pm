package FusionInventory::Agent::Tools::Solaris;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use Memoize;

our @EXPORT = qw(
    getZone
    getModel
);

memoize('getZone');
memoize('getModel');

sub getZone {

    my $OSLevel = getSingleLine(command => 'uname -r');
    return 'global' if $OSLevel =~ /5.8/;

    my ($zone) = getFirstMatch(
        command => "zoneadm list -p",
        pattern => qr/^0:([a-z]+):/
    );

    return $zone;
}

sub getModel {

    my $zone = getZone();

    my $model;
    if ($zone) {
        # first, we need determinate on which model of Sun Server we run,
        # because prtdiags output (and with that memconfs output) is differend
        # from server model to server model
        # we try to classified our box in one of the known classes
        $model = getSingleLine(command => 'uname -i');
        # debug print model
        # cut the CR from string model
        $model = substr($model, 0, length($model) -1);
    } else {
        $model = "Solaris Containers";
    }

    return $model;
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

=head2 getModel()

Returns system model.
