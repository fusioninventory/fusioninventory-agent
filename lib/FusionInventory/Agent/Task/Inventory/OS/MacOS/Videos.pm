package FusionInventory::Agent::Task::Inventory::OS::MacOS::Videos;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;
sub isInventoryEnabled {
    return
        -r '/usr/sbin/system_profiler'
}


sub _getDisplays {
    my $infos = getSystemProfilerInfos(@_);

    my $monitors = [];
    my $videos = [];

    foreach my $videoName (keys %{$infos->{'Graphics/Displays'}}) {
        my $videoCardInfo = $infos->{'Graphics/Displays'}{$videoName};

        my $displays = {};
        foreach my $displayName (keys %{$videoCardInfo->{Displays}}) {
            next if $displayName =~ /^Display Connector$/;
            next if $displayName =~ /^Display$/;
            my $displayInfo = $videoCardInfo->{Displays}{$displayName};


            my $resolution = $displayInfo->{Resolution};
            if ($resolution) {
                $resolution =~ s/\ //g;
                $resolution =~ s/\@.*//g;
            }

            my $memory = $videoCardInfo->{'VRAM (Total)'};
            $memory =~ s/\ .*//g if $memory;



#            use Data::Dumper;
#            print "display-BEGIN-\n";
#            print Dumper($displayInfo);
#            print "display-END-\n";
#            print "video-BEGIN-\n";
#            print Dumper($videoCardInfo);
#            print "video-END-\n";



            push @$videos, {
                CHIPSET => $videoCardInfo->{'Chipset Model'},
                MEMORY => $memory,
                NAME => $videoName,
                RESOLUTION => $resolution,
                PCISLOT => $videoCardInfo->{Slot}
            };

            push @$monitors, {
                CAPTION => $displayName,
                DESCRIPTION => $displayName,
                MANUFACTURER => '',
                SERIAL => '',
            }
        }
    }

    return (
        MONITORS => $monitors,
        VIDEOS => $videos
    );

}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my %displays = _getDisplays();
    foreach my $section (keys %displays ) {
        foreach (@{$displays{$section}}) {
            $inventory->addVideo($_);
        }
    }
}

1;
