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

    my @configurations;

    foreach my $object (getWmiObjects(
        class      => 'Win32_NetworkAdapterConfiguration',
        properties => [ qw/Index Description IPEnabled DHCPServer MACAddress
                           MTU DefaultIPGateway DNSServerSearchOrder IPAddress
                           IPSubnet/  ]
    )) {

        my $configuration = {
            DESCRIPTION => $object->{Description},
            STATUS      => $object->{IPEnabled} ? "Up" : "Down",
            IPDHCP      => $object->{DHCPServer},
            MACADDR     => $object->{MACAddress},
            MTU         => $object->{MTU}
        };

        if ($object->{DefaultIPGateway}) {
            $configuration->{IPGATEWAY} = $object->{DefaultIPGateway}->[0];
        }

        if ($object->{DNSServerSearchOrder}) {
            $configuration->{dns} = $object->{DNSServerSearchOrder}->[0];
        }

        if ($object->{IPAddress}) {
            foreach my $address (@{$object->{IPAddress}}) {
                my $mask = shift @{$object->{IPSubnet}};
                if ($address =~ /$ip_address_pattern/) {
                    push @{$configuration->{IPADDRESS}}, $address;
                    push @{$configuration->{IPMASK}}, $mask;
                    push @{$configuration->{IPSUBNET}},
                        getSubnetAddress($address, $mask);
                } elsif ($address =~ /\S+/) {
                    push @{$configuration->{IPADDRESS6}}, $address;
                    push @{$configuration->{IPMASK6}}, $mask;
                    push @{$configuration->{IPSUBNET6}},
                        getSubnetAddressIPv6($address, $mask);
                }
            }
        }

        $configurations[$object->{Index}] = $configuration;
    }

    my @interfaces;

    foreach my $object (getWmiObjects(
        class      => 'Win32_NetworkAdapter',
        properties => [ qw/Index PNPDeviceID Speed PhysicalAdapter AdapterType/  ]
    )) {
        # http://comments.gmane.org/gmane.comp.monitoring.fusion-inventory.devel/34
        next unless $object->{PNPDeviceID};

        my $configuration = $configurations[$object->{Index}];

        next unless 
            $configuration->{IPADDRESS} ||
            $configuration->{IPADDRESS6} ||
            $configuration->{MACADDR};

        my $interface = {
            SPEED       => $object->{Speed},
            PNPDEVICEID => $object->{PNPDeviceID},
            MACADDR     => $configuration->{MACADDR},
            DESCRIPTION => $configuration->{DESCRIPTION},
            STATUS      => $configuration->{STATUS},
            IPDHCP      => $configuration->{IPDHCP},
            MTU         => $configuration->{MTU},
            IPGATEWAY   => $configuration->{IPGATEWAY},
            IPADDRESS   => $configuration->{IPADDRESS},
            IPMASK      => $configuration->{IPMASK},
            IPSUBNET    => $configuration->{IPSUBNET},
            IPADDRESS6  => $configuration->{IPADDRESS6},
            IPMASK6     => $configuration->{IPMASK6},
            IPSUBNET6   => $configuration->{IPSUBNET6},
            dns         => $configuration->{dns},
        };

        # PhysicalAdapter only work on OS > XP
        if (defined $object->{PhysicalAdapter}) {
            $interface->{VIRTUALDEV} = $object->{PhysicalAdapter} ? 0 : 1;
        # http://forge.fusioninventory.org/issues/1166 
        } elsif ($interface->{DESCRIPTION}
              && $interface->{DESCRIPTION} =~ /RAS/
              && $interface->{DESCRIPTION} =~ /Adapter/i) {
            $interface->{VIRTUALDEV} = 1;
        } else {
            $interface->{VIRTUALDEV} = $object->{PNPDeviceID} =~ /^ROOT/ ? 1 : 0;
        }

        if (defined $object->{AdapterType}) {
            $interface->{TYPE} = $object->{AdapterType};
            $interface->{TYPE} =~ s/Ethernet.*/Ethernet/;
        }

        push @interfaces, $interface;
    }

    return
        @interfaces;

}

1;
