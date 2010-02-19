package FusionInventory::Agent::Task::Inventory::OS::Win32::Networks;


# http://techtasks.com/code/viewbookcode/1417

use strict;

# No check here. If Win32::OLE and Win32::OLE::Variant not available, the module
# will fail to load.
use Win32::OLE;
use Win32::OLE::Variant;


sub check {1}

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $strComputer = '.';
    my $objWMIService = Win32::OLE->GetObject('winmgmts:' . '{impersonationLevel=impersonate}!\\\\' . $strComputer . '\\root\\cimv2');

    my $nics = $objWMIService->ExecQuery('SELECT * FROM Win32_NetworkAdapterConfiguration');

    my @netifs;
    foreach my $nic (in $nics) {
        my $idx = $nic->Index;
        $netifs[$idx]{description} = $nic->Description;

        if ($nic->IPAddress) {
            foreach (@{$nic->IPAddress}) {
                $netifs[$idx]{ipaddress} .= '/' if $netifs[$idx]{ipaddress};
                $netifs[$idx]{ipaddress} .= $_;
            }
        }

        $netifs[$idx]{ipgateway} = $nic->DefaultIPGateway;
        $netifs[$idx]{ipsubnet} = $nic->IPSubnet;
        $netifs[$idx]{status} = $nic->IPEnabled?"Up":"Down";
        $netifs[$idx]{name} = $nic->Name;
        $netifs[$idx]{ipdhcp} = $nic->DHCPServer;
        $netifs[$idx]{macaddr} = $nic->MACAddress;
        $netifs[$idx]{mtu} = $nic->MTU;
    }

    $nics = $objWMIService->ExecQuery('SELECT * FROM Win32_NetworkAdapter');
    foreach my $nic (in $nics) {
        my $idx = $nic->Index;
        $netifs[$idx]{virtualdev} = $nic->PhysicalAdapter?0:1;
        $netifs[$idx]{name} = $nic->Name;
        $netifs[$idx]{macaddr} = $nic->MACAddress;
        $netifs[$idx]{speed} = $nic->Speed;
    }

    foreach my $netif (@netifs) {
        $inventory->addNetwork({
                DESCRIPTION => $netif->{description},
                IPADDRESS => $netif->{ipaddress},
                IPDHCP => $netif->{ipdhcp},
                IPGATEWAY => $netif->{ipgateway},
                IPMASK => $netif->{ipmask},
                IPSUBNET => $netif->{ipsubnet},
                MACADDR => $netif->{macaddr},
                STATUS => $netif->{status},
                TYPE => $netif->{type},
                VIRTUALDEV => $netif->{virtualdev}
            });



    }
}
1;
