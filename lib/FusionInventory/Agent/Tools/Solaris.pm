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
    return canRun('zonename') ?
        getFirstLine(command => 'zonename') : # actual zone name
        'global';                             # outside zone name
}

sub getModel {
    return getZone() eq 'global' ?
        getFirstLine(command => 'uname -i') :
        'Solaris Containers';
}

sub getClass {
    my $model = getModel();

    if ($model =~ /SUNW,Sun-Fire-\d/ || $model =~ /SUNW,Sun-Fire-V490/) {
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

Returns current zone name, or 'global' if there is no defined zone.

=head2 getModel()

Returns system model, as a string.

=head2 getclass()

Returns system class, as a symbolic constant.
