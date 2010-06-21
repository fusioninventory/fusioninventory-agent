package FusionInventory::Agent::Task::Inventory::OS::Generic::Printers::Cups;

use strict;
use warnings;

sub isInventoryEnabled {
    return 
        can_load("Net::CUPS") &&
        $Net::CUPS::VERSION >= 0.60;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger}; 
    my $config = $params->{config};

    return if $config->{'no-printer'};

    my $cups = Net::CUPS->new();
    my @printers = $cups->getDestinations();

    return unless scalar(@printers);
    foreach my $printer  (@printers) {

        my $printername = $printer->getUri();
        $printername =~ s/^.*\/\/([^\.]*).*$/$1/eg ;
        $printername =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
        $inventory->addPrinter({
            NAME    => $printername,
            DESCRIPTION => $printer->getDescription(),
            DRIVER => $printer->getOptionValue("printer-make-and-model"),
            PORT => $printer->getUri(), 
        });
    }

}
1;
