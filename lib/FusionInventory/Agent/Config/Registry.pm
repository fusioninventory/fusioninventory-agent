package FusionInventory::Agent::Config::Registry;

use strict;
use warnings;
use base 'FusionInventory::Agent::Config';

use English qw(-no_match_vars);
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

sub _load {
    my ($self) = @_;

    my $machKey = $Registry->Open('LMachine', {
        Access => Win32::TieRegistry::KEY_READ()
    }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    my $settings = $machKey->{"SOFTWARE/FusionInventory-Agent"};

    foreach my $entry (keys %$settings) {
        if ($entry =~ /^\/(\S+)/) {
            my $key = lc($1);
            $self->{_}->{$key} = _unquote($settings->{$entry});
        } elsif ($entry =~ /(\S+)\/$/) {
            my $section = lc($1);
            foreach my $subEntry (keys %{$settings->{$entry}}) {
                next unless $subEntry =~ /^\/(\S+)/;
                my $key = lc($1);
                $self->{$section}->{$key} =
                    _unquote($settings->{$section}->{$entry});
            }
        }
    }
}

sub _unquote {
    my ($value) = @_;

    $value =~ s/\s+$//;
    $value =~ s/^'(.*)'$/$1/;
    $value =~ s/^"(.*)"$/$1/;

    return $value;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Config::Registry - Registry-based configuration backend

=head1 DESCRIPTION

This is the object used by the agent to store its configuration.
