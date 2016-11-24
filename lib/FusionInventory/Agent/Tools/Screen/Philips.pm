package FusionInventory::Agent::Tools::Screen::Philips;

use strict;
use warnings;

use base 'FusionInventory::Agent::Tools::Screen';

sub altserial {
    my ($self) = @_;

    my $serial1 = sprintf("%06d", $self->{edid}->{serial_number});

    # Don't report altserial if current serial still includes it
    my $altserial =  $self->serial =~ m/$serial1$/ ? undef : $serial1 ;

    return $altserial;
}

1;
