package FusionInventory::Agent::Task::Inventory::Input::Win32::License;

use strict;
use warnings;

use English qw(-no_match_vars);
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);


use FusionInventory::Agent::Tools::Win32;
use FusionInventory::Agent::Tools::Generic::License;

sub isEnabled {
    return 1;
}

sub _scanOffice {
    my ($currentKey, $found) = @_;

    my %license;
    if ($currentKey->{'ProductID'}) {
        $license{'KEY'} = $currentKey->{ProductID};
    } elsif ($currentKey->{DigitalProductID}) {
        $license{'KEY'} = decodeWinKey($currentKey->{DigitalProductID});
    }
    if ($currentKey->{ConvertToEdition}) {
        $license{'FULLNAME'} = encodeFromRegistry($currentKey->{ConvertToEdition});
    }
    if ($currentKey->{ProductName}) {
        $license{'FULLNAME'} = encodeFromRegistry($currentKey->{ProductName});
    }
    if ($currentKey->{ProductNameVersion}) {
        $license{'NAME'} = encodeFromRegistry($currentKey->{ProductNameVersion});
    }
    if ($currentKey->{ProductNameNonQualified}) {
        $license{'NAME'} = encodeFromRegistry($currentKey->{ProductNameNonQualified});
    }
    if ($currentKey->{TrialType} && $currentKey->{TrialType} =~ /(\d+)$/) {
        $license{'TRIAL'} = int($1);
    }
    if ($currentKey->{SPLevel}) {
        $license{'UPDATE'} = $currentKey->{SPLevel};
    }
    if ($currentKey->{OEM}) {
        $license{'OEM'} = $currentKey->{OEM};
    }
    my @products;
    foreach(keys %$currentKey) {
        next unless s/\/(\w+)NameVersion$//;
        my $product = $1;
        next unless $currentKey->{$product."NameVersion"};
        push @products, $1;
    }
    if (@products) {
        $license{'COMPONENTS'} = join('/', @products);
    }
    push @$found, \%license if $license{'KEY'};

    foreach my $subKey (  $currentKey->SubKeyNames  ) {
        next if $subKey =~ /\//; # Oops, that's our delimitator
        _scanOffice($currentKey->{$subKey}, $found);
    }
}


sub doInventory {
    my (%params) = @_;

    my $machKey = $Registry->Open('LMachine', {
            Access => KEY_READ ## no critic (ProhibitBitwise)
            }) or $params{logger}->error("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");

    my $office =
        $machKey->{"SOFTWARE/Microsoft/Office"};

    my @found;
    _scanOffice($office, \@found);
    foreach my $license (@found) {
        $params{inventory}->addEntry(section => 'LICENSEINFOS', entry => $license);
    }
}

1;
