package FusionInventory::Agent::Controller;

use strict;
use warnings;

use English qw(-no_match_vars);
use URI;

sub new {
    my ($class, %params) = @_;

    die 'no url parameter' unless $params{url};

    my $url = URI->new($params{url});

    my $scheme = $url->scheme();
    if (!$scheme) {
        # this is likely a bare hostname
        $url = URI->new('http://' . $params{url});
    } else {
        die "invalid protocol for URL parameter: $params{url}"
            if $scheme ne 'http' && $scheme ne 'https';
    }

    my $self = {
        maxDelay        => $params{maxDelay} || 3600,
        nextContactDate => time(),
        url             => $url->as_string(),
        id              => $url->host()
    };
    bless $self, $class;

    return $self;
}

sub getId {
    my ($self) = @_;

    return $self->{id};
}

sub getUrl {
    my ($self) = @_;

    return $self->{url};
}

sub setNextContactDate {
    my ($self, $nextContactDate) = @_;

    $self->{nextContactDate} = $nextContactDate;
}

sub resetNextContactDate {
    my ($self) = @_;

    $self->{nextContactDate} =
        time + $self->{maxDelay} / 2  + int rand($self->{maxDelay} / 2);
}

sub getNextContactDate {
    my ($self) = @_;

    return $self->{nextContactDate};
}

sub getFormatedNextContactDate {
    my ($self) = @_;

    return $self->{nextContactDate} > 1 ?
        scalar localtime($self->{nextContactDate}) : "now";
}

sub getMaxDelay {
    my ($self) = @_;

    return $self->{maxDelay};
}

sub setMaxDelay {
    my ($self, $maxDelay) = @_;

    $self->{maxDelay} = $maxDelay;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Controller - Control server

=head1 DESCRIPTION

This is the control server for the agent.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<maxDelay>

the maximum delay before contacting the target, in seconds
(default: 3600)

=item I<url>

the server URL (mandatory)

=back

=head2 getUrl()

Return the server URL for this target.

=head2 getNextContactDate()

Get nextContactDate attribute.

=head2 getFormatedNextContactDate()

Get nextContactDate attribute as a formated string.

=head2 setNextContactDate($nextContactDate)

Set next contact date.

=head2 resetNextContactDate()

Set next contact date to a random value.

=head2 getMaxDelay($maxDelay)

Get maxDelay attribute.

=head2 setMaxDelay($maxDelay)

Set maxDelay attribute.
