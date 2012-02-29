package FusionInventory::Agent::Task::Inventory::Input::MacOS::Printers;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    my (%params) = @_;

    return 
        !$params{no_category}->{printer} &&
        -r '/usr/sbin/system_profiler' &&
        canLoad("Mac::SysProfile");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $prof = Mac::SysProfile->new();
    my $info = $prof->gettype('SPPrintersDataType');
    return unless ref $info eq 'HASH';

    foreach my $printer (keys %$info) {
        if ($printer && (
            $printer =~ /list is empty/
            ||
            $printer =~ /^Status/
            ||
            $printer =~ /^CUPS Version/
            )            ) {
#http://forge.fusioninventory.org/issues/169
#https://bugs.launchpad.net/bugs/901570
                next;
        }

        $inventory->addEntry(
            section => 'PRINTERS',
            entry   => {
                NAME    => $printer,
                DRIVER  => $info->{$printer}->{'PPD'},
                PORT    => $info->{$printer}->{'URI'},
            }
        );
    }

}

1;
