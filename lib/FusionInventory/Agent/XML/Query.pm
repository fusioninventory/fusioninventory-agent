package FusionInventory::Agent::XML::Query;

use strict;
use warnings;

use XML::Simple;

sub new {
    my ($class, $params) = @_;

    die "No DEVICEID" unless $params->{target}->{deviceid};

    my $self = {
        logger      => $params->{logger},
        target      => $params->{target}
    };
    bless $self, $class;

    my $target = $self->{target};

    $self->{h} = {
        QUERY    => ['UNSET!'],
        DEVICEID => [$target->{deviceid}]
    };

    if (
        $target->{currentDeviceid} &&
        $target->{deviceid} ne $target->{currentDeviceid}
    ) {
      $self->{h}->{OLD_DEVICEID} = [$target->{currentDeviceid}];
    }

    return $self;
}

sub getContent {
    my ($self, $args) = @_;

    my $content = XMLout(
        $self->{h},
        RootName      => 'REQUEST',
        XMLDecl       => '<?xml version="1.0" encoding="UTF-8"?>',
        SuppressEmpty => undef,
        NoAttr        => 1,
        KeyAttr       => []
    );

    return $content;
}

sub setAccountInfo {
    my ($self, $info) = @_;

    return unless defined $info;
    die "invalid argument $info" unless ref $info eq 'HASH';

    while (my ($key, $value) = each %$info) {
        push @{$self->{h}->{CONTENT}->{ACCOUNTINFO}}, {
            KEYNAME  => $key,
            KEYVALUE => $value
        }
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::XML::Query - Base class for query message

=head1 DESCRIPTION

This is an abstract class for all XML query messages sent by the agent to the
server.

=head1 METHODS

=head2 new($params)

The constructor. The following named parameters are allowed:

=over

=item logger (mandatory)

=item target (mandatory)

=back

=head2 getContent

Get XML content.

=head2 setAccountInfo($info)

Set account informations for this message.
