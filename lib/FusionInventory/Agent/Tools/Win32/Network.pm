package FusionInventory::Agent::Tools::Win32::Network;

use warnings;
use strict;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools::Network;

sub new {
    my ($class, %params) = @_;

    return unless defined $params{WMI} && defined $params{configurations};

    my $self = {
        WMI             => $params{WMI}
    };
    bless $self, $class;

    $self->{config} = defined $params{configurations}[$self->_getObjectIndex()] ? $params{configurations}[$self->_getObjectIndex()] : undef;

    return unless $self->_getPNPDeviceID() && $self->{config} && $self->{config}->{MACADDR};

    return $self;
}

sub getBaseInterface {
    my ($self) = @_;

    my $interface = {
        PNPDEVICEID => $self->_getPNPDeviceID(),
        PCIID       => $self->_getPciid(),
        MACADDR     => $self->{config}->{MACADDR},
        DESCRIPTION => $self->_getDescription(),
        STATUS      => $self->{config}->{STATUS},
        MTU         => $self->{config}->{MTU},
        dns         => $self->{config}->{dns},
        GUID        => $self->_getGUID(),
        VIRTUALDEV  => $self->_isVirtual()
    };
    
    $interface->{DNSDomain}     = $self->{config}->{DNSDomain} if $self->{config}->{DNSDomain};
    $interface->{SPEED}         = int($self->{WMI}->{Speed} / 1_000_000) if $self->{WMI}->{Speed};

    return $interface;
}

sub getInterfacesWithAddresses {
    my ($self) = @_;

    my @interfaces;

    foreach my $address (@{$self->{config}->{addresses}}) {
        my $interface = $self->getBaseInterface();
        if ($address->[0] =~ /$ip_address_pattern/) {
            $interface->{IPADDRESS} = $address->[0];
            $interface->{IPMASK}    = $address->[1];
            $interface->{IPSUBNET}  = getSubnetAddress(
                $interface->{IPADDRESS},
                $interface->{IPMASK}
            );
            $interface->{IPDHCP}        = $self->{config}->{IPDHCP};
            $interface->{IPGATEWAY}     = $self->{config}->{IPGATEWAY};
        } else {
            $interface->{IPADDRESS6}    = $address->[0];
            $interface->{IPMASK6}       = getNetworkMaskIPv6($address->[1]);
            $interface->{IPSUBNET6}     = getSubnetAddressIPv6(
                $interface->{IPADDRESS6},
                $interface->{IPMASK6}
            );
        }
        push @interfaces, $interface;
    }

    return @interfaces;
}

sub hasAddresses {
    my ($self) = @_;

    return $self->{config}->{addresses} ? 1 : 0;
}

sub _isVirtual {
    my ($self) = @_;

    # Some virtual network adapters like VirtualBox or VPN ones could be set
    # as physical but with PNPDeviceID starting by ROOT
    return 1 if $self->_getPNPDeviceID() =~ /^ROOT/;

    # PhysicalAdapter only work on OS > XP
    return $self->_getPhysicalAdapter() ? 0 : 1 if defined $self->_getPhysicalAdapter();

    # http://forge.fusioninventory.org/issues/1166
    my $description = $self->_getDescription();
    return 1 if $description && $description =~ /RAS/ && $description =~ /Adapter/i;

    return 0;
}

sub _getPciid {
    my ($self) = @_;

    return ($self->_getPNPDeviceID() =~ /PCI\\VEN_(\w{4})&DEV_(\w{4})&SUBSYS_(\w{4})(\w{4})/) ? join(':', $1 , $2 , $3 , $4) : undef;
}

sub _getObjectIndex {
    my ($self) = @_;
    
    return defined($self->{WMI}->{InterfaceIndex}) ? $self->{WMI}->{InterfaceIndex} : $self->{WMI}->{Index};
}

# Getters try get Information on MSFT_NetAdapter || Win32_NetworkAdapter || undef

sub _getGUID {
    my ($self) = @_;

    return $self->{WMI}->{InterfaceGuid} || $self->{WMI}->{GUID} || undef;
}

sub _getPhysicalAdapter {
    my ($self) = @_;

    return $self->{WMI}->{HardwareInterface} || $self->{WMI}->{PhysicalAdapter} || undef;
}

sub _getPNPDeviceID {
    my ($self) = @_;

    return $self->{WMI}->{PnPDeviceID} || $self->{WMI}->{PNPDeviceID} || undef;
}

sub _getDescription {
    my ($self) = @_;

    return $self->{WMI}->{InterfaceDescription} || $self->{config}->{DESCRIPTION} || undef;
}

1;
