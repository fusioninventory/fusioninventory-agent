package FusionInventory::Agent::XML::Response;

use strict;
use warnings;

use XML::Simple;

sub new {
    my ($class, $params) = @_;

    my $content = XMLin(
        $params->{content},
        ForceArray => [ qw/OPTION PARAM/ ],
        KeepRoot   => 1
    );
    die "content is not an XML message" unless ref $content eq 'HASH';
    die "content is an invalid XML message" unless $content->{REPLY};

    my $self = {
        accountconfig => $params->{accountconfig},
        accountinfo   => $params->{accountinfo},
        config        => $params->{config},
        origmsg       => $params->{origmsg},
        content       => $content->{REPLY}
    };

    bless $self, $class;

    return $self;
}

sub getParsedContent {
    my ($self) = @_;

    return $self->{content};
}

sub getOptionsInfoByName {
    my ($self, $name) = @_;

    my $parsedContent = $self->getParsedContent();

    return unless $parsedContent && $parsedContent->{OPTION};

    foreach my $option (@{$parsedContent->{OPTION}}) {
        next unless $option->{NAME} eq $name;
        return $option->{PARAM}->[0];
    }

    return;
}

1;
