package Ocsinventory::Agent::Backend::OS::Generic::Lspci;
use strict;

sub isInventoryEnabled {can_run("lspci")}


sub doInventory {}
1;
