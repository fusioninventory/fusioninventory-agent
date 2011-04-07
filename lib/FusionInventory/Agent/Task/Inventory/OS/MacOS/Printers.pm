package FusionInventory::Agent::Task::Inventory::OS::MacOS::Printers;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    my ($params) = @_;

    return 
        !$params->{config}->{no_printer} &&
        -r '/usr/sbin/system_profiler' &&
        can_load("Mac::SysProfile");
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    my $prof = Mac::SysProfile->new();
    my $info = $prof->gettype('SPPrintersDataType');
    return unless ref $info eq 'HASH';

    foreach my $printer (keys %$info) {
        if ($printer && $printer =~ /^The printers list is empty. To add printers/) {
#http://forge.fusioninventory.org/issues/169
            next;
        }

        $inventory->addPrinter({
            NAME    => $printer,
            DRIVER  => $info->{$printer}->{'PPD'},
            PORT    => $info->{$printer}->{'URI'},
        });
    }

}

1;
