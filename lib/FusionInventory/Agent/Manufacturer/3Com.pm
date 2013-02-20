package FusionInventory::Agent::Manufacturer::3Com;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Network;

# In Intellijack 225, put mac address of port 'IntelliJack Ethernet Adapter' in port 'LAN Port'
sub RewritePortOf225 {
    my (%params) = @_;

    my $ports = $params{ports};

    $ports->{101}->{MAC} = $ports->{1}->{MAC};
    delete $ports->{1};
    delete $ports->{101}->{CONNECTIONS};
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Manufacturer::3Com - 3Com-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to 3Com hardware.

=head1 FUNCTIONS

=head2 RewritePortOf225(%params)

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back
