package FusionInventory::Agent::SNMP::Mock;

use strict;
use warnings;
use parent 'FusionInventory::Agent::SNMP';

use FusionInventory::Agent::Tools;

my %prefixes = (
    'iso'                               => '.1',
    'SNMPv2-MIB::sysDescr'              => '.1.3.6.1.2.1.1.1',
    'SNMPv2-MIB::sysObjectID'           => '.1.3.6.1.2.1.1.2',
    'SNMPv2-MIB::sysUpTime'             => '.1.3.6.1.2.1.1.3',
    'SNMPv2-MIB::sysContact'            => '.1.3.6.1.2.1.1.4',
    'SNMPv2-MIB::sysName'               => '.1.3.6.1.2.1.1.5',
    'SNMPv2-MIB::sysLocation'           => '.1.3.6.1.2.1.1.6',
    'SNMPv2-MIB::sysORID'               => '.1.3.6.1.2.1.1.9.1.2',
    'SNMPv2-SMI::mib-2'                 => '.1.3.6.1.2.1',
    'SNMPv2-SMI::enterprises'           => '.1.3.6.1.4.1',
    'IF-MIB::ifIndex'                   => '.1.3.6.1.2.1.2.2.1.1',
    'IF-MIB::ifDescr'                   => '.1.3.6.1.2.1.2.2.1.2',
    'IF-MIB::ifType'                    => '.1.3.6.1.2.1.2.2.1.3',
    'IF-MIB::ifMtu'                     => '.1.3.6.1.2.1.2.2.1.4',
    'IF-MIB::ifSpeed'                   => '.1.3.6.1.2.1.2.2.1.5',
    'IF-MIB::ifPhysAddress'             => '.1.3.6.1.2.1.2.2.1.6',
    'IF-MIB::ifLastChange'              => '.1.3.6.1.2.1.2.2.1.9',
    'IF-MIB::ifInOctets'                => '.1.3.6.1.2.1.2.2.1.10',
    'IF-MIB::ifInErrors'                => '.1.3.6.1.2.1.2.2.1.14',
    'IF-MIB::ifOutOctets'               => '.1.3.6.1.2.1.2.2.1.16',
    'IF-MIB::ifOutErrors'               => '.1.3.6.1.2.1.2.2.1.20',
    'IF-MIB::ifName'                    => '.1.3.6.1.2.1.31.1.1.1.1',
    'HOST-RESOURCES-MIB::hrDeviceDescr' => '.1.3.6.1.2.1.25.3.2.1.3',
    'NET-SNMP-MIB::netSnmpAgentOIDs'    => '.1.3.6.1.4.1.8072.3.2',
);

sub new {
    my ($class, %params) = @_;

    my $self = {
        _ip => $params{ip}
    };
    bless $self, $class;

    SWITCH: {
        if ($params{file}) {
            die "non-existing file '$params{file}'\n"
                unless -f $params{file};
            die "unreadable file '$params{file}'\n"
                unless -r $params{file};
            $self->{file}   = $params{file};
            $self->_setIndexedValues();
            last SWITCH;
        }

        if ($params{hash}) {
            $self->{values} = $params{hash};
            last SWITCH;
        }
    }

    return $self;
}

sub switch_vlan_context {
    my ($self, $vlan_id) = @_;

    $self->{oldvalues} = $self->{values} unless $self->{oldvalues};

    my $file = $self->{file} . '@' . $vlan_id;
    if (-r $file && -f $file) {
        $self->_setIndexedValues($file);
    } else {
        delete $self->{values};
    }
}

sub reset_original_context {
    my ($self) = @_;

    $self->{values} = $self->{oldvalues};
    delete $self->{oldvalues};
}

