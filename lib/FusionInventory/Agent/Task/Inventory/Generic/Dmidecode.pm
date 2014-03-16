package FusionInventory::Agent::Task::Inventory::Generic::Dmidecode;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::Tools::Generic;

sub isEnabled {

    # don't run dmidecode on Win2003
    # http://forge.fusioninventory.org/issues/379
    if ($OSNAME eq 'MSWin32') {
        Win32->require();
        my @osver = Win32::GetOSVersion();
        return if
            $osver[4] == 2 &&
            $osver[1] == 5 &&
            $osver[2] == 2;
    }

    return canRun('dmidecode');
}

sub doInventory {}

1;
