package FusionInventory::Agent::Task::Inventory::Input::Win32::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::Win32;
 
sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my (@gateways, @dns, @ips);

    foreach my $interface (_getInterfaces()) {
        push @gateways, $interface->{IPGATEWAY}
            if $interface->{IPGATEWAY};

        push @dns, $interface->{dns}
            if $interface->{dns};

        push @ips, @{$interface->{IPADDRESS}}
            if $interface->{IPADDRESS};

        delete $interface->{dns};

        # flatten multivalued keys
        foreach my $key (qw/IPADDRESS IPMASK IPSUBNET IPADDRESS6/) {
            next unless $interface->{$key};
            $interface->{$key} = join('/', @{$interface->{$key}});
        }

        $inventory->addEntry(
            section => 'NETWORKS',
            entry   => $interface
        );
    }

    $inventory->setHardware({
        DEFAULTGATEWAY => join('/', uniq @gateways),
        DNS            => join('/', uniq @dns),
        IPADDR         => join('/', uniq @ips),
    });

}

sub _getInterfaces {

    my @interfaces;

    foreach my $object (getWmiObjects(
        class      => 'Win32_NetworkAdapterConfiguration',
        properties => [ qw/Index Description IPEnabled DHCPServer MACAddress 
                           MTU DefaultIPGateway DNSServerSearchOrder IPAddress
                           IPSubnet/  ]
    )) {

        my $interface = {
            DESCRIPTION => $object->{Description},
            STATUS      => $object->{IPEnabled} ? "Up" : "Down",
            IPDHCP      => $object->{DHCPServer},
            MACADDR     => $object->{MACAddress},
            MTU         => $object->{MTU}
        };

        if ($object->{DefaultIPGateway}) {
            $interface->{IPGATEWAY} = $object->{DefaultIPGateway}->[0];
        }

        if ($object->{DNSServerSearchOrder}) {
            $interface->{dns} = $object->{DNSServerSearchOrder}->[0];
        }

        if ($object->{IPAddress}) {
            foreach my $address (@{$object->{IPAddress}}) {
                my $mask = shift @{$object->{IPSubnet}};
                if ($address =~ /$ip_address_pattern/) {
                    push @{$interface->{IPADDRESS}}, $address;
                    push @{$interface->{IPMASK}}, $mask;
                    push @{$interface->{IPSUBNET}},
                        getSubnetAddress($address, $mask);
                } elsif ($address =~ /\S+/) {
                    push @{$interface->{IPADDRESS6}}, $address;
                    push @{$interface->{IPMASK6}}, $mask;
                    push @{$interface->{IPSUBNET6}},
                        getSubnetAddressIPv6($address, $mask);
                }
            }
        }

        $interfaces[$object->{Index}] = $interface;
    }

    foreach my $object (getWmiObjects(
        class      => 'Win32_NetworkAdapter',
        properties => [ qw/Index PNPDeviceId Speed MACAddress PhysicalAdapter 
                           AdapterType/  ]
    )) {
        # http://comments.gmane.org/gmane.comp.monitoring.fusion-inventory.devel/34
        next unless $object->{PNPDeviceId};

        my $interface = $interfaces[$object->{Index}];

        $interface->{SPEED}       = $object->{Speed};
        $interface->{MACADDR}     = $object->{MACAddress};
        $interface->{PNPDEVICEID} = $object->{PNPDeviceId};

        # PhysicalAdapter only work on OS > XP
        if (defined $object->{PhysicalAdapter}) {
            $interface->{VIRTUALDEV} = $object->{PhysicalAdapter} ? 0 : 1;
        # http://forge.fusioninventory.org/issues/1166 
        } elsif ($interface->{DESCRIPTION}
              && $interface->{DESCRIPTION} =~ /RAS/
              && $interface->{DESCRIPTION} =~ /Adapter/i) {
            $interface->{VIRTUALDEV} = 1;
        } else {
            $interface->{VIRTUALDEV} = $object->{PNPDeviceId} =~ /^ROOT/ ? 1 : 0;
        }

        if (defined $object->{AdapterType}) {
            $interface->{TYPE} = $object->{AdapterType};
            $interface->{TYPE} =~ s/Ethernet.*/Ethernet/;
        }
    }

    # exclude pure virtual interfaces
    return
        grep { $_->{IPADDRESS} || $_->{IPADDRESS6} || $_->{MACADDR} }
        @interfaces;

}

1;
