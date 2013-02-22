package FusionInventory::Agent::Tools::MacOS;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use Memoize;

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    getSystemProfilerInfos
    getIODevices
);

memoize('getSystemProfilerInfos');

sub getSystemProfilerInfos {
    my (%params) = @_;

    my $command = $params{type} ?
        "/usr/sbin/system_profiler $params{type}" : "/usr/sbin/system_profiler";
    my $handle = getFileHandle(command => $command, %params);

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

        my $parent = $parents[-1];
        my $parent_level = $parent->[1];
        my $parent_node  = $parent->[0];

        if (defined $value) {
            # check indentation level against parent node
            if ($level <= $parent_level) {

                if (keys %$parent_node == 0) {
                    # discard just created node, and fix its parent
                    my $parent_key = $parent->[2];
                    $parents[-2]->[0]->{$parent_key} = undef;
                }

                # unstack nodes until a suitable parent is found
                while ($level <= $parents[-1]->[1]) {
                    pop @parents;
                }
                $parent_node = $parents[-1]->[0];
            }

            # add the value to the current node
            $parent_node->{$key} = $value;
        } else {
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

            # create a new node, and push it to the stack
            my $parent_node = $parents[-1]->[0];

            my $i;
            my $keyL = $key;
            while (defined($parent_node->{$key})) {
                $key = $keyL . '_' . $i++;
            }

            $parent_node->{$key} = {};
            push (@parents, [ $parent_node->{$key}, $level, $key ]);
        }
    }
    close $handle;

    return $info;
}

sub getIODevices {
    my (%params) = @_;

    # passing expected class to the command ensure only instance of this class
    # are present in the output, reducing the size of the content to be parsed,
    # but still requires some manual filtering to avoid subclasses instances
    my $command = $params{class} ? "ioreg -c $params{class}" : "ioreg -l";
    my $filter = $params{class} || '[^,]+';

    my $handle = getFileHandle(command => $command, %params);
    return unless $handle;

    my @devices;
    my $device;


    while (my $line = <$handle>) {
        if ($line =~ /<class $filter,/) {
            # new device block
            $device = {};
            next;
        }

        next unless $device;

        if ($line =~ /\| }/) {
            # end of device block
            push @devices, $device;
            undef $device;
            next;
        }

        if ($line =~ /"([^"]+)" \s = \s <? (?: "([^"]+)" | (\d+)) >?/x) {
            # string or numeric property
            $device->{$1} = $2 || $3;
            next;
        }

    }
    close $handle;

    return @devices;
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

=head2 getIODevices(%params)

Returns a flat list of devices as a list of hashref, by parsing ioreg output.
Relationships are not extracted.

=over

=item logger a logger object

=item class the class of devices wanted

=item file the file to use, as an alternative to the command

=back
