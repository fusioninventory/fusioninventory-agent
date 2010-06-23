package FusionInventory::Agent::Task::Base;

use strict;
use warnings;

sub new {
    my ($class, $params) = @_;

    my $self = {
        config     => $params->{config},
        target     => $params->{target},
        logger     => $params->{logger},
        prologresp => $params->{prologresp}
    };

    bless $self, $class;

    return $self;
}

1;
