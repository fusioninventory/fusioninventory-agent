package FusionInventory::Agent::Tools::Hardware::Apc;

use strict;
use warnings;

sub run {
   my (%params) = @_;

   my $snmp   = $params{snmp};
   my $device = $params{device};

   my $sPDUIdentModelNumber = $snmp->get(".1.3.6.1.4.1.318.1.1.4.1.4.0");

   $device->{INFO}->{MODEL} = $sPDUIdentModelNumber if $sPDUIdentModelNumber;
}

1;
__END__

=head1 NAME

Inventory module for APC PDUs

=head1 DESCRIPTION

The module returns the correct PDU model.
