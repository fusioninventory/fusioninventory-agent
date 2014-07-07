package FusionInventory::Agent::Task::Inventory::Generic::Dmidecode;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::Tools;

sub isEnabled {

    # don't run dmidecode on Win2003
    # http://forge.fusioninventory.org/issues/379
    if ($OSNAME eq 'MSWin32') {
        Win32->require();
        return if Win32::GetOSName() eq 'Win2003';
    }

    return canRun('dmidecode');
}

sub doInventory {}

1;
