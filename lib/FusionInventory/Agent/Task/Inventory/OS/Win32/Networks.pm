package FusionInventory::Agent::Task::Inventory::OS::Win32::Networks;


use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;
use Win32::OLE::Enum;
 
use FusionInventory::Agent::Tools::Win32;
use FusionInventory::Agent::Tools;

Win32::OLE->Option(CP=>CP_UTF8);

# http://techtasks.com/code/viewbookcode/1417
sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $strComputer = '.';
    my $objWMIService = Win32::OLE->GetObject('winmgmts:' . '{impersonationLevel=impersonate}!\\\\' . $strComputer . '\\root\\cimv2');


    my $defaultGw;
    my @ips;
    my @ip6s;
    my @interfaces;
    my %defaultgateways;
    my %dns;

    my $nics = $objWMIService->ExecQuery('SELECT * FROM Win32_NetworkAdapterConfiguration');
    foreach my $nic (in $nics) {
        my $interface = $interfaces[$nic->Index];

        $interface->{description} = encodeFromWmi($nic->Description);

        foreach (@{$nic->DefaultIPGateway || []}) {
            $defaultgateways{$_} = 1;
        }

        foreach (@{$nic->DNSServerSearchOrder || []}) {
            $dns{$_} = 1;
        }

        if ($nic->IPAddress) {
            while (@{$nic->IPAddress}) {
                my $address = shift @{$nic->IPAddress};
                my $mask = shift @{$nic->IPSubnet};
                if ($address =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/) {
                    push @ips, $address;
                    push @{$interface->{ipaddress}}, $address;
                    push @{$interface->{ipmask}}, $mask;
                    push @{$interface->{ipsubnet}}, getSubnetAddress($address, $mask);
                } elsif ($address =~ /\S+/) {
                    push @ip6s, $address;
                    push @{$interface->{ipaddress6}}, $address;
                    push @{$interface->{ipmask6}}, $mask;
                    push @{$interface->{ipsubnet6}}, getSubnetAddressIPv6($address, $mask);
                }
            }
        }

        if ($nic->DefaultIPGateway) {
            $interface->{ipgateway} = $nic->DefaultIPGateway()->[0];
        }

        $interface->{status}  = $nic->IPEnabled ? "Up" : "Down";
        $interface->{name}    = $nic->Name;
        $interface->{ipdhcp}  = $nic->DHCPServer;
        $interface->{macaddr} = $nic->MACAddress;
        $interface->{mtu}     = $nic->MTU;

    }

    $nics = $objWMIService->ExecQuery('SELECT * FROM Win32_NetworkAdapter');
    foreach my $nic (in $nics) {
        my $interface = $interfaces[$nic->Index];

        $interface->{virtualdev}  = $nic->PhysicalAdapter?0:1;
        $interface->{name}        = $nic->Name;
        $interface->{macaddr}     = $nic->MACAddress;
        $interface->{speed}       = $nic->Speed;
        $interface->{pnpdeviceid} = $nic->PNPDeviceID;
    }

    foreach my $interface (@interfaces) {

        # http://comments.gmane.org/gmane.comp.monitoring.fusion-inventory.devel/34
        next unless $netif->{pnpdeviceid};

        next if
            !$interface->{ipaddress} &&
            !$interface->{ipaddress6} &&
            !$interface->{macaddr}

        my $ipaddress  = $interface->{ipaddress}  ? join('/', @{$interface->{ipaddress})  : undef;
        my $ipmask     = $interface->{ipmask}     ? join('/', @{$interface->{ipmask})     : undef;
        my $ipsubnet   = $interface->{ipsubnet}   ? join('/', @{$interface->{ipsubnet})   : undef;
        my $ipaddress6 = $interface->{ipaddress6} ? join('/', @{$interface->{ipaddress6}) : undef;

        $inventory->addNetwork({
            DESCRIPTION => $interface->{description},
            IPADDRESS => $ipaddress,
            IPDHCP => $interface->{ipdhcp},
            IPGATEWAY => $interface->{ipgateway},
            IPMASK => $ipmask,
            IPSUBNET => $ipsubnet,
            IPADDRESS6 => $ipaddress6,
            MACADDR => $interface->{macaddr},
            MTU => $interface->{mtu},
            STATUS => $interface->{status},
            TYPE => $interface->{type},
            VIRTUALDEV => $interface->{virtualdev}
        });

    }


    $inventory->setHardware(
        DEFAULTGATEWAY => join('/', keys %defaultgateways),
        DNS            => join('/', keys %dns),
        IPADDR         => join('/', @ips),
    );

}

1;
