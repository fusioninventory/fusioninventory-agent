package FusionInventory::Agent::Task::Inventory::OS::Win32::Networks;

use strict;
use warnings;

use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;
use Win32::OLE::Enum;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;
use FusionInventory::Agent::Regexp;
 
Win32::OLE-> Option(CP=>CP_UTF8);


# http://techtasks.com/code/viewbookcode/1417
sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    my $WMIService = Win32::OLE->GetObject(
        'winmgmts:{impersonationLevel=impersonate}!\\\\.\\root\\cimv2'
    ) or die "WMI connection failed: " . Win32::OLE->LastError();

    my $defaultGw;
    my %ips;
    my @ip6s;
    my @interfaces;
    my %defaultgateways;
    my %dns;

    my $nics = $WMIService->ExecQuery(
        'SELECT * FROM Win32_NetworkAdapterConfiguration'
    );
    foreach my $nic (in $nics) {
        my $interface = $interfaces[$nic->Index];

        $interface->{DESCRIPTION} = encodeFromWmi($nic->Description)

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
                if ($address =~ /$ip_address_pattern/) {
                    $ips{$address}=1;
                    push @{$interface->{IPADDRESS}}, $address;
                    push @{$interface->{IPMASK}}, $mask;
                    push @{$interface->{IPSUBNET}},
                        getSubnetAddress($address, $mask);
                } elsif ($address =~ /\S+/) {
                    push @ip6s, $address;
                    push @{$interface->{IPADDRESS6}}, $address;
                    push @{$interface->{IPMASK6}}, $mask;
                    push @{$interface->{IPSUBNET6}},
                        getSubnetAddressIPv6($address, $mask);
                }
            }
        }

        if ($nic->DefaultIPGateway) {
            $interface->{IPGATEWAY} = $nic->DefaultIPGateway()->[0];
        }

        $interface->{STATUS}  = $nic->IPEnabled ? "Up" : "Down";
        $interface->{IPDHCP}  = $nic->DHCPServer;
        $interface->{MACADDR} = $nic->MACAddress;
        $interface->{MTU}     = $nic->MTU;

    }

    $nics = $objWMIService->ExecQuery('SELECT * FROM Win32_NetworkAdapter');
    foreach my $nic (in $nics) {
        my $interface = $interfaces[$nic->Index];

        my $virtualdev = 0;
        # PhysicalAdapter only work on OS > XP
        if (!defined($nic->PhysicalAdapter)) {
            if ($nic->PNPDeviceID =~ /^ROOT/) {
                $virtualdev = 1;
            }
        } else {
            $virtualdev = $nic->PhysicalAdapter ? 0 : 1;
        }

        $interface->{NAME} = $nic->Name;
        $interface->{SPEED} = $nic->Speed;
        $interface->{VIRTUALDEV}  = $virtualdev;
        $interface->{MACADDR}     = $nic->MACAddress;
        $interface->{PNPDEVICEID} = $nic->PNPDeviceID;
    }

    foreach my $interface (@interfaces) {

        # http://comments.gmane.org/gmane.comp.monitoring.fusion-inventory.devel/34
        next unless $interface->{PNPDEVICEID};

        next if
            !$interface->{IPADDRESS} &&
            !$interface->{IPADDRESS6} &&
            !$interface->{MACADDR}

        # flatten multivalued keys
        foreach my $key (qw/IPADDRESS IPMASK IPSUBNET IPADDRESS6/) {
            next unless $interface->{$key};
            $interface->{$key} = join('/', @{$interface->{$key}});
        }

        $inventory->addEntry({
            section => 'NETWORKS',
            entry   => $interface
        });
    }

    $inventory->setHardware({
        DEFAULTGATEWAY => join ('/',keys %defaultgateways),
        DNS            => join('/', keys %dns),
        IPADDR         => join('/', keys %ips),
    });

}

1;
