package FusionInventory::Agent::Task::Inventory::OS::Generic::Printers::Cups;
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

    my $cups = Net::CUPS->new();
    my @printers = $cups->getDestinations();

    return unless scalar(@printers);

    foreach my $printer  (@printers)
    {
        $inventory->addPrinter({
            NAME    => $printer->getName(),
            DESCRIPTION => $printer->getDescription(),
            DRIVER => $printer->getOptionValue("printer-make-and-model"),
            PORT => $printer->getUri() 
        });
    }

}
1;
