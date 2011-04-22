package FusionInventory::Agent::Tools::AIX;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use Memoize;

our @EXPORT = qw(
    getDevicesFromLsvpd
);

memoize('getDevicesFromLsvpd');

sub getDevicesFromLsvpd {
    my %params = (
        command => 'lsvpd',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @devices;
    my $device;

    # skip first lines
    while (my $line = <$handle>) {
        last if $line =~ /^\*FC \?+/;
    }

    while (my $line = <$handle>) {
        if ($line =~ /^\*FC \?+/) {
            # block delimiter
            push @devices, $device;
            undef $device;
            next;
        }

        chomp $line;
        next unless $line =~ /^\* ([A-Z]{2}) \s+ (.*\S)/x;
        $device->{$1} = $2; 
    }
    close $handle;

    # last device
    push @devices, $device;

    return @devices;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::AIX - AIX generic functions

=head1 DESCRIPTION

This module provides some generic functions for AIX.

=head1 FUNCTIONS

=head2 getDevicesFromLsvpd

Returns a list of devices, extracted from lsvpd output.

@devices = (
    {
        DS => 'System VPD',
        YL => 'U9111.520.65DEDAB',
        RT => 'VSYS',
        FG => 'XXSV',
        BR => 'O0',
        SE => '65DEDAB',
        TM => '9111-520',
        SU => '0004AC0BA763',
        VK => 'ipzSeries'
    },
    ...
)
