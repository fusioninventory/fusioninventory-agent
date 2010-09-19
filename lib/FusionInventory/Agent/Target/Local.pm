package FusionInventory::Agent::Target::Local;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

my $count = 0;

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new(
        {
            %$params,
            dir => '__LOCAL__',
            id  => 'local' . $count++
        }
    );

    return $self;
}


1;
