package FusionInventory::Agent::XML::Query::Prolog;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Query';

use Digest::MD5 qw(md5_base64);

#use FusionInventory::Agent::XML::Query::Prolog;
use Carp;

sub new {
    my ($class, $params) = @_;

    croak "No token" unless $params->{token};

    my $self = $class->SUPER::new($params);

    $self->{h}->{QUERY} = ['PROLOG'];
    $self->{h}->{TOKEN} = [$params->{token}];

    return $self;
}

1;
