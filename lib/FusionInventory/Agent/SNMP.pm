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
    } else {
        $value = $result->{$oid};
    }

    $value = getSanitizedString($value);
    $value =~ s/\n$//;

    return $value;
}

sub snmpWalk {
    my ($self, $args) = @_;

    my $oid_start = $args->{oid_start};

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
                        $oid = getSanitizedString($oid);
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

1;
