package FusionInventory::Agent::Task::Inventory::OS::MacOS::Videos;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return
        -r '/usr/sbin/system_profiler' &&
        can_load("Mac::SysProfile");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $prof = Mac::SysProfile->new();
    my $info = $prof->gettype('SPDisplaysDataType');
    return unless ref $info eq 'HASH';

    # add the video information
    foreach my $x (keys %$info){
        my $memory = $info->{$x}->{'VRAM (Total)'};
        $memory =~ s/ MB$//;
        $inventory->addEntry({
            section => 'VIDEOS',
            entry   => { 
                NAME    => $x,
                CHIPSET => $info->{$x}->{'Chipset Model'},
                MEMORY  => $memory,
            },
            noDuplicated => 1
        });

        # this doesn't work yet, need to fix the Mac::SysProfile module to not be such a hack (parser only goes down one level)
        # when we do fix it, it will attach the displays that sysprofiler shows in a tree form
        # apple "xml" blows. Hard.
        foreach my $display (keys %{$info->{$x}}){
            my $ref = $info->{$x}->{$display};
            next unless ref $ref eq 'HASH';

            $inventory->addEntry({
                section => 'MONITORS',
                entry   => {
                    CAPTION     => $ref->{'Resolution'},
                    DESCRIPTION => $display,
                }
            })
        }
    }

}

1;
