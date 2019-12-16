package FusionInventory::Agent::SNMP::MibSupport::Ricoh;

use strict;
use warnings;

use parent 'FusionInventory::Agent::SNMP::MibSupportTemplate';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::SNMP;

use constant    mib2        => '.1.3.6.1.2.1' ;
use constant    enterprises => '.1.3.6.1.4.1' ;

use constant    ricoh       => enterprises . '.367.1.1' ;

# Printer-MIB
use constant    printmib                => mib2 . '.43' ;
use constant    prtGeneralPrinterName   => printmib . '.5.1.1.16.1' ;

our $mibSupport = [
    {
        name        => "ricoh-printer",
        sysobjectid => getRegexpOidMatch(ricoh)
    }
];

sub getModel {
    my ($self) = @_;

    return $self->get(prtGeneralPrinterName);
}

1;

__END__

=head1 NAME

FusionInventory::Agent::SNMP::MibSupport::Ricoh - Inventory module for Ricoh Printers

=head1 DESCRIPTION

The module enhances Ricoh printers devices support.
