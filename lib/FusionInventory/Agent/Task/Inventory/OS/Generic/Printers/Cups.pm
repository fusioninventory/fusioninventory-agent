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
    my $printer = $cups->getDestination();

    return unless $printer;

    # Just grab the default printer, is I use getDestinations, CUPS
    # returns all the printer of the local subnet (is it can)
    # TODO There is room for improvement here
    $inventory->addPrinter({
            NAME    => $printer->getName(),
            DESCRIPTION => $printer->getDescription(),
#                DRIVER =>  How to get the PPD?!!
        });

}
1;
