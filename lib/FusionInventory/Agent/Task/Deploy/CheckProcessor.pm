package FusionInventory::Agent::Task::Deploy::CheckProcessor;

use strict;
use warnings;

use English qw(-no_match_vars);
use Digest::SHA;

use FusionInventory::Agent::Task::Deploy::DiskFree;

sub process {
    my ($self, %params) = @_;

    if ($params{check}->{type} eq 'winkeyExists') {
        return unless $OSNAME eq 'MSWin32';
        require FusionInventory::Agent::Tools::Win32;

        my $path = $params{check}->{path};
        $path =~ s{\\}{/}g;

        my $r = FusionInventory::Agent::Tools::Win32::getRegistryValue(path => $path);

        return defined $r ? 'ok' : $params{check}->{return};
    }

    if ($params{check}->{type} eq 'winkeyEquals') {
        return unless $OSNAME eq 'MSWin32';
        require FusionInventory::Agent::Tools::Win32;

        my $path = $params{check}->{path};
        $path =~ s{\\}{/}g;

        my $r = FusionInventory::Agent::Tools::Win32::getRegistryValue(path => $path);

        return defined $r && $params{check}->{value} eq $r ? 'ok' : $params{check}->{return};
    }
    
    if ($params{check}->{type} eq 'winkeyMissing') {
        return unless $OSNAME eq 'MSWin32';
        require FusionInventory::Agent::Tools::Win32;

        my $path = $params{check}->{path};
        $path =~ s{\\}{/}g;

        my $r = FusionInventory::Agent::Tools::Win32::getRegistryValue(path => $path);

        return defined $r ? $params{check}->{return} : 'ok';
    } 

    if ($params{check}->{type} eq 'fileExists') {
        return -f $params{check}->{path} ? 'ok' : $params{check}->{return};
    }

    if ($params{check}->{type} eq 'fileSizeEquals') {
        my @s = stat($params{check}->{path});
        return @s ? 'ok' : $params{check}->{return};
    }

    if ($params{check}->{type} eq 'fileSizeGreater') {
        my @s = stat($params{check}->{path});
        return $params{check}->{return} unless @s;

        return $params{check}->{value} < $s[7] ? 'ok' : $params{check}->{return};
    }

    if ($params{check}->{type} eq 'fileSizeLower') {
        my @s = stat($params{check}->{path});
        return $params{check}->{return} unless @s;
        return $params{check}->{value} > $s[7] ? 'ok' : $params{check}->{return};
    }
    
    if ($params{check}->{type} eq 'fileMissing') {
        return -f $params{check}->{path} ? $params{check}->{return} : 'ok';
    }
    
    if ($params{check}->{type} eq 'freespaceGreater') {
        my $freespace = getFreeSpace(logger => $params{logger}, path => $params{check}->{path});
        return $freespace>$params{check}->{value}? "ok" : $params{check}->{return};
    }

    if ($params{check}->{type} eq 'fileSHA512') {
        my $sha = Digest::SHA->new('512');

        my $sha512 = "";
        eval {
            $sha->addfile($params{check}->{path}, 'b');
            $sha512 = $sha->hexdigest;
        };


        return $sha512 eq $params{check}->{value} ? "ok" : $params{check}->{return};
    }

    print "Unknown check: `".$params{check}->{type}."'\n";

    return "ok";
}

1;
