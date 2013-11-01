package FusionInventory::Agent::Config::Registry;

use strict;
use warnings;

use English qw(-no_match_vars);

use base qw(FusionInventory::Agent::Config::Backend);

use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

sub getValues {
    my ($self) = @_;

    my $machKey = $Registry->Open('LMachine', {
        Access => Win32::TieRegistry::KEY_READ()
    }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    my $settings = $machKey->{"SOFTWARE/FusionInventory-Agent"};
    my %values;

    foreach my $rawKey (keys %$settings) {
        next unless $rawKey =~ /^\/(\S+)/;
        my $key = lc($1);
        my $value = $settings->{$rawKey};

        # remove the quotes
        $value =~ s/\s+$//;
        $value =~ s/^'(.*)'$/$1/;
        $value =~ s/^"(.*)"$/$1/;

        $values{$key} = $value;
    }

    return %values;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Config::Registry - Registry-based configuration backend

=head1 DESCRIPTION

This is a windows-specific registry configuration backend
