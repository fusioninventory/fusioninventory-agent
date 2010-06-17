package FusionInventory::Agent::XML::Response::SimpleMessage;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Response';

sub new {
    my ($class, @params) = @_;

    my $self = $class->SUPER::new(@params);
    bless $self, $class;

    return $self;
}

1;
