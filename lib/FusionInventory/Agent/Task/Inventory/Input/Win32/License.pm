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

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    # TODO: 64/32 bit support
    my $machKey = $Registry->Open('LMachine', {
        Access => KEY_READ ## no critic (ProhibitBitwise)
    }) or $params{logger}->error(
        "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR"
    );

    my $office = $machKey->{"SOFTWARE/Microsoft/Office"};

    my @licenses = _scanOffice($office);

    foreach my $license (@licenses) {
        $params{inventory}->addEntry(
            section => 'LICENSEINFOS',
            entry   => $license
        );
    }

}

sub _scanOffice {
    my ($currentKey) = @_;

    my %license = {
        PRODUCTID => $currentKey->{ProductID},
        UPDATE    => $currentKey->{SPLevel},
        OEM       => $currentKey->{OEM},
        FULLNAME  => encodeFromRegistry($currentKey->{ProductName}) ||
                     encodeFromRegistry($currentKey->{ConvertToEdition}),
        NAME      => encodeFromRegistry($currentKey->{ProductNameNonQualified}) ||
                     encodeFromRegistry($currentKey->{ProductNameVersion})
    };

    if ($currentKey->{DigitalProductID}) {
        $license{KEY} = parseProductKey($currentKey->{DigitalProductID});
    }

    if ($currentKey->{TrialType} && $currentKey->{TrialType} =~ /(\d+)$/) {
        $license{TRIAL} = int($1);
    }

    my @products;
    foreach my $entry (keys %$currentKey) {
        next unless $entry =~ s/\/(\w+)NameVersion$//;
        my $product = $1;
        next unless $currentKey->{$product."NameVersion"};
        push @products, $product;
    }
    if (@products) {
        $license{COMPONENTS} = join('/', @products);
    }

    my @licenses;
    push @licenses, \%license if $license{KEY};

    foreach my $subKey (  $currentKey->SubKeyNames  ) {
        next if $subKey =~ /\//; # Oops, that's our delimitator
        push @licenses, _scanOffice($currentKey->{$subKey});
    }

    return @licenses;
}

1;
