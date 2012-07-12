package FusionInventory::Agent::SNMP::Mock;

use strict;
use warnings;
use base 'FusionInventory::Agent::SNMP';

use FusionInventory::Agent::Tools;

sub new {
    my ($class, %params) = @_;

    die "no file parameter" unless $params{file};
    die "non-existing file parameter" unless -f $params{file};
    die "unreadable file parameter" unless -r $params{file};

    my $self = {
        values => _getIndexedValues($params{file})
    };

    bless $self, $class;

    return $self;

}

sub _getIndexedValues {
    my ($file) = @_;

    my $values;
    my $handle = getFileHandle(file => $file);
    while (my $line = <$handle>) {
       next unless $line =~ /^(\S+)\s=\s(\S+):\s(.*)/;
       my $oid = _getSanitizedOid($1);
       $values->{$oid} = [ $2, $3 ];
    }
    close ($handle);

    return $values;
}

sub get {
    my ($self, $oid) = @_;

    return unless $oid;
    $oid = _getSanitizedOid($oid);

    return _getSanitizedValue(
        $self->{values}->{$oid}->[0],
        $self->{values}->{$oid}->[1],
    );
}

sub walk {
    my ($self, $oid) = @_;

    return unless $oid;
    $oid = _getSanitizedOid($oid);

    my $values;
    foreach my $key (keys %{$self->{values}}) {
       next unless $key =~ /^$oid\./;
       $values->{$key} = _getSanitizedValue(
           $self->{values}->{$key}->[0],
           $self->{values}->{$key}->[1]
       );
    }

    return $values;
}

sub _getSanitizedOid {
    my ($oid) = @_;

    $oid =~ s/^\.//;
    $oid =~ s/^iso\./1./;
    $oid =~ s/SNMPv2-MIB::sysDescr(\.\d+)/1.3.6.1.2.1.1.1.0/;
    $oid =~ s/SNMPv2-MIB::sysName.0/1.3.6.1.2.1.1.5.0/;
    $oid =~ s/DISMAN-EVENT-MIB::sysUpTimeInstance/1.3.6.1.2.1.1.3.0/;

    return $oid;
}

sub _getSanitizedValue {
    my ($format, $value) = @_;

    if ($format eq 'Hex-STRING') {
        $value =~ s/\s//g;
    } else {
        $value =~ s/"(.*)"/$1/;
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
