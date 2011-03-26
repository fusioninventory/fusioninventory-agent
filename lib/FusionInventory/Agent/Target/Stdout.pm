package FusionInventory::Agent::Target::Stdout;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    $self->_init({
        vardir => $self->{config}->{basevardir} . '/__LOCAL__',
    });

    return $self;
}

1;
