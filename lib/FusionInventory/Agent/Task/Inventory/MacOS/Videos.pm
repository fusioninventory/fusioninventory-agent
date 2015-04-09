package FusionInventory::Agent::Task::Inventory::MacOS::Videos;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{video};
    return canRun('/usr/sbin/system_profiler');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my %displays = _getDisplays(logger => $logger);

    foreach my $monitor (@{$displays{MONITORS}}) {
        $inventory->addEntry(
            section => 'MONITORS',
            entry   => $monitor,
        );
    }

    foreach my $video (@{$displays{VIDEOS}}) {
        $inventory->addEntry(
            section => 'VIDEOS',
            entry   => $video,
        );
    }
}

sub _getDisplays {
    my (%params) = @_;

    my $infos = getSystemProfilerInfos(
        type   => 'SPDisplaysDataType',
        logger => $params{logger},
        file   => $params{file}
    );

    my @monitors;
    my @videos;

    foreach my $videoName (keys %{$infos->{'Graphics/Displays'}}) {
        my $videoCardInfo = $infos->{'Graphics/Displays'}->{$videoName};
        foreach my $displayName (keys %{$videoCardInfo->{Displays}}) {
            next if $displayName eq 'Display Connector';
            next if $displayName eq 'Display';
            my $displayInfo = $videoCardInfo->{Displays}->{$displayName};

            my $resolution = $displayInfo->{Resolution};
            if ($resolution) {
                $resolution =~ s/\ //g;
                $resolution =~ s/\@.*//g;
            }

            my $memory = $videoCardInfo->{'VRAM (Total)'};
            $memory =~ s/\ .*//g if $memory;

            push @videos, {
                CHIPSET    => $videoCardInfo->{'Chipset Model'},
                MEMORY     => $memory,
                NAME       => $videoName,
                RESOLUTION => $resolution,
                PCISLOT    => $videoCardInfo->{Slot}
            };

            push @monitors, {
                CAPTION     => $displayName,
                DESCRIPTION => $displayName,
            }
        }
    }

    return (
        MONITORS => \@monitors,
        VIDEOS   => \@videos
    );

}

1;
