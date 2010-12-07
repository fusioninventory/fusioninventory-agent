package FusionInventory::Agent::Target::Server;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

use English qw(-no_match_vars);
use URI;

use FusionInventory::Agent::Transmitter;
use FusionInventory::Agent::XML::Query::Prolog;

sub new {
    my ($class, %params) = @_;

    die "no url parameter" unless $params{url};

    my $self = $class->SUPER::new(%params);

    $self->{tag} = $params{tag};
    $self->{url} = URI->new($params{url});

    my $scheme = $self->{url}->scheme();
    if (!$scheme) {
        # this is likely a bare hostname
        # as parsing relies on scheme, host and path have to be set explicitely
        $self->{url}->scheme('http');
        $self->{url}->host($params{url});
        $self->{url}->path('ocsinventory');
    } else {
        die "invalid protocol for URL: $params{url}"
            if $scheme ne 'http' && $scheme ne 'https';
        # complete path if needed
        $self->{url}->path('ocsinventory') if !$self->{url}->path();
    }

    # target transmitter
    $self->{transmitter} = FusionInventory::Agent::Transmitter->new(
        logger => $self->{logger},
        %{$params{network}},
    );

    # target-specific storage object
    my $subdir = $params{url};
    $subdir =~ s/\//_/g;
    $subdir =~ s/:/../g if $OSNAME eq 'MSWin32';
    $self->_initStorage($params{basevardir} . '/' . $subdir);

    # restore previous state
    $self->_loadState();

    return $self;
}

sub init {
    my ($self, %params) = @_;

    my $prolog = FusionInventory::Agent::XML::Query::Prolog->new(
        logger   => $self->{logger},
        deviceid => $params{deviceid},
        token    => $params{token}
    );

    if ($self->{tag}) {
        $prolog->setAccountInfo(TAG => $self->{tag});
    }

    $self->{prologresp} = $self->{transmitter}->send(message => $prolog);

    if (!$self->{prologresp}) {
        $self->{logger}->error("No anwser from the server");
    }
}

sub getUrl {
    my ($self) = @_;

    return $self->{url};
}

sub getAccountInfo {
    my ($self) = @_;

    return $self->{accountInfo};
}

sub setAccountInfo {
    my ($self, $accountInfo) = @_;

    $self->{accountInfo} = $accountInfo;
}

sub getTransmitter {
    my ($self) = @_;

    return $self->{transmitter};
}

sub getPrologresp {
    my ($self) = @_;

    return $self->{prologresp};
}

sub _loadState {
    my ($self) = @_;

    my $data = $self->{storage}->restore();
    $self->{nextRunDate} = $data->{nextRunDate} if $data->{nextRunDate};
    $self->{period}      = $data->{period} if $data->{period};
    $self->{accountInfo} = $data->{accountInfo} if $data->{accountInfo};
}

sub saveState {
    my ($self) = @_;

    $self->{storage}->save(
        data => {
            nextRunDate => $self->{nextRunDate},
            period      => $self->{period},
            accountInfo => $self->{accountInfo}
        }
    );

}

sub getDescription {
    my ($self) = @_;

    my $description = $self->SUPER::getDescription();

    my $url = $self->{url};

    # Remove the login:password if needed
    $url =~ s/(http|https)(:\/\/)(.*@)(.*)/$1$2$4/;

    $description->{type}        = 'server';
    $description->{destination} = $url;

    return $description;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Target::Server - Server target

=head1 DESCRIPTION

This is a target for sending execution result to a server.

A server target has the additional following attributes:

=over

=item I<url>

The server URL.

=item I<transmitter>

The C<FusionInventory::Agent::Transmitter> object used to communicate with the
server.

=back

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, in addition to those
from the base class C<FusionInventory::Agent::Target>, as keys of the %params
hash:

=over

=item I<url>

the server URL (mandatory)

=item I<network>

the parameters for the C<FusionInventory::Agent::Transmitter> object

=back

=head2 getAccountInfo()

Get account informations for this target.

=head2 setAccountInfo($info)

Set account informations for this target.

=head2 getUrl()

Return the server URL for this target.
