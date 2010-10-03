package FusionInventory::Agent::XML::Response;

use strict;
use warnings;

use XML::TreePP;

use FusionInventory::Logger;

sub new {
    my ($class, $params) = @_;

    my $self = {
        content => $params->{content},
        logger  => $params->{logger} || FusionInventory::Logger->new(),
    };
    bless $self, $class;

    return $self;
}

sub getContent {
    my $self = shift;

    return $self->{content};

}

sub getParsedContent {
    my $self = shift;

    if(!$self->{parsedcontent} && $self->{content}) {
        my $tpp = XML::TreePP->new(
            force_array   => [ qw/OPTION PARAM/ ],
            attr_prefix   => '',
            text_node_key => 'content'
        );
        my $tmp = $tpp->parse( $self->{content} );
        return unless $tmp->{REPLY};
        $self->{parsedcontent} = $tmp->{REPLY};
    }

    return $self->{parsedcontent};
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
__END__

=head1 NAME

FusionInventory::Agent::XML::Response - XML response message

=head1 DESCRIPTION

This is the response message sent by the server to the agent.

=head1 METHODS

=head2 new($params)

The constructor. The following named parameters are allowed:

=over

=item content (mandatory)

=item logger: the logger object to use

=back

=head2 getContent

Get raw XML content.

=head2 getParsedContent

Get XML content, parsed as a perl data structure.

=head2 getOptionsInfoByName($name)

Get parameters of a specific option
