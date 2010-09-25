package FusionInventory::Agent::XML::Query::Prolog;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Query';

use Digest::MD5 qw(md5_base64);
use XML::TreePP;

use FusionInventory::Agent::XML::Query;

sub new {
    my ($class, $params) = @_;

    die "No token" unless $params->{token};

    my $self = $class->SUPER::new($params);

    $self->{h}->{QUERY} = ['PROLOG'];
    $self->{h}->{TOKEN} = [$params->{token}];

    my $tpp = XML::TreePP->new();
    my $content= $tpp->write( { REQUEST => $self->{h} } );

    return $self;
}

1;
