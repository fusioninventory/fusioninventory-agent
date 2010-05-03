package FusionInventory::Agent::Task::Inventory::OS::Generic::Printers::Cups;
use URI::Split qw(uri_split uri_join);
use strict;

sub isInventoryEnabled {
    # If we are on a MAC, Mac::SysProfile will do the job
    return if -r '/usr/sbin/system_profiler';
    return unless can_load("Net::CUPS");
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger}; 

    my $cups = Net::CUPS->new();
    my @printers = $cups->getDestinations();

    return unless scalar(@printers);
    foreach my $printer  (@printers)
    {

        my $printername = $printer->getUri();
        $logger->debug("printer name avant: $printername");
        $printername =~ s/^.*\/\/([^\.]*).*$/$1/eg ;
        $printername =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
        $logger->debug("printer name apres: $printername");
        $inventory->addPrinter({
            #NAME    => $printer->getName(),
            NAME    => $printername,
            DESCRIPTION => $printer->getDescription(),
            DRIVER => $printer->getOptionValue("printer-make-and-model"),
            PORT => $printer->getUri(), 
        });
    }

}
1;
