package FusionInventory::Agent::Target::Stdout;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    $self->_init({
        vardir => $params->{basevardir} . '/__LOCAL__',
    });

    return $self;
}

sub getDescription {
    my ($self) = @_;

    return "stdout";
}

1;
