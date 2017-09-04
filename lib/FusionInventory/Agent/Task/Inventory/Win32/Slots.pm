package FusionInventory::Agent::Task::Inventory::Win32::Slots;

use strict;
use warnings;

use Storable 'dclone';

use FusionInventory::Agent::Tools::Win32;

my %status = (
    3 => 'free',
    4 => 'used'
);

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{slot};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $wmiParams = {};
    $wmiParams->{WMIService} = dclone ($params{inventory}->{WMIService}) if $params{inventory}->{WMIService};
    foreach my $object (getWMIObjects(
        %$wmiParams,
        class      => 'Win32_SystemSlot',
        properties => [ qw/Name Description SlotDesignation CurrentUsage/ ]
    )) {
        if (!defined($object->{CurrentUsage})) {
            $params{logger}->debug2("ignoring usage-less '$object->{Name}' slot")
                if ($params{logger} && $object->{Name});
            next;
        }

        $inventory->addEntry(
            section => 'SLOTS',
            entry   => {
                NAME        => $object->{Name},
                DESCRIPTION => $object->{Description},
                DESIGNATION => $object->{SlotDesignation},
                STATUS      => $status{$object->{CurrentUsage}}
            }
        );
    }

}

1;
