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
    getPrtconfInfos
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

sub getPrtconfInfos {
    my (%params) = (
        command => '/usr/sbin/prtconf -vp',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my $info = {};

    # a stack of nodes, as a list of couples [ node, level ]
    my @parents = (
        [ $info, -1 ]
    );

    while (my $line = <$handle>) {
        chomp $line;

        # new node
        if ($line =~ /^(\s*)Node \s (0x[a-f\d]+)/x) {
            my $level   = defined $1 ? length($1) : 0;
            my $address = $2;

            my $parent_level = $parents[-1]->[1];

            # compare level with parent
            if ($level > $parent_level) {
                # down the tree: no change
            } elsif ($level < $parent_level) {
                # up the tree: unstack nodes until a suitable parent is found
                while ($level <= $parents[-1]->[1]) {
                    pop @parents;
                }
            } else {
                # same level: unstack last node
                pop @parents;
            }

            # attach a new node to parent node 
            my $parent_node = $parents[-1]->[0];
            $parent_node->{$address} = {};

            # and push it to the stack
            push (@parents, [ $parent_node->{$address}, $level ]);

            next;
        }

        # value
        if ($line =~ /(\S[^:]+): \s+ (\S.*)$/x) {
            my $key       = $1;
            my $raw_value = $2;
            my $node = $parents[-1]->[0];

            if ($raw_value =~ /^'[^']+'(?: \+ '[^']+')+$/) {
                # list of string values
                $node->{$key} = [
                    map { /^'([^']+)'$/; $1 }
                    split (/ \+ /, $raw_value)
                ];
            } elsif ($raw_value =~ /^'([^']+)'$/) {
                # single string value
                $node->{$key} = $1;
            } else  {
                # other kind of value
                $node->{$key} = $raw_value;
            }
            next;
        }

    }
    close $handle;

    return $info;
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

=head2 getPrtconfInfos(%params)

Returns a structured view of prtconf output. Each information block is
turned into a hashref, hierarchically organised.

$info = {
    'System Configuration' => 'Sun Microsystems  sun4u',
    'Memory size' => '32768 Megabytes',
    '0xf00298fc' => {
        'banner-name' => 'Sun Fire V890',
        'model' => 'SUNW,501-7199',
        '0xf007c538' => {
            'compatible' => [
                'SUNW,UltraSPARC-III,mc',
                'SUNW,mc'
            ],
        }
    }
}
