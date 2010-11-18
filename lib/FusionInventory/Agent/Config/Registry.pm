package FusionInventory::Agent::Config::Registry;

use strict;
use warnings;

use English qw(-no_match_vars);
use Encode;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

sub new {
    my ($class, %params) = @_;

    my $machKey = $Registry->Open('LMachine', {
        Access => Win32::TieRegistry::KEY_READ
    } ) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    my $self = {
        key => $machKey->{"SOFTWARE/FusionInventory-Agent"}
    };
    bless $self, $class;

    return $self;
}

sub load {
    my ($self, $values) = @_;

    foreach my $raw_key (keys %{$self->{key}}) {
        my $raw_alue = $self->{key}->{$raw_key};
        if (ref $raw_value eq 'HASH') {
            # a subsection
            foreach my $raw_subkey (keys %{$self->{key}->{$value}}) {
                my $value = _cleanValue($self->{key}->{$value}->{$raw_subkey});
                my $key = _cleanKey($raw_key) . _cleanKey($raw_subkey);
                $values->{$key} = $value;
            }
        } else {
            # a plain value
            my $value = _cleanValue($raw_value);
            my $key = 'default.' . _cleanKey($raw_key);
            $values->{$key} = $value;
        }
    }
}

sub _cleanValue {
    my ($value) = @_;

    # Remove trailing spaces
    $value =~ s/\s+$//;

    # Remove quotes
    $value =~ s/^'(.*)'$/$1/;
    $value =~ s/^"(.*)"$/$1/;

    return $value;
}

sub _cleanKey {
    my ($key) = @_;

    # Remove leading slash
    $key =~ s/^\///;

    return $key;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Config::Registry - Registry-based backend for configuration

=head1 DESCRIPTION

This is the object used by the agent to store its configuration.

=head1 METHODS

=head2 new($params)

The constructor. All configuration parameters can be passed.
