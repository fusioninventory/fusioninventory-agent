package FusionInventory::Agent::Task::Deploy::CheckProcessor;

use strict;
use warnings;

use English qw(-no_match_vars);
use Digest::SHA;

use FusionInventory::Agent::Task::Deploy::DiskFree;

sub process {
    my ($self, $check) = @_;

    if ($check->{type} eq 'winkeyExists') {
        return unless $OSNAME eq 'MSWin32';
        require FusionInventory::Agent::Tools::Win32;
        my $r = FusionInventory::Agent::Tools::Win32::getRegistryValue(path => $check->{path});

        return defined $r ? 'ok' : $check->{return};
    }

    if ($check->{type} eq 'winkeyEquals') {
        return unless $OSNAME eq 'MSWin32';
        require FusionInventory::Agent::Tools::Win32;
        my $r = FusionInventory::Agent::Tools::Win32::getValueFromRegistry(path => $check->{path});

        return defined $r && $check->{value} eq $r ? 'ok' : $check->{return};
    }
    
    if ($check->{type} eq 'winkeyMissing') {
        return unless $OSNAME eq 'MSWin32';
        require FusionInventory::Agent::Tools::Win32;
        my $r = FusionInventory::Agent::Tools::Win32::getValueFromRegistry(path => $check->{path});

        return defined $r ? $check->{return} : 'ok';
    } 

    if ($check->{type} eq 'fileExists') {
        return -f $check->{path} ? 'ok' : $check->{return};
    }

    if ($check->{type} eq 'fileSizeEquals') {
        my @s = stat($check->{path});
        return @s ? 'ok' : $check->{return};
    }

    if ($check->{type} eq 'fileSizeGreater') {
        my @s = stat($check->{path});
        return $check->{return} unless @s;

        return $check->{value} < $s[7] ? 'ok' : $check->{return};
    }

    if ($check->{type} eq 'fileSizeLower') {
        my @s = stat($check->{path});
        return $check->{return} unless @s;
        return $check->{value} > $s[7] ? 'ok' : $check->{return};
    }
    
    if ($check->{type} eq 'fileMissing') {
        return -f $check->{path} ? $check->{return} : 'ok';
    }
    
    if ($check->{type} eq 'freespaceGreater') {
        my $freespace = getFreeSpace(path => $check->{path});
        return $freespace>$check->{value}? "ok" : $check->{return};
    }

    if ($check->{type} eq 'fileSHA512') {
        my $sha = Digest::SHA->new('512');

        my $sha512 = "";
        eval {
            $sha->addfile($check->{path}, 'b');
            $sha512 = $sha->hexdigest;
        };


        return $sha512 eq $check->{value} ? "ok" : $check->{return};
    }

    print "Unknown check: `".$check->{type}."'\n";

    return "ok";
}

1;
