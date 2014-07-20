package FusionInventory::Agent::Task::Inventory::Win32::License;

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

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $is64bit = is64bit();
    my @licenses;

    if ($is64bit) {
        my $machKey64 = $Registry->Open('LMachine', {
            Access => KEY_READ | KEY_WOW64_64 ## no critic (ProhibitBitwise)
        }) or $logger->error("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");
        my $officeKey64 = $machKey64->{"SOFTWARE/Microsoft/Office"};
        push @licenses, _scanOffice($officeKey64 ) if $officeKey64;

        my $machKey32 = $Registry->Open('LMachine', {
            Access => KEY_READ | KEY_WOW64_32 ## no critic (ProhibitBitwise)
        }) or $logger->error("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");

        my $officeKey32 = $machKey32->{"SOFTWARE/Microsoft/Office"};
        push @licenses, _scanOffice($officeKey32) if $officeKey32;
    } else {
        my $machKey = $Registry->Open('LMachine', {
            Access => KEY_READ ## no critic (ProhibitBitwise)
        }) or $logger->error(
            "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR"
        );

        my $officeKey = $machKey->{"SOFTWARE/Microsoft/Office"};
        push @licenses, _scanOffice($officeKey) if $officeKey;
    }

    foreach my $license (@licenses) {
        $params{inventory}->addEntry(
            section => 'LICENSEINFOS',
            entry   => $license
        );
    }
}

sub _scanOffice {
    my ($key) = @_;

    my %license = (
        PRODUCTID => $key->{ProductID},
        UPDATE    => $key->{SPLevel},
        OEM       => $key->{OEM},
        FULLNAME  => encodeFromRegistry($key->{ProductName}) ||
                     encodeFromRegistry($key->{ConvertToEdition}),
        NAME      => encodeFromRegistry($key->{ProductNameNonQualified}) ||
                     encodeFromRegistry($key->{ProductNameVersion})
    );

    if ($key->{DigitalProductID}) {
        $license{KEY} = parseProductKey($key->{DigitalProductID});
    }

    if ($key->{TrialType} && $key->{TrialType} =~ /(\d+)$/) {
        $license{TRIAL} = int($1);
    }

    my @products;
    foreach my $entry (keys %$key) {
        next unless $entry =~ s/\/(\w+)NameVersion$//;
        my $product = $1;
        next unless $key->{$product."NameVersion"};
        push @products, $product;
    }
    if (@products) {
        $license{COMPONENTS} = join('/', @products);
    }

    my @licenses;
    push @licenses, \%license if $license{KEY};

    foreach my $subKey (keys %$key) {
        # skip variables
        next if $subKey =~ m{^/};
        push @licenses, _scanOffice($key->{$subKey});
    }

    return @licenses;
}

1;
