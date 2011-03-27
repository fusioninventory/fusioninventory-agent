package FusionInventory::Agent::XML::Query::Prolog;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Query';

use Digest::MD5 qw(md5_base64);
use XML::Simple;

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    my $logger = $self->{logger};
    my $target = $self->{target};

    $self->{h}{QUERY} = ['PROLOG'];
    $self->{h}{TOKEN} = [$params->{token}];

    return $self;
}

1;
