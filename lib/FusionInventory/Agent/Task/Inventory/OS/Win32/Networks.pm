package FusionInventory::Agent::Task::Inventory::OS::Win32::Networks;
# http://techtasks.com/code/viewbookcode/1417


use strict;

# No check here. If Win32::OLE and Win32::OLE::Variant not available, the module
# will fail to load.

sub isInventoryEnabled {
  can_load("Win32::OLE") && can_load("Win32::OLE::Variant") && can_load("Net::IP qw(:PROC)");
}

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $strComputer = '.';
  my $objWMIService = Win32::OLE->GetObject('winmgmts:' . '{impersonationLevel=impersonate}!\\\\' . $strComputer . '\\root\\cimv2');

  #my $nics = $objWMIService->ExecQuery('SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True');
  my $nics = $objWMIService->ExecQuery('SELECT * FROM Win32_NetworkAdapterConfiguration');

print "\n";

foreach my $nic (in $nics) {
  my $description;
  my $ipaddress;
  my $ipgateway;
  my $ipmask;
  my $ipdhcp;
  my $ipsubnet;
  my $macaddr;
  my $status;
  my $type;

    $description = $nic->Description;

foreach ($nic->IPAddress) {
    $ipaddress += '/' if $ipaddress;
    $ipaddress += $_;
}
print ">>$ipaddress\n";
    $macaddr = $nic->MACAddress;

    $inventory->addNetwork({
	  DESCRIPTION => $description,
      IPADDRESS => $ipaddress,
      IPDHCP => $ipdhcp,
      IPGATEWAY => $ipgateway,
      IPMASK => $ipmask,
      IPSUBNET => $ipsubnet,
      MACADDR => $macaddr,
      STATUS => $status?"Up":"Down",
      TYPE => $type,
	});		
  }
}

1;
