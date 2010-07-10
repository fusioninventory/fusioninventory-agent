package FusionInventory::Agent::XML::Query::Prolog;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Query';

use Carp;
use XML::Simple;

sub new {
    my ($class, $params) = @_;

    croak "No token" unless $params->{token};

    my $self = $class->SUPER::new($params);

    $self->{h}->{QUERY} = ['PROLOG'];
    $self->{h}->{TOKEN} = [$params->{token}];

    return $self;
}

1;
