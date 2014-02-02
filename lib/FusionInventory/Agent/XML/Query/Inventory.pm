package FusionInventory::Agent::XML::Query::Inventory;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Query';

sub new {
    my ($class, %params) = @_;

    die "no content parameter" unless $params{content};

    return $class->SUPER::new(
        query => 'INVENTORY',
        %params
    );
}

sub getContent {
    my ($self) = @_;

    my $declaration = 
        '<?xml version="1.0" encoding="UTF-8" ?>' .
        "\n" .
        '<?xml-stylesheet type= "text/xsl" href= "share/inventory.xsl"?>';

    my $tpp = XML::TreePP->new(
        indent   => 2,
        xml_decl => $declaration
    );

    return $tpp->write({ REQUEST => $self->{h} });
}

1;
__END__

=head1 NAME

FusionInventory::Agent::XML::Query::Inventory - Inventory agent message

=head1 DESCRIPTION

This is an inventory message sent by the agent to the server, using OCS
Inventory XML format.

The data strcture format is documented in L<FusionInventory::Agent::Inventory>.


=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, in addition to those
from the base class C<FusionInventory::Agent::XML::Query>, as keys of the
%params hash:

=over

=item I<content>

the inventory content (mandatory)

=back
