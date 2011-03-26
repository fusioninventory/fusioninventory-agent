package FusionInventory::Agent::Target::Local;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

sub new {
    my ($class, $params) = @_;

    die "no path parameter" unless $params->{path};

    my $self = $class->SUPER::new($params);

    $self->{path} = $params->{path};

    $self->{format} = $params->{html} ? 'HTML' :'XML';

    $self->_init({
        vardir => $params->{basevardir} . '/__LOCAL__',
    });

    return $self;
}

sub getDescription {
    my ($self) = @_;

    return "local, $self->{path}";
}

1;
