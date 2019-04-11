package FusionInventory::Agent::SNMP::MibSupport::Oki;

use strict;
use warnings;

use parent 'FusionInventory::Agent::SNMP::MibSupportTemplate';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::SNMP;

use constant oki    => '.1.3.6.1.4.1.2001';
use constant serial => oki . '.1.1.1.1.11.1.10.45.0';

our $mibSupport = [
    {
        name        => "oki",
        sysobjectid => getRegexpOidMatch(oki)
    }
];

sub getSerial {
    my ($self) = @_;

    return $self->get(serial);
}

1;

__END__

=head1 NAME

FusionInventory::Agent::SNMP::MibSupport::Oki - Inventory module for Oki printers

=head1 DESCRIPTION

This module enhances Oki printers support.
