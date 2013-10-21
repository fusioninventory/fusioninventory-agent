package FusionInventory::Agent::SNMP::Live;

use strict;
use warnings;
use base 'FusionInventory::Agent::SNMP';

use Encode qw(encode);
use English qw(-no_match_vars);
use Net::SNMP;

sub new {
    my ($class, %params) = @_;

    die "no hostname parameters" unless $params{hostname};

    my $timeout = $params{timeout} || 15;

    my $version =
        ! $params{version}       ? 'snmpv1'  :
        $params{version} eq '1'  ? 'snmpv1'  :
        $params{version} eq '2c' ? 'snmpv2c' :
        $params{version} eq '3'  ? 'snmpv3'  :
                                     undef   ;

    die "invalid SNMP version $params{version}" unless $version;

    my $self = {
        community => $params{community}
    };

    my $error;
    if ($version eq 'snmpv3') {
        ($self->{session}, $error) = Net::SNMP->session(
            -timeout      => $timeout,
            -retries      => 0,
            -version      => $version,
            -hostname     => $params{hostname},
            -username     => $params{username},
            -authpassword => $params{authpassword},
            -authprotocol => $params{authprotocol},
            -privpassword => $params{privpassword},
            -privprotocol => $params{privprotocol},
        );
    } else { # snmpv2c && snmpv1 #
        ($self->{session}, $error) = Net::SNMP->session(
            -timeout   => $timeout,
            -retries   => 0,
            -version   => $version,
            -hostname  => $params{hostname},
            -community => $params{community},
        );
    }

    die $error unless $self->{session};

    bless $self, $class;

    return $self;
}

sub switch_community {
    my ($self, $suffix) = @_;

    my $version_id = $self->{session}->version();
    my $version =
        $version_id == 0 ? 'snmpv1'  :
        $version_id == 1 ? 'snmpv2c' :
        $version_id == 2 ? 'snmpv3'  :
                             undef   ;
    my $error;
    ($self->{session}, $error) = Net::SNMP->session(
            -timeout   => $self->{session}->timeout(),
            -retries   => 0,
            -version   => $version,
            -hostname  => $self->{session}->hostname(),
            -community => $self->{community} . $suffix
    );
    die $error unless $self->{session};
}

sub get {
    my ($self, $oid) = @_;

    return unless $oid;

    my $session = $self->{session};

    my $response = $session->get_request(
        -varbindlist => [$oid]
    );

    return unless $response;

    return if $response->{$oid} =~ /noSuchInstance/;
    return if $response->{$oid} =~ /noSuchObject/;
    return if $response->{$oid} =~ /No response from remote host/;


    my $value = $response->{$oid};
    chomp $value;

    return $value;
}

sub walk {
    my ($self, $oid) = @_;

    return unless $oid;

    my $session = $self->{session};

    my $response = $session->get_table(
        -baseoid => $oid
    );

    return unless $response;

    my $values;
    my $offset = length($oid) + 1;

    foreach my $oid (keys %{$response}) {
        my $value = $response->{$oid};
        chomp $value;
        $values->{substr($oid, $offset)} = $value;
    }

    return $values;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::SNMP::Live - Live SNMP client

=head1 DESCRIPTION

This is the object used by the agent to perform SNMP queries on live host.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item version (mandatory)

Can be one of:

=over

=item '1'

=item '2c'

=item '3'

=back

=item timeout

The transport layer timeout (default: 15 seconds)

=item hostname (mandatory)

=item community

=item username

=item authpassword

=item authprotocol

=item privpassword

=item privprotocol

=back
