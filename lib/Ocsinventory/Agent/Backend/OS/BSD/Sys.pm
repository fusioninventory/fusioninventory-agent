package Ocsinventory::Agent::Backend::OS::BSD::Sys;

#$LunchAfter = "Ocsinventory::Agent::Backend::OS::Linux::VirtualFs::Sys";

sub check {
	foreach (`mount`) {
		return 1 if (/type\ sysfs/);
	}
	return;
}

sub run {
  # Hum?
	return "";
}

1
