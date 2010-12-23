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
    getClass
);

memoize('getZone');
memoize('getModel');
memoize('getClass');

sub getZone {

    my $OSLevel = getFirstLine(command => 'uname -r');
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
        $model = getFirstLine(command => 'uname -i');
        # debug print model
        # cut the CR from string model
        $model = substr($model, 0, length($model) -1);
    } else {
        $model = "Solaris Containers";
    }

    return $model;
}

sub getClass {
    my $model = getModel();

    if ($model =~ /SUNW,Sun-Fire-\d/) {
        return 1;
    }

    if (
        $model =~ /SUNW,Sun-Fire-V/ or
        $model =~ /SUNW,Netra-T/    or
        $model =~ /SUNW,Ultra-250/
    ) {
        return 2;
    }

    if (
        $model =~ /SUNW,Sun-Fire-T\d/ or
        $model =~ /SUNW,T\d/
    ) {
        return 3;
    }

    if ($model =~ /SUNW,SPARC-Enterprise-T\d/) {
        return 4;
    }
    if ($model =~ /SUNW,SPARC-Enterprise/) {
        return 5;
    }
    if ($model eq "i86pc") {
        return 6;
    }
    if ($model =~ /Solaris Containers/) {
        return 7;
    }

    # unknown class
    return 0;
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

=head2 getclass()

Returns system class.
