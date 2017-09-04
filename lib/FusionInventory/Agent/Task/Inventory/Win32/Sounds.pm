package FusionInventory::Agent::Task::Inventory::Win32::Sounds;

use strict;
use warnings;

use Storable 'dclone';

use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{sound};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $wmiParams = {};
    $wmiParams->{WMIService} = dclone ($params{inventory}->{WMIService}) if $params{inventory}->{WMIService};
    foreach my $object (getWMIObjects(
        %$wmiParams,
        class      => 'Win32_SoundDevice',
        properties => [ qw/
            Name Manufacturer Caption Description
        / ]
    )) {

        $inventory->addEntry(
            section => 'SOUNDS',
            entry   => {
                NAME         => $object->{Name},
                CAPTION      => $object->{Caption},
                MANUFACTURER => $object->{Manufacturer},
                DESCRIPTION  => $object->{Description},
            }
        );
    }
}

1;
