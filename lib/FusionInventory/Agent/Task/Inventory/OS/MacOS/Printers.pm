package FusionInventory::Agent::Task::Inventory::OS::MacOS::Printers;

use strict;
use warnings;

use constant DATATYPE => 'SPPrintersDataType';

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

    my $pro = Mac::SysProfile->new();
    my $h = $pro->gettype(DATATYPE());
    return(undef) unless(ref($h) eq 'HASH');

    foreach my $printer (keys %$h){
        if ($printer && $printer =~ /^The printers list is empty. To add printers/) {
#http://forge.fusioninventory.org/issues/169
            next;
        }

        $inventory->addPrinter({
            NAME    => $printer,
            DRIVER  => $h->{$printer}->{'PPD'},
            PORT    => $h->{$printer}->{'URI'},
        });
    }

}

1;
