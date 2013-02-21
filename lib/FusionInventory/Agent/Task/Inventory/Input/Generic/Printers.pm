package FusionInventory::Agent::Task::Inventory::Input::Generic::Printers;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isEnabled {
    my (%params) = @_;

    return
        # we use system profiler on MacOS
        $OSNAME ne 'darwin' &&
        !$params{no_category}->{printer} &&
        canLoad("Net::CUPS") &&
        $Net::CUPS::VERSION >= 0.60;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $cups = Net::CUPS->new();
    my @printers = $cups->getDestinations();

    foreach my $printer (@printers) {
        my $uri = $printer->getUri();
        my $name = $uri;
        $name =~ s/^.*\/\/([^\.]*).*$/$1/eg ;
        $name =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
        $inventory->addEntry(
            section => 'PRINTERS',
            entry   => {
                NAME        => $name,
                PORT        => $uri,
                DESCRIPTION => $printer->getDescription(),
                DRIVER      => $printer->getOptionValue(
                                   "printer-make-and-model"
                               ),
            }
        );
    }

}

1;
