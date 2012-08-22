package FusionInventory::Agent::Task::Inventory::Input::MacOS::License;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Generic::License;

sub isEnabled {
    return unless -f "/Library/Application Support/Adobe/Adobe PCD/cache/cache.db";
}


sub doInventory {
    my (%params) = @_;



    my @found = getAdobeLicenses( command => 'sqlite3 -separator " <> " "/Library/Application Support/Adobe/Adobe PCD/cache/cache.db" "SELECT * FROM domain_data"');

use Data::Dumper;
print Dumper(\@found);


        foreach my $license (@found) {
		$params{inventory}->addEntry(section => 'LICENSES', entry => $license);
}

}

1;
