package FusionInventory::Agent::XML::Query::Prolog;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Query';

use XML::Simple;

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    $self->{h}{QUERY} = ['PROLOG'];
    $self->{h}{TOKEN} = [$params->{token}];

    return $self;
}

1;
