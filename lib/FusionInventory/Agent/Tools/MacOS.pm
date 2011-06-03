package FusionInventory::Agent::Tools::MacOS;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    getSystemProfilerInfos
);


sub getSystemProfilerInfos {
    my %params = (
        command => '/usr/sbin/system_profiler',
        @_
    );
    my $handle = getFileHandle(%params);

    my $info = {};

    my @parents = (
        [ $info, -1 ]
    );
    while (my $line = <$handle>) {
        chomp $line;

        next unless $line =~ /^(\s*)(\S[^:]*):(?: (.*\S))?/;
        my $level = defined $1 ? length($1) : 0;
        my $key = $2;
        my $value = $3;

        if ($value) {
            # just add the value to the current parent
            $parents[-1]->[0]->{$key} = $value;
        } else {
            # compare level with parent
            my $parent_level = $parents[-1]->[1];

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

            # create a new node, and push it to the stack
            my $parent_node = $parents[-1]->[0];
            $parent_node->{$key} = {};
            push (@parents, [ $parent_node->{$key}, $level ]);
        }
    }
    close $handle;

    return $info;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::MacOS - MacOS generic functions

=head1 DESCRIPTION

This module provides some generic functions for MacOS.

=head1 FUNCTIONS

=head2 getSystemProfilerInfos(%params)

Returns a structured view of system_profiler output. Each information block is
turned into a hashref, hierarchically organised.

$info = {
    'Hardware' => {
        'Hardware Overview' => {
            'SMC Version (system)' => '1.21f4',
            'Model Identifier' => 'iMac7,1',
            ...
        }
    }
}

=over

=item logger a logger object

=item command the exact command to use (default: /usr/sbin/system_profiler)

=item file the file to use, as an alternative to the command

=back
