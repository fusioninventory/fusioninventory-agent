package FusionInventory::Agent::SNMP;

use strict;
use warnings;
use base 'Exporter';

use Encode qw(encode);
use English qw(-no_match_vars);
use Net::SNMP;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

our @EXPORT_OK = qw(
    getSanitizedSerialNumber
    getSanitizedMacAddress
    getElement
    getLastElement
    getNextToLastElement
);


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

    foreach my $oid (keys %{$response}) {
        my $value = $response->{$oid};
        chomp $value;
        $values->{$oid} = $value;
    }

    return $values;
}

sub getMacAddress {
    my ($self, $oid) = @_;

    my $value = $self->get($oid);
    return unless $value;

    if ($oid =~ /$bad_oids_pattern/) {
        $value = getSanitizedMacAddress($value);
    }

    $value = alt2canonical($value);

    return $value;
}

sub walkMacAddresses {
    my ($self, $oid) = @_;

    my $values = $self->walk($oid);
    return unless $values;

    if ($oid =~ /$bad_oids_pattern/) {
        foreach my $value (values %$values) {
            $value = getSanitizedMacAddress($value);
        }
    }

    foreach my $value (values %$values) {
        $value = alt2canonical($value);
    }

    return $values;
}

sub getSerialNumber {
    my ($self, $oid) = @_;

    my $value = $self->get($oid);
    return unless $value;

    return getSanitizedSerialNumber($value);
}

sub getSanitizedMacAddress {
    my ($value) = @_;

    if ($value !~ /^0x/) {
        # convert from binary to hexadecimal
        $value = unpack 'H*', $value;
    } else {
        # drop hex prefix
        $value =~ s/^0x//;
    }

    return $value;
}

sub getSanitizedSerialNumber {
    my ($value) = @_;

    $value =~ s/\n//g;
    $value =~ s/\r//g;
    $value =~ s/^\s+//;
    $value =~ s/\s+$//;
    $value =~ s/\.{2,}//g;

    return $value;
}

sub getElement {
    my ($oid, $index) = @_;

    my @array = split(/\./, $oid);
    return $array[$index];
}

sub getLastElement {
    my ($oid) = @_;

    return getElement($oid, -1);
}

sub getNextToLastElement {
    my ($oid) = @_;

    return getElement($oid, -2);
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

=head2 getSerialNumber($oid)

Wraps get($oid), assuming the value is a serial number and sanitizing it
accordingly.

=head2 getMacAddress($oid)

Wraps get($oid), assuming the value is a mac address and sanitizing it
accordingly.

=head2 walkMacAddresses($oid)

Wraps walk($oid), assuming the values are mac addresses and sanitizing them
accordingly.

=head1 FUNCTIONS

=head2 getSanitizedSerialNumber($value)

Return a sanitized serial number.

=head2 getSanitizedMacAddress($value)

Return a sanitized mac address.

=head2 getElement($oid, $index)

return the $index element of an oid.

=head2 getLastElement($oid)

return the last element of an oid.

=head2 getNextToLastElement($oid)

return the next to last element of an oid.
