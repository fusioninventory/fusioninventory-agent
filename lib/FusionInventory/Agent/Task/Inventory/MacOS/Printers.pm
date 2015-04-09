package FusionInventory::Agent::Task::Inventory::MacOS::Printers;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    my (%params) = @_;

    return
        !$params{no_category}->{printer} &&
        canRun('/usr/sbin/system_profiler');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $infos = getSystemProfilerInfos(type => 'SPPrintersDataType', logger => $logger);
    my $info = $infos->{Printers};

    foreach my $printer (keys %$info) {
        next unless ref($info->{printer}) eq 'HASH';

        $inventory->addEntry(
            section => 'PRINTERS',
            entry   => {
                NAME    => $printer,
                DRIVER  => $info->{$printer}->{PPD},
                PORT    => $info->{$printer}->{URI},
            }
        );
    }

}

1;
