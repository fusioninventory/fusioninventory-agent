package FusionInventory::Agent::XML::Query::Prolog;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Query';

use XML::Simple;
use Data::Dumper;

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    $self->{h}->{QUERY} = ['PROLOG'];
    $self->{h}->{TOKEN} = [$params->{token}];

    return $self;
}

sub dump {
    my $self = shift;
    print Dumper($self->{h});
}

sub getContent {
    my ($self, $args) = @_;

    $self->{accountinfo}->setAccountInfo($self);
    my $content = XMLout(
        $self->{h},
        RootName => 'REQUEST',
        XMLDecl => '<?xml version="1.0" encoding="UTF-8"?>',
        SuppressEmpty => undef
    );

    return $content;
}

1;
