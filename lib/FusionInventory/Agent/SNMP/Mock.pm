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

    # check first line
    my $first_line = <$handle>;
    seek($handle, 0, 0);
    die "invalid content: non-numerical oids"
        if substr($first_line, 0, 1) ne '.';

    while (my $line = <$handle>) {
       next unless $line =~ /^(\S+) \s = \s (\S+): \s (.*)/x;
       $values->{$1} = [ $2, $3 ];
    }
    close ($handle);

    return $values;
}

sub _convertOid {
    my ($oid) = @_;

    return $oid;
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
       next unless $key =~ /^$oid\./;
       $values->{$key} = _getSanitizedValue(
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
