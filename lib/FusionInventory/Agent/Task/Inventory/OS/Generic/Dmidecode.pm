package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {

    my $isWin2003;

    eval '
	use Win32;
    my(@osver) = Win32::GetOSVersion();
    $isWin2003 = ($osver[4] == 2 && $osver[1] == 5 && $osver[2] == 2);
    ';

# http://forge.fusioninventory.org/issues/379
    return if $isWin2003;

    return unless can_run('dmidecode');

    my @output = `dmidecode`;
    return @output > 10;
}

sub doInventory {}

1;
