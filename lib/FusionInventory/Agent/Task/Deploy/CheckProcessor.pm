package FusionInventory::Agent::Task::Deploy::CheckProcessor;

use strict;
use warnings;

use English qw(-no_match_vars);

use Data::Dumper;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    bless $self;
}

sub process {
    my ($self, $check) = @_;

    if ($check->{type} eq 'winkeyExists') {
        return unless $OSNAME eq 'MSWin32';
        eval "use FusionInventory::Agent::Tools::Win32; 1";
        my $r = getValueFromRegistry($check->{path});
        if (defined($r)) {
            return 1;
        } else {
            return;
        }
    } elsif ($check->{type} eq 'winkeyEquals') {
        return unless $OSNAME eq 'MSWin32';
        eval "use FusionInventory::Agent::Tools::Win32; 1";
        my $r = getValueFromRegistry($check->{path});
        if (defined($r) && $check->{value} eq $r) {
            return 1;
        } else {
            return;
        }
    } elsif ($check->{type} eq 'winkeyMissing') {
        return unless $OSNAME eq 'MSWin32';
        eval "use FusionInventory::Agent::Tools::Win32; 1";
        my $r = getValueFromRegistry($check->{path});
        if (defined($r)) {
            return;
        } else {
            return 1;
        }
    } elsif ($check->{type} eq 'fileExists') {
        return 0 unless -f $check->{path};
    } elsif ($check->{type} eq 'fileSizeEquals') {
        my @s = stat($check->{path});
        return unless @s;
        return ($check->{value}) == int($s[7]);
    } elsif ($check->{type} eq 'fileSizeGreater') {
        my @s = stat($check->{path});
        return unless @s;
        return ($check->{value}) > $s[7];
    } elsif ($check->{type} eq 'fileSizeLess') {
        my @s = stat($check->{path});
        return unless @s;
        return ($check->{value}) < $s[7];
    } elsif ($check->{type} eq 'fileMissing') {
        return 0 if -f $check->{path};
    } elsif ($check->{type} eq 'freespaceGreater') {
        # TODO
    } else {
        print "Unknown check: `".$check->{type}."'\n";
    }

    return 1;
}

1;
