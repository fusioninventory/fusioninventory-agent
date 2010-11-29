package FusionInventory::Agent::XML::Query::SimpleMessage;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Query';

use XML::TreePP;

sub new {
    my ($class, %params) = @_;

    die "no msg parameter" unless $params{msg};

    my $self = $class->SUPER::new(%params);

    foreach (keys %{$params{msg}}) {
        $self->{h}->{$_} = $params{msg}->{$_};
    }

    return $self;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::XML::Query::SimpleMessage - Simple agent message

=head1 DESCRIPTION

This is a generic message sent by the agent to the server, allowing basic
key/values transmission.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, in addition to those
from the base class C<FusionInventory::Agent::XML::Query>, as keys of the
%params hash:

=over

=item I<msg>

the msg content, as an hashref (mandatory)

=back
