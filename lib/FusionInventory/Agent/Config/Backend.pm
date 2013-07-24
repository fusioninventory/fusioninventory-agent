package FusionInventory::Agent::Config::Backend;

use strict;
use warnings;

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;

    return $self;
}

1;
