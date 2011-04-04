package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {

    eval {
        # don't run dmidecode on Win2003
        # http://forge.fusioninventory.org/issues/379
        require Win32;
        my @osver = Win32::GetOSVersion();
        return if
            $osver[4] == 2 &&
            $osver[1] == 5 &&
            $osver[2] == 2;
    };

    return unless can_run('dmidecode');

    my $count = getLinesCount(
        command => "dmidecode"
    );
    return $count > 10;
}

sub doInventory {}

1;
