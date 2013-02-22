package FusionInventory::Agent::Task::Inventory::Win32;

use strict;
use warnings;

use English qw(-no_match_vars);

our $runAfter = ["FusionInventory::Agent::Task::Inventory::Generic"];

sub isEnabled {
    return $OSNAME eq 'MSWin32';
}

sub doInventory {

}

1;