sub _setIndexedValues {
    my ($self, $file) = @_;

    my $handle = getFileHandle(file => $file || $self->{file});

    # check first line
    my $first_line = <$handle>;
    seek($handle, 0, 0);

    # check first line for safety
    die "invalid file format\n" unless $first_line =~ /^(\S+) = .*/;

    my $numerical = substr($first_line, 0, 1) eq '.' ? 1 : 0 ;
    my $last_value;
    $self->{_walk} = [ [], undef, undef, {} ];

    while (my $line = <$handle>) {

        if ($numerical) {
            if ($line =~ /^
               (\S+) \s
               = \s
               (?:Wrong \s Type \s \(should \s be \s [^:]+\): \s)?
               ([^:]+): \s
               (.*)
               /x
            ) {
                my ($oid, $type, $value) = ($1, $2, $3);
                $last_value = [ $type, $value ];
                $self->_setOid($oid, $last_value);
                next;
            }
        } else {
            if ($line =~ /^
               ([^.]+) \. ([\d.]+) \s
               = \s
               (?:Wrong \s Type \s \(should \s be \s [^:]+\): \s)?
               ([^:]+): \s
               (.*)
               /x
            ) {
                my ($mib, $suffix, $type, $value) = ($1, $2, $3, $4);

                if ($prefixes{$mib}) {
                    my $oid = $prefixes{$mib} . '.' . $suffix;
                    $last_value = [ $type, $value ];
                    $self->_setOid($oid, $last_value);
                } else {
                    # irrelevant OID
                    $last_value = undef;
                }

                next;
            }
        }

        last if $line =~ /No more variables left in this MIB View/;

        # potential continuation
        if ($line !~ /^$/ && $line !~ /= ""$/ && $last_value) {
            if ($last_value->[0] eq 'STRING' &&
                $last_value->[1] !~ /"$/
            ) {
                chomp $line;
                $last_value->[1] .= "\n" . $line;
                next;
            }
            if ($last_value->[0] eq 'Hex-STRING') {
                chomp $line;
                $last_value->[1] .= $line;
                next;
            }
        }

        $last_value = undef;
    }

    close ($handle);
}

sub _setOid {
    my ($self, $oid, $value) = @_;

    my @oid = split(/\./, $oid);
    shift @oid;

    my $base = $self->{_walk};
    my ($num, $ref);
    while (@oid) {
        $num = shift @oid;
        $ref = $base->[2]->{$num} if $base->[2];
        unless ($ref) {
            $ref = [undef, $num, {}];
            $base->[0] = [] unless $base->[0];
            push @{$base->[0]}, $ref;
            $base->[2]->{$num} = $ref;
        }
        $base = $ref;
    }
    $ref->[2] = undef;
    $ref->[3] = $value;
}

sub _getOid {
    my ($self, $oid, $walk) = @_;

    my @oid = split(/\./, $oid);
    shift @oid;

    my $base = $self->{_walk};
    my ($num, $ref);
    while (@oid) {
        $num = shift @oid;
        return unless $ref = $base->[2];
        $ref = $base->[2]->{$num};
        return unless $ref;
        $base = $ref;
    }

    return $walk ? $ref : $ref->[3];
}

sub get {
    my ($self, $oid) = @_;

    return unless $oid;
    my $value = $self->_getOid($oid)
        or return;

    return _getSanitizedValue(
        $value->[0],
        $value->[1],
    );
}

sub _deepwalk {
    my ($base) = @_;

    my $array = [];

    foreach my $ref (@{$base->[0]}) {
        my $key = $ref->[1];
        if (defined($ref->[3])) {
            push @{$array}, [ $key, _getSanitizedValue(@{$ref->[3]}) ];
        } else {
            my $subkeys = _deepwalk($ref);
            foreach my $subkey (@{$subkeys}) {
                push @{$array}, [ $key.".".($subkey->[0]), $subkey->[1] ];
            }
        }
    }

    return $array;
}

sub walk {
    my ($self, $oid) = @_;

    return unless $oid;

    my $base = $self->_getOid($oid, 1)
        or return;

    my $walk = _deepwalk($base);

    return { map { $_->[0] => $_->[1] } @{$walk} };
}

sub _getSanitizedValue {
    my ($format, $value) = @_;

    if ($format eq 'Hex-STRING') {
        $value =~ s/\s//g;
        $value = "0x".$value;
    } elsif ($format eq 'STRING') {
        $value =~ s/^(?<!\\)"//;
        $value =~ s/(?<!\\)"$//;
    } elsif ($format eq 'OID') {
        if ($value =~ /^ ([^.]+) (\.[\d.]+)? $/x) {
            my $prefix = $1;
            my $suffix = $2 || '';
            $value = $prefixes{$prefix} ?
                $prefixes{$prefix} . $suffix :
                $prefix . $suffix;
        }
    } elsif ($format =~ /timeticks/i) {
        # Keep only string part as return by SNMP get API
        $value = $1 if ($value =~ /^\s*\([\d.]+\)\s*(.*)$/x);
    }

    return $value;
}

sub peer_address {
    my ($self) = @_;

    return $self->{_ip};
}

1;
__END__

=head1 NAME

FusionInventory::Agent::SNMP::Mock - Mock SNMP client

=head1 DESCRIPTION

This is the object used by the agent to replay SNMP queries on snmpwalk files.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item file (mandatory)

=back
