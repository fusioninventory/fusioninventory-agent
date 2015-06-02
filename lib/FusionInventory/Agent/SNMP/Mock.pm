package FusionInventory::Agent::SNMP::Mock;

use strict;
use warnings;
use base 'FusionInventory::Agent::SNMP';

use FusionInventory::Agent::Tools;

my %prefixes = (
    'iso'                               => '.1',
    'SNMPv2-MIB::sysDescr'              => '.1.3.6.1.2.1.1.1',
    'SNMPv2-MIB::sysObjectID'           => '.1.3.6.1.2.1.1.2',
    'SNMPv2-MIB::sysUpTime'             => '.1.3.6.1.2.1.1.3',
    'SNMPv2-MIB::sysContact'            => '.1.3.6.1.2.1.1.4',
    'SNMPv2-MIB::sysName'               => '.1.3.6.1.2.1.1.5',
    'SNMPv2-MIB::sysLocation'           => '.1.3.6.1.2.1.1.6',
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

    my $self = {};
    bless $self, $class;

    SWITCH: {
        if ($params{file}) {
            die "non-existing file '$params{file}'\n"
                unless -f $params{file};
            die "unreadable file '$params{file}'\n"
                unless -r $params{file};
            $self->{values} = _getIndexedValues($params{file});
            $self->{file}   = $params{file};
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
        $self->{values} = _getIndexedValues($file);
    } else {
        delete $self->{values};
    }
}

sub reset_original_context {
    my ($self) = @_;

    $self->{values} = $self->{oldvalues};
    delete $self->{oldvalues};
}

sub _getIndexedValues {
    my ($file) = @_;

    my $handle = getFileHandle(file => $file);

    # check first line
    my $first_line = <$handle>;
    seek($handle, 0, 0);

    # check first line for safety
    die "invalid file format\n" unless $first_line =~ /^(\S+) = .*/;

    my $values = substr($first_line, 0, 1) eq '.' ?
        _readNumericalOids($handle) :
        _readSymbolicOids($handle)  ;
    close ($handle);

    return $values;
}

sub _readNumericalOids {
    my ($handle) = @_;

    my ($values, $last_oid);
    while (my $line = <$handle>) {

        if ($line =~ /^
           (\S+) \s
           = \s
           (?:Wrong \s Type \s \(should \s be \s [^:]+\): \s)?
           ([^:]+): \s
           (.*)
           /x
        ) {
            my ($oid, $type, $value) = ($1, $2, $3);
            $values->{$oid} = [ $type, $value ];
            $last_oid = $oid;
            next;
        }

        # potential continuation
        if ($line !~ /^$/ && $line !~ /= ""$/ && $last_oid) {
            if ($values->{$last_oid}->[0] eq 'STRING' &&
                $values->{$last_oid}->[1] !~ /"$/
            ) {
                chomp $line;
                $values->{$last_oid}->[1] .= "\n" . $line;
                next;
            }
            if ($values->{$last_oid}->[0] eq 'Hex-STRING') {
                chomp $line;
                $values->{$last_oid}->[1] .= $line;
                next;
            }
        }

        $last_oid = undef;
    }

    return $values;
}

sub _readSymbolicOids {
    my ($handle) = @_;


    my ($values, $last_oid);
    while (my $line = <$handle>) {

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
                $values->{$oid} = [ $type, $value ];
                $last_oid = $oid;
            } else {
                # irrelevant OID
                $last_oid = undef;
            }

            next;
        }

        # potential continuation
        if ($line !~ /^$/ && $line !~ /= ""$/ && $last_oid) {
            if ($values->{$last_oid}->[0] eq 'STRING' &&
                $values->{$last_oid}->[1] !~ /"$/
            ) {
                chomp $line;
                $values->{$last_oid}->[1] .= "\n" . $line;
                next
            }
            if ($values->{$last_oid}->[0] eq 'Hex-STRING' &&
                $line =~ /^([A-F0-9]{2})( [A-F0-9]{2})?/
            ) {
                chomp $line;
                $values->{$last_oid}->[1] .= $line;
                next
            }
        }

        $last_oid = undef;
    }

    return $values;
}

sub get {
    my ($self, $oid) = @_;

    return unless $oid;
    return unless $self->{values}->{$oid};

    return _getSanitizedValue(
        $self->{values}->{$oid}->[0],
        $self->{values}->{$oid}->[1],
    );
}

sub walk {
    my ($self, $oid) = @_;

    return unless $oid;

    my $values;
    foreach my $key (keys %{$self->{values}}) {
       next unless $key =~ /^$oid\.(.+)/;
       $values->{$1} = _getSanitizedValue(
           $self->{values}->{$key}->[0],
           $self->{values}->{$key}->[1]
       );
    }

    return $values;
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
    }

    return $value;
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
