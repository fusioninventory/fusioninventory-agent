package Ocsinventory::Agent::Task::Inventory::OS::BSD::Sys;

#$LunchAfter = "Ocsinventory::Agent::Task::Inventory::OS::Linux::VirtualFs::Sys";

sub isInventoryEnabled {
	foreach (`mount`) {
		return 1 if (/type\ sysfs/);
	}
	return;
}

sub doInventory {
  # Hum?
	return "";
}

1
