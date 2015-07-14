package FusionInventory::Agent::Task::Inventory::Win32::License;

use strict;
use warnings;

use English qw(-no_match_vars);
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Tools::License;
use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{licenseinfo};
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
        push @licenses, _scanOfficeLicences($officeKey64 ) if $officeKey64;

        my $machKey32 = $Registry->Open('LMachine', {
            Access => KEY_READ | KEY_WOW64_32 ## no critic (ProhibitBitwise)
        }) or $logger->error("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");

        my $officeKey32 = $machKey32->{"SOFTWARE/Microsoft/Office"};
        push @licenses, _scanOfficeLicences($officeKey32) if $officeKey32;
    } else {
        my $machKey = $Registry->Open('LMachine', {
            Access => KEY_READ ## no critic (ProhibitBitwise)
        }) or $logger->error(
            "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR"
        );

        my $officeKey = $machKey->{"SOFTWARE/Microsoft/Office"};
        push @licenses, _scanOfficeLicences($officeKey) if $officeKey;
    }

    foreach my $license (@licenses) {
        $inventory->addEntry(
            section => 'LICENSEINFOS',
            entry   => $license
        );
    }
}

sub _scanOfficeLicences {
    my ($key) = @_;

    # registry data structure:
    # SOFTWARE/Microsoft/Office
    # └── x.y
    #     └── Registration
    #         └── UUID
    #             └── DigitalProductID:value
    #             └── ProductID:value
    #             └── ...

    my @licences;

    foreach my $versionKey (keys %{$key}) {
        my $registrationKey = $key->{$versionKey}->{'Registration/'};
        next unless $registrationKey;

        foreach my $uuidKey (keys %{$registrationKey}) {
            next unless $registrationKey->{$uuidKey}->{'/DigitalProductID'};
            push @licences, _getOfficeLicense($registrationKey->{$uuidKey});
        }
    }

    return @licences;
}

sub _getOfficeLicense {
    my ($key) = @_;

    my $license = {
        KEY       => decodeMicrosoftKey($key->{'/DigitalProductID'}),
        PRODUCTID => $key->{'/ProductID'},
        UPDATE    => $key->{'/SPLevel'},
        OEM       => $key->{'/OEM'},
        FULLNAME  => encodeFromRegistry($key->{'/ProductName'}) ||
                     encodeFromRegistry($key->{'/ConvertToEdition'}),
        NAME      => encodeFromRegistry($key->{'/ProductNameNonQualified'}) ||
                     encodeFromRegistry($key->{'/ProductNameVersion'})
    };

    if ($key->{'/TrialType'} && $key->{'/TrialType'} =~ /(\d+)$/) {
        $license->{TRIAL} = int($1);
    }

    my @products;
    foreach my $variable (keys %$key) {
        next unless $variable =~ m/\/(\w+)NameVersion$/;
        push @products, $1;
    }
    if (@products) {
        $license->{COMPONENTS} = join('/', sort @products);
    }

    return $license;
}

1;
