package FusionInventory::Agent::Task::Inventory::OS::Win32::Networks;


use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;
 
Win32::OLE-> Option(CP=>CP_UTF8);
 
use Win32::OLE::Enum;

# http://techtasks.com/code/viewbookcode/1417

sub isInventoryEnabled {1}

sub doInventory {
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

        if ($nic->DefaultIPGateway) {
            $netifs[$idx]{ipgateway} = $nic->DefaultIPGateway()->[0];
        }
        if ($nic->IPSubnet) {
            $netifs[$idx]{ipsubnet} = $nic->IPSubnet()->[0];
        }
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
                DESCRIPTION => $netif->{description}->utf8,
                IPADDRESS => $netif->{ipaddress},
                IPDHCP => $netif->{ipdhcp},
                IPGATEWAY => $netif->{ipgateway},
                IPMASK => $netif->{ipmask},
                IPSUBNET => $netif->{ipsubnet},
                MACADDR => $netif->{macaddr},
                MTU => $netif->{mtu},
                STATUS => $netif->{status},
                TYPE => $netif->{type}->utf8,
                VIRTUALDEV => $netif->{virtualdev}
            });



    }
}
1;
