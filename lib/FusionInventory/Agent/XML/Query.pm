package FusionInventory::Agent::XML::Query;

use strict;
use warnings;

use XML::TreePP;

sub new {
    my ($class, %params) = @_;

    die "no query parameter" unless $params{query};

    my $self = {
        stylesheet => $params{stylesheet},
    };
    bless $self, $class;

    foreach my $key (qw/query deviceid content token/) {
        next unless $params{$key};
        $self->{h}->{uc($key)} = $params{$key};
    }

    return $self;
}

sub getContent {
    my ($self) = @_;

    my $declaration = '<?xml version="1.0" encoding="UTF-8" ?>';
    if ($self->{stylesheet}) {
        $declaration .= 
            "\n" .
            '<?xml-stylesheet type= "text/xsl" href= "' .
            $self->{stylesheet} .
            '"?>';
    }

    my $tpp = XML::TreePP->new(
        indent   => 2,
        xml_decl => $declaration
    );

    return $tpp->write({ REQUEST => $self->{h} });
}


1;

__END__

=head1 NAME

FusionInventory::Agent::XML::Query - Base class for agent messages

=head1 DESCRIPTION

This is an abstract class for all XML query messages sent by the agent to the
server.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use

=item I<deviceid>

the agent identifier (optional)

=back

=head2 getContent

Get XML content.
