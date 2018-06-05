package FusionInventory::Agent::SNMP::MibSupport::Zebra;

use strict;
use warnings;

use parent 'FusionInventory::Agent::SNMP::MibSupportTemplate';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::SNMP;

# See ESI-MIB

use constant    esi     => '.1.3.6.1.4.1.683' ;
use constant    model2  => esi . '.6.2.3.2.1.15.1' ;
use constant    serial  => esi . '.1.5.0' ;
use constant    fw2     => esi . '.1.9.0' ;

use constant    zebra   => '.1.3.6.1.4.1.10642' ;
use constant    model1  => zebra . '.1.1.0' ;
use constant    fw1     => zebra . '.1.2.0' ;

our $mibSupport = [
    {
        name        => "zebra-printer",
        sysobjectid => getRegexpOidMatch(esi)
    }
];

sub getSerial {
    my ($self) = @_;

    return hex2char($self->get(serial));
}

sub getModel {
    my ($self) = @_;

    return hex2char($self->get(model1) || $self->get(model2));
}

sub getFirmware {
    my ($self) = @_;

    return hex2char($self->get(fw1) || $self->get(fw2));
}

1;

__END__

=head1 NAME

Inventory module for Zebra Printers

=head1 DESCRIPTION

The module enhances Zebra printers devices support.
