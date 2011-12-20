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
        my $r = FusionInventory::Agent::Tools::Win32::getRegistryValue($check->{path});
        if (defined($r)) {
            return "ok";
        } else {
            return $check->{return};
        }
    } elsif ($check->{type} eq 'winkeyEquals') {
        return unless $OSNAME eq 'MSWin32';
        eval "use FusionInventory::Agent::Tools::Win32; 1";
        my $r = getValueFromRegistry($check->{path});
        if (defined($r) && $check->{value} eq $r) {
            return "ok";
        } else {
            return $check->{return};
            return;
        }
    } elsif ($check->{type} eq 'winkeyMissing') {
        return unless $OSNAME eq 'MSWin32';
        eval "use FusionInventory::Agent::Tools::Win32; 1";
        my $r = getValueFromRegistry($check->{path});
        if (defined($r)) {
            return $check->{return};
            return;
        } else {
            return "ok";
        }
    } elsif ($check->{type} eq 'fileExists') {
        return $check->{return} unless -f $check->{path};
    } elsif ($check->{type} eq 'fileSizeEquals') {
        my @s = stat($check->{path});
        return $check->{return} unless @s;
    } elsif ($check->{type} eq 'fileSizeGreater') {
        my @s = stat($check->{path});
        return $check->{return} unless @s;
        return "ok" if ($check->{value}) > $s[7];
    } elsif ($check->{type} eq 'fileSizeLower') {
        my @s = stat($check->{path});
        return $check->{return} unless @s;
        return "ok" if ($check->{value}) < $s[7];
    } elsif ($check->{type} eq 'fileMissing') {
        return $check->{return} if -f $check->{path};
    } elsif ($check->{type} eq 'freespaceGreater') {
        # TODO
    } else {
        print "Unknown check: `".$check->{type}."'\n";
    }

    return "ok";
}

1;
