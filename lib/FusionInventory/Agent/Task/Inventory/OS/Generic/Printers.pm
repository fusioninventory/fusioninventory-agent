package FusionInventory::Agent::Task::Inventory::OS::Generic::Printers;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    my (%params) = @_;

    return 
        # we use system profiler on MacOS
        $OSNAME ne 'darwin' &&
        !$params{no_printer} &&
        can_load("Net::CUPS") &&
        $Net::CUPS::VERSION >= 0.60;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $cups = Net::CUPS->new();
    my @printers = $cups->getDestinations();

    foreach my $printer (@printers) {
        my $name = $printer->getUri();
        $name =~ s/^.*\/\/([^\.]*).*$/$1/eg ;
        $name =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
        $inventory->addEntry(
            section => 'PRINTERS',
            entry   => {
                NAME        => $name,
                DESCRIPTION => $printer->getDescription(),
                DRIVER      => $printer->getOptionValue(
                                   "printer-make-and-model"
                               ),
                PORT        => $printer->getUri(), 
            }
        );
    }

}

1;
