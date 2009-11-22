package Ocsinventory::Agent::XML::Response::SimpleMessage;

use strict;
use Ocsinventory::Agent::XML::Response;
our @ISA = ('Ocsinventory::Agent::XML::Response');

sub new {
    my ($class, @params) = @_;

    my $self = $class->SUPER::new(@params);
    bless ($self, $class);

    return $self;
}

1;
