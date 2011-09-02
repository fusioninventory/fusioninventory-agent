package FusionInventory::Agent::Task::Inventory::Input::Generic::Dmidecode;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::Tools;

sub isEnabled {

    if ($OSNAME eq 'MSWin32') {
        # don't run dmidecode on Win2003
        # http://forge.fusioninventory.org/issues/379
        Win32->require();
        my @osver = Win32::GetOSVersion();
        return if
            $osver[4] == 2 &&
            $osver[1] == 5 &&
            $osver[2] == 2;
    }

    return unless canRun('dmidecode');

    my $count = getLinesCount(
        command => "dmidecode"
    );
    return $count > 10;
}

sub doInventory {}

1;
