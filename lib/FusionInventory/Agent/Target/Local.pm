package FusionInventory::Agent::Target::Local;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    $self->{path} = $params->{path};

    $self->{format} = $params->{html} ? 'HTML' :'XML';

    $self->_init({
        vardir => $params->{basevardir} . '/__LOCAL__',
    });

    return $self;
}

1;
