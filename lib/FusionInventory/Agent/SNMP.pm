package FusionInventory::Agent::SNMP;

use strict;
use warnings;

use Encode qw(encode);
use English qw(-no_match_vars);
use Net::SNMP;

use FusionInventory::Agent::Tools;

sub new {
    my ($class, $params ) = @_;

    my $self = {};

    die "no hostname parameters" unless $params->{hostname};

    my $version =
        ! $params->{version}       ? 'snmpv1'  :
        $params->{version} eq '1'  ? 'snmpv1'  :
        $params->{version} eq '2c' ? 'snmpv2c' :
        $params->{version} eq '3'  ? 'snmpv3'  :
                                     undef     ;

    die "invalid SNMP version $params->{version}" unless $version;

    my $error;
    if ($version eq 'snmpv3') {
        ($self->{session}, $error) = Net::SNMP->session(
            -timeout   => 1,
            -retries   => 0,
            -version      => $version,
            -hostname     => $params->{hostname},
            -username     => $params->{username},
            -authpassword => $params->{authpassword},
            -authprotocol => $params->{authprotocol},
            -privpassword => $params->{privpassword},
            -privprotocol => $params->{privprotocol},
            -nonblocking => 0,
            -port      => 161
        );
    } else { # snmpv2c && snmpv1 #
        ($self->{session}, $error) = Net::SNMP->session(
            -timeout     => 1,
            -retries     => 0,
            -version     => $version,
            -hostname    => $params->{hostname},
            -community   => $params->{community},
            -nonblocking => 0,
            -port      => 161
        );
    }

    die $error unless $self->{session};

    bless $self, $class;

    # netdiscovery and snmpquery plugins access internal structure directly
    $self->{SNMPSession}->{session} = $self->{session};

    return $self;
}


sub snmpGet {
    my ($self, $params) = @_;

    my $oid = $params->{oid};

    return unless $oid;

    my $session = $self->{session};

    my $response = $session->get_request(
        -varbindlist => [$oid]
    );

    return unless $response;

    return if $response->{$oid} =~ /noSuchInstance/;
    return if $response->{$oid} =~ /noSuchObject/;

    my $result = _getNormalizedValue($oid, $response->{$oid});
    $result = getSanitizedString($result);
    chomp $result;

    return $result;
}

sub snmpWalk {
    my ($self, $args) = @_;

    my $oid_start = $args->{oid_start};

    return unless $oid_start;

    my $session = $self->{session};

    my $response = $session->get_table(
        -baseoid => $oid_start
    );

    return unless $response;

    my $result;

    foreach my $oid (keys %{$response}) {
        my $value = _getNormalizedValue($oid, $response->{$oid});
        $value = getSanitizedString($value);
        chomp $value;
        $result->{$oid} = $value;
    }

    return $result;
}

sub _getNormalizedValue {
    my ($oid, $value) = @_;

    # return value directly, unless for specific oids
    # corresponding to bad mac addresses
    return $value unless 
        $oid =~ /.1.3.6.1.2.1.2.2.1.6/    ||
        $oid =~ /.1.3.6.1.2.1.4.22.1.2/   ||
        $oid =~ /.1.3.6.1.2.1.17.1.1.0/   ||
        $oid =~ /.1.3.6.1.2.1.17.4.3.1.1/ ||
        $oid =~ /.1.3.6.1.4.1.9.9.23.1.2.1.1.4/;

    if ($value !~ /0x/) {
        $value = "0x" . unpack 'H*', $value;
    }

    my @array = split(/\S{2}/, $value);
    if (@array == 14) {
        $value = join(':', map { $array[$_] } qw/3 5 7 9 11 13/);
    }
    return $value;
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

=head2 snmpGet(%params)

This method returns a single value, corresponding to a single OID. The value is
normalised to remove any control character, and hexadecimal mac addresses are
translated into plain ascii.

Available params:

=over

=item oid the unique OID to query

=back

=head2 snmpWalk(%params)

This method returns an hashref of values, indexed by their OIDs, starting from
the given one. The values are normalised to remove any control character, and
hexadecimal mac addresses are translated into plain ascii.

Available params:

=over

=item oid_start the first OID to start walking

=back
