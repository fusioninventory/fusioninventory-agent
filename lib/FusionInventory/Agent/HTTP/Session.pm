package FusionInventory::Agent::HTTP::Session;

use strict;
use warnings;

use Digest::SHA;

use FusionInventory::Agent::Logger;

my $log_prefix = "[http session] ";

sub new {
    my ($class, %params) = @_;

    my $self = {
        logger  => $params{logger} ||
                        FusionInventory::Agent::Logger->new(),
        timer   => $params{timer} || time,
        timeout => $params{timeout} || 600,
        nonce   => $params{nonce} || '',
    };
    bless $self, $class;

    return $self;
}

sub expired {
    my ($self) = @_;

    return $self->{timer} + $self->{timeout} < time;
}

sub state {
    my ($self) = @_;

    unless ($self->{nonce}) {
        my $sha = Digest::SHA->new(1);

        my $nonce;
        eval {
            for (my $i = 0; $i < 32; $i ++) {
                $sha->add(ord(rand(256)));
            }
            $nonce = $sha->b64digest;
        };

        $self->{logger}->debug($log_prefix . "Nonce failure: $@") if $@;

        $self->{nonce} = $nonce
            if $nonce;
    }

    my $state = {};

    $state->{nonce} = $self->{nonce}
        if $self->{nonce};

    return $state;
}

sub authorized {
    my ($self, %params) = @_;

    return unless $params{token} && $params{payload};

    my $sha = Digest::SHA->new('256');

    my $digest;
    eval {
        $sha->add($self->{nonce}.'++'.$params{token});
        $digest = $sha->b64digest;
    };
    $self->{logger}->debug($log_prefix . "Digest failure: $@") if $@;

    return ($digest && $digest eq $params{payload});
}

sub dump {
    my ($self) = @_;

    my $dump = {};

    $dump->{nonce} = $self->{nonce} if $self->{nonce};
    $dump->{timer} = $self->{timer} if $self->{timer};

    return $dump;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::HTTP::Session - An abstract HTTP session

=head1 DESCRIPTION

This is an abstract class for HTTP sessions. It can be used to store
peer connection status.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<remoteip>

the peer ip address

=item I<secret>

our server-side secret

=item I<nonce>

a nonce used to compute the final secret

=item I<token>

the token provided by peer

=back

=head2 authorized()

Return true if provided secret matches the token.
