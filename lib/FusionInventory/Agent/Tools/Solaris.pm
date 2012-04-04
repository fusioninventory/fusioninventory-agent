package FusionInventory::Agent::Tools::Solaris;

use strict;
use warnings;
use base 'Exporter';

use constant SOLARIS_UNKNOWN      => 0;
use constant SOLARIS_FIRE         => 1;
use constant SOLARIS_FIRE_V       => 2;
use constant SOLARIS_FIRE_T       => 3;
use constant SOLARIS_ENTERPRISE_T => 4;
use constant SOLARIS_ENTERPRISE   => 5;
use constant SOLARIS_I86PC        => 6;
use constant SOLARIS_CONTAINER    => 7;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use Memoize;

our @EXPORT = qw(
    getZone
    getModel
    getClass
    SOLARIS_UNKNOWN
    SOLARIS_FIRE
    SOLARIS_FIRE_V
    SOLARIS_FIRE_T
    SOLARIS_ENTERPRISE_T
    SOLARIS_ENTERPRISE
    SOLARIS_I86PC
    SOLARIS_CONTAINER
);

memoize('getZone');
memoize('getModel');
memoize('getClass');

sub getZone {

    return 'global' unless canRun('zonename');

    my $zone = getFirstLine(command => 'zonename');

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
    } else {
        $model = "Solaris Containers";
    }

    return $model;
}

sub getClass {
    my $model = getModel();

    if ($model =~ /SUNW,Sun-Fire-\d/) {
        return SOLARIS_FIRE;
    }

    if (
        $model =~ /SUNW,Sun-Fire-V/ or
        $model =~ /SUNW,Netra-T/    or
        $model =~ /SUNW,Ultra-250/
    ) {
        return SOLARIS_FIRE_V;
    }

    if (
        $model =~ /SUNW,Sun-Fire-T\d/ or
        $model =~ /SUNW,T\d/
    ) {
        return SOLARIS_FIRE_T;
    }

    if ($model =~ /SUNW,SPARC-Enterprise-T\d/) {
        return SOLARIS_ENTERPRISE_T;
    }
    if ($model =~ /SUNW,SPARC-Enterprise/) {
        return SOLARIS_ENTERPRISE;
    }
    if ($model eq "i86pc") {
        return SOLARIS_I86PC;
    }
    if ($model =~ /Solaris Containers/) {
        return SOLARIS_CONTAINER;
    }

    # unknown class
    return SOLARIS_UNKNOWN;
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
