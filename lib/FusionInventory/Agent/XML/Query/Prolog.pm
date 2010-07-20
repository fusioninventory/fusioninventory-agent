package FusionInventory::Agent::XML::Query::Prolog;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Query';

use XML::Simple;
use Data::Dumper;
use Digest::MD5 qw(md5_base64);

#use FusionInventory::Agent::XML::Query::Prolog;

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    my $logger = $self->{logger};
    my $target = $self->{target};
    my $rpc = $params->{rpc};

    $self->{h}{QUERY} = ['PROLOG'];

    # $rpc can be undef if thread not enabled in Perl
    if ($rpc) {
        $self->{h}{TOKEN} = [$rpc->getToken()];
    }

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
