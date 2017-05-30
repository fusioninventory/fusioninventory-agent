package FusionInventory::Agent::Tools::Hardware::Juniper;

use strict;
use warnings;

sub run {
   my (%params) = @_;

   my $snmp   = $params{snmp};
   my $device = $params{device};

   my $firmware = $snmp->get('.1.3.6.1.4.1.2636.3.40.1.4.1.1.1.5.0');

   $device->{INFO}->{FIRMWARE} = $firmware if $firmware;
}

1;
__END__

=head1 NAME

Inventory module for Juniper

=head1 DESCRIPTION

The module returns the correct firmware.
