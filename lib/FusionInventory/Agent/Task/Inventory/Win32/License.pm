package FusionInventory::Agent::Task::Inventory::Win32::License;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use English qw(-no_match_vars);

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

    my @licenses;

    my $officeKey = getRegistryKey(
        path => "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Office"
    );
    push @licenses, _scanOfficeLicences($officeKey) if $officeKey;

    if (is64bit()) {
        my $officeKey32 = getRegistryKey(
            path => "HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/Microsoft/Office"
        );
        push @licenses, _scanOfficeLicences($officeKey32) if $officeKey32;
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
