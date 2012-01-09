package FusionInventory::Agent::Task::Deploy::CheckProcessor;

use strict;
use warnings;

use English qw(-no_match_vars);

sub new {
    my ($class, %params) = @_;

    my $self = {};

    bless $self, $class;

    return $self;
}

sub process {
    my ($self, $check) = @_;

    if ($check->{type} eq 'winkeyExists') {
        return unless $OSNAME eq 'MSWin32';
        require FusionInventory::Agent::Tools::Win32;
        my $r = FusionInventory::Agent::Tools::Win32::getRegistryValue($check->{path});
        if (defined($r)) {
            return "ok";
        } else {
            return $check->{return};
        }
    }

    if ($check->{type} eq 'winkeyEquals') {
        return unless $OSNAME eq 'MSWin32';
        require FusionInventory::Agent::Tools::Win32;
        my $r = FusionInventory::Agent::Tools::Win32::getValueFromRegistry($check->{path});
        if (defined($r) && $check->{value} eq $r) {
            return "ok";
        } else {
            return $check->{return};
            return;
        }
    }
    
    if ($check->{type} eq 'winkeyMissing') {
        return unless $OSNAME eq 'MSWin32';
        require FusionInventory::Agent::Tools::Win32;
        my $r = FusionInventory::Agent::Tools::Win32::getValueFromRegistry($check->{path});
        if (defined($r)) {
            return $check->{return};
            return;
        } else {
            return "ok";
        }
    } 

    if ($check->{type} eq 'fileExists') {
        return $check->{return} unless -f $check->{path};
        return 'ok';
    }

    if ($check->{type} eq 'fileSizeEquals') {
        my @s = stat($check->{path});
        return $check->{return} unless @s;
        return 'ok';
    }

    if ($check->{type} eq 'fileSizeGreater') {
        my @s = stat($check->{path});
        return $check->{return} unless @s;
        return "ok" if ($check->{value}) > $s[7];
        return "ok";
    }

    if ($check->{type} eq 'fileSizeLower') {
        my @s = stat($check->{path});
        return $check->{return} unless @s;
        return "ok" if ($check->{value}) < $s[7];
        return "ok";
    }
    
    if ($check->{type} eq 'fileMissing') {
        return $check->{return} if -f $check->{path};
        return "ok";
    }
    
    if ($check->{type} eq 'freespaceGreater') {
        # TODO
        return "ok";
    }
    
    print "Unknown check: `".$check->{type}."'\n";

    return "ok";
}

1;
