package FusionInventory::Agent::Target::Local;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    $self->{format} = $self->{config}->{html} ? 'HTML' :'XML';

    $self->_init({
        vardir => $self->{config}->{basevardir} . '/__LOCAL__',
    });

    return $self;
}

1;
