package FusionInventory::Agent::SNMP;

use strict;
use warnings;

use Encode qw(encode);
use English qw(-no_match_vars);
use Net::SNMP;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

my @bad_oids = qw(
    .1.3.6.1.2.1.2.2.1.6
    .1.3.6.1.2.1.4.22.1.2
    .1.3.6.1.2.1.17.1.1.0
    .1.3.6.1.2.1.17.4.3.1.1
    .1.3.6.1.4.1.9.9.23.1.2.1.1.4
);
my $bad_oids_pattern = '^(' . join('|', map { quotemeta($_) } @bad_oids) . ')';

sub new {
    my ($class, %params) = @_;

    die "no hostname parameters" unless $params{hostname};

    my $version =
        ! $params{version}       ? 'snmpv1'  :
        $params{version} eq '1'  ? 'snmpv1'  :
        $params{version} eq '2c' ? 'snmpv2c' :
        $params{version} eq '3'  ? 'snmpv3'  :
                                     undef   ;

    die "invalid SNMP version $params{version}" unless $version;

    my $self = {};

    my $error;
    if ($version eq 'snmpv3') {
        ($self->{session}, $error) = Net::SNMP->session(
            -timeout      => 1,
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
            -timeout   => 1,
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

    my $result = $response->{$oid};
    $result = _getFixedMac($result) if $oid =~ /$bad_oids_pattern/;
    $result = getSanitizedString($result);
    chomp $result;

    return $result;
}

sub walk {
    my ($self, $oid) = @_;

    return unless $oid;

    my $session = $self->{session};

    my $response = $session->get_table(
        -baseoid => $oid
    );

    return unless $response;

    my $result;

    foreach my $oid (keys %{$response}) {
        my $value = $response->{$oid};
        $value = _getFixedMac($value) if $oid =~ /$bad_oids_pattern/;
        $value = getSanitizedString($value);
        chomp $value;
        $result->{$oid} = $value;
    }

    return $result;
}

# normalize badly-encoded mac address
sub _getFixedMac {
    my ($value) = @_;

    if ($value !~ /^0x/) {
        # convert from binary to hexadecimal
        $value = unpack 'H*', $value;
    } else {
        # drop hex prefix
        $value = s/^0x//;
    }

    return alt2canonical($value);
}

1;
__END__

=head1 NAME

FusionInventory::Agent::SNMP - An SNMP query extension

=head1 DESCRIPTION

This is the object used by the agent to perform SNMP queries.

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

=item hostname (mandatory)

=item community

=item username

=item authpassword

=item authprotocol

=item privpassword

=item privprotocol

=back

=head2 get($oid)

This method returns a single value, corresponding to a single OID. The value is
normalised to remove any control character, and hexadecimal mac addresses are
translated into plain ascii.

=head2 walk($oid)

This method returns an hashref of values, indexed by their OIDs, starting from
the given one. The values are normalised to remove any control character, and
hexadecimal mac addresses are translated into plain ascii.
