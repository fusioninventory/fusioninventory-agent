package FusionInventory::Agent::Tools::Screen::Samsung;

use strict;
use warnings;

use base 'FusionInventory::Agent::Tools::Screen';

# Well-known eisa_id for which wee need to revert serial and altserial
my $eisa_id_match = qr/09c6$/ ;

sub serial {
    my ($self) = @_;

    # Revert serial and altserial when eisa_id matches
    return $self->_altserial if ($self->eisa_id =~ $eisa_id_match);

    return $self->{_serial};
}

sub altserial {
    my ($self) = @_;

    return $self->{_altserial} if $self->{_altserial};

    # Revert serial and altserial when eisa_id matches
    return $self->{_altserial} = $self->eisa_id =~ $eisa_id_match ?
        $self->{_serial} : $self->_altserial;
}

sub _altserial {
    my ($self) = @_;

    my $serial1 = $self->{edid}->{serial_number};
    my $serial2 = $self->{edid}->{serial_number2}->[0];

    return
        chr(($serial1 >> 24)% 256) .
        chr(($serial1 >> 16)% 256) .
        chr(($serial1 >> 8 )% 256) .
        chr( $serial1       % 256) .
        $serial2 ;
}

1;
