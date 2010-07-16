package FusionInventory::Agent::Task;

use strict;
use warnings;

sub new {
    my ($class, $params) = @_;

    my $self = {
        config     => $params->{config},
        target     => $params->{target},
        logger     => $params->{logger},
        storage    => $params->{storage},
        prologresp => $params->{prologresp}
    };

    bless $self, $class;

    return $self;
}

1;
