package Ocsinventory::Agent::Task::Inventory::OS::Win32;

use strict;
use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Task::Inventory::OS::Generic"];

sub isInventoryEnabled { $^O =~ /^MSWin32$/ }

sub doInventory {

}

1;
