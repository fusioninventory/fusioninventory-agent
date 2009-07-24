package Ocsinventory::Agent::Backend::Virtualization::VirtualBox;
#
# Initial version: Nicolas Eisen <nico92856@hotmail.com>
#
use strict;

sub check { return can_run('VirtualBox') and can_run('VBoxManage') }

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

    foreach my $vm (`VBoxManage -nologo list vms`){
        if ($vm =~ m/^UUID:\s+(.*)/) {
	    my $uuid = $1;
	    my $mem;
	    my $status;
	    my $name;
	    my $vcpu = 1;
	    foreach my $value (`VBoxManage -nologo showvminfo $uuid`) {
#                       print $value;
		if ($value =~ m/^Name:\s+(.*)/)        { $name = $1;}
		if ($value =~ m/^Memory size:\s+(.*)/) { $mem = $1;}
		if ($value =~ m/^State:\s+(.*)\(.*/)   { $status = ( $1 =~ m/off/ ? "off" : $1 ); }
	    }

	    $inventory->addVirtualMachine ({
		NAME      => $name,
		VCPU      => $vcpu,
		UUID      => $uuid,
		MEMORY    => $mem,
		STATUS    => $status,
		SUBSYSTEM => "Sun xVM VirtualBox",
		VMTYPE    => "VirtualBox",
	   });
        }
    }
}

1;
