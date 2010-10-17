package FusionInventory::Agent::SNMP;

use strict;
use warnings;

use Encode qw(encode);
use English qw(-no_match_vars);
use Net::SNMP;

sub new {
    my ($class, $params) = @_;

    my $version =
        ! $params->{version}       ? 'snmpv1'  :
        $params->{version} eq '1'  ? 'snmpv1'  :
        $params->{version} eq '2c' ? 'snmpv2c' :
        $params->{version} eq '3'  ? 'snmpv3'  :
                                     undef     ;

    die "invalid SNMP version $params->{version}" unless $version;

    my ($self, $error);
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
            -nonblocking  => 0,
            -port         => 161
        );
    } else { # snmpv2c && snmpv1 #
        ($self->{session}, $error) = Net::SNMP->session(
            -timeout     => 1,
            -retries     => 0,
            -version     => $version,
            -hostname    => $params->{hostname},
            -community   => $params->{community},
            -nonblocking => 0,
            -port        => 161
        );
    }

    die $error unless $self->{session};

    bless $self, $class;

    return $self;
}


sub snmpGet {
    my ($self, $params) = @_;

    my $oid = $params->{oid};
    my $up = $params->{up};

    return unless $oid;

    my $session = $self->{session};

    my $result = $session->get_request(
        -varbindlist => [$oid]
    );

    return unless $result;

    return if $result->{$oid} =~ /noSuchInstance/;
    return if $result->{$oid} =~ /noSuchObject/;

    my $value;
    if (
        $oid =~ /.1.3.6.1.2.1.2.2.1.6/    ||
        $oid =~ /.1.3.6.1.2.1.4.22.1.2/   ||
        $oid =~ /.1.3.6.1.2.1.17.1.1.0/   ||
        $oid =~ /.1.3.6.1.2.1.17.4.3.1.1/ ||
        $oid =~ /.1.3.6.1.4.1.9.9.23.1.2.1.1.4/
    ) {
        $value = getBadMACAddress($oid, $result->{$oid});
    }

    $value = specialChar($value);
    $value =~ s/\n$//;

    return $value;
}


sub snmpWalk {
    my ($self, $params) = @_;

    my $oid_start = $params->{oid_start};

    my $ArraySNMP = {};

    my $oid_prec = $oid_start;
    if (defined($oid_start)) {
        while($oid_prec =~ m/$oid_start/) {
            my $response = $self->{session}->get_next_request($oid_prec);
            my $err = $self->{session}->error;
            if ($err){
                #debug($log,"[".$_[1]."] Error : ".$err,"",$PID);
                #debug($log,"[".$_[1]."] Oid Error : ".$oid_prec,"",$PID);
                return $ArraySNMP;
            }
            my %pdesc = %{$response};
            #print %pdesc;
            while ((my $object,my $oid) = each (%pdesc)) {
                if ($object =~ /$oid_start/) {
                    if ($oid !~ /No response from remote host/) {
                        if ($object =~ /.1.3.6.1.2.1.17.4.3.1.1/) {
                            $oid = getBadMACAddress($object,$oid)
                        }
                        if ($object =~ /.1.3.6.1.2.1.17.1.1.0/) {
                            $oid = getBadMACAddress($object,$oid)
                        }
                        if ($object =~ /.1.3.6.1.2.1.2.2.1.6/) {
                            $oid = getBadMACAddress($object,$oid)
                        }
                        if ($object =~ /.1.3.6.1.2.1.4.22.1.2/) {
                            $oid = getBadMACAddress($object,$oid)
                        }
                        if ($object =~ /.1.3.6.1.4.1.9.9.23.1.2.1.1.4/) {
                            $oid = getBadMACAddress($object,$oid)
                        }
                        my $object2 = $object;
                        $object2 =~ s/$_[0].//;
                        $oid = specialChar($oid);
                        $oid =~ s/\n$//;
                        $ArraySNMP->{$object2} = $oid;
                    }
                }
                $oid_prec = $object;
            }
        }
    }
    return $ArraySNMP;
}

sub specialChar {
    if (defined($_[0])) {
        if ($_[0] =~ /0x$/) {
            return "";
        }
        $_[0] = encode('UTF-8', $_[0]);
        $_[0] =~ s/\0//g;
        $_[0] =~ s/([\x80-\xFF])//g;
        return $_[0];
    } else {
        return "";
    }
}


sub getBadMACAddress {
    my $OID_ifTable = shift;
    my $oid_value = shift;

    if ($oid_value !~ /0x/) {
        $oid_value = "0x".unpack 'H*', $oid_value;
    }

    my @array = split(/(\S{2})/, $oid_value);
    if (@array eq "14") {
        $oid_value = $array[3].":".$array[5].":".$array[7].":".$array[9].":".$array[11].":".$array[13];
    }
    return $oid_value;
}

sub getAuthList {
    my ($class, $options) = @_;

    my $list;

    if (ref($options->{AUTHENTICATION}) eq "HASH") {
        # a single auth object
        $list->{$options->{AUTHENTICATION}->{ID}} = $options->{AUTHENTICATION};
    } else {
        # a list of auth objects
        foreach my $auth (@{$options->{AUTHENTICATION}}) {
            $list->{$auth->{ID}} = $auth;
        }
    }

    return $list;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::SNMP - An SNMP query extension

=head1 DESCRIPTION

This is the object used by the agent to perform SNMP queries.

=head1 METHODS

=head2 new($params)

The constructor. The following named parameters are allowed:

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

=head2 snmpGet()

=head2 snmpWalk()

=head2 specialChar()

=head2 getBadMACAddress()
