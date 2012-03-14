package FusionInventory::Agent::Task::NetDiscovery::Dictionary;

use strict;
use warnings;

use Digest::MD5 qw(md5_hex);
use English qw/-no_match_vars/;
use UNIVERSAL::require;

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;

    SWITCH: {
        if ($params{file}) {
            $self->_init_from_file($params{file});
            last SWITCH;
        }
        if ($params{string}) {
            $self->_init_from_string($params{string});
            last SWITCH;
        }
        if ($params{hash}) {
            $self->_init_from_hash($params{hash});
            last SWITCH;
        }
    }

    return $self;
}

sub _init_from_string {
    my ($self, $string) = @_;

    XML::TreePP->require();
    my $hash = XML::TreePP->new()->parse($string);
    $self->_init_from_hash($hash);
}

sub _init_from_file {
    my ($self, $file) = @_;

    XML::TreePP->require();
    my $hash = XML::TreePP->new()->parsefile($file);
    $self->_init_from_hash($hash);
}

sub _init_from_hash {
    my ($self, $hash) = @_;

    foreach my $device (@{$hash->{SNMPDISCOVERY}->{DEVICE}}) {
        my $md5 = md5_hex($device->{SYSDESCR});
        $self->{models}->{$md5} = $device;
    }
    $self->{hash} = md5_hex($hash);
}

sub getModel {
    my ($self, $description) = @_;

    $description =~ s/\n//g;
    $description =~ s/\r//g;

    my $md5 = md5_hex($description);
    return $self->{models}->{$md5};
}

sub getHash {
    my ($self) = @_;

    return $self->{hash};
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::NetDiscovery::Dictionary - SNMP model dictionary

=head1 DESCRIPTION

This dictionary contains identification information for SNMP devices.

=head1 METHODS

=head2 new

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<string>

The models list, as an XML string.

=item I<file>

The models list, as an XML file.

=item I<hash>

The models list, as an hashref.

=back

=head2 getHash()

Return the hash identifying this dictionary content.

=head2 getModel($description)

Return the model whose sysDescr property matches the given description.
