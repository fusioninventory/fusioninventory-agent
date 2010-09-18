package FusionInventory::Agent::Target::Local;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new(
        {
            %$params,
            dir => '__LOCAL__'
        }
    );

    return $self;
}


1;
