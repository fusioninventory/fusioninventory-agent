package Ocsinventory::Agent::XML::Response::SimpleMessage;

use strict;
use Ocsinventory::Agent::XML::Response;
our @ISA = ('Ocsinventory::Agent::XML::Response');

sub new {
    my ($class, @params) = @_;

    my $this = $class->SUPER::new(@params);
    bless ($this, $class);

    return $this;
}

1;
