package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    my $isWin2003;

    eval '
	use Win32;
    my(@osver) = Win32::GetOSVersion();
    $isWin2003 = ($osver[4] == 2 && $osver[1] == 5 && $osver[2] == 2);
    ';

# http://forge.fusioninventory.org/issues/379
    return if $isWin2003;

    if (can_run("dmidecode")) {
        my @output = `dmidecode`;

        return 1 if @output > 10;
    }

    return 0;
}

sub doInventory {}

1;
