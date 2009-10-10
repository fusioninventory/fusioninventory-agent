package Ocsinventory::Agent::Backend::OS::Win32;

use strict;
use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::Generic"];

sub isInventoryEnabled { $^O =~ /^MSWin32$/ }

sub doInventory {

}

1;
