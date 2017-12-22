package FusionInventory::Agent::Task::Inventory::Win32::License;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools::License;
use FusionInventory::Agent::Tools::Win32;

my $seenProducts;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{licenseinfo};
    return 1;
}

sub isEnabledForRemote {
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

    push @licenses, _getWmiSoftwareLicensingProducts();

    foreach my $license (@licenses) {
        $inventory->addEntry(
            section => 'LICENSEINFOS',
            entry   => $license
        );
    }

    # Reset seen products list
    $seenProducts = {};
}

sub _getWmiSoftwareLicensingProducts {

    my @licences;

    foreach my $object (getWMIObjects(
        moniker    => 'winmgmts:\\\\.\\root\\CIMV2',
        class      => 'SoftwareLicensingProduct',
        properties => [ qw/
            Name Description LicenseStatus PartialProductKey ID
            ProductKeyChannel ProductKeyID ProductKeyID2 ApplicationID
        / ]
    )) {
        my $key = $object->{'PartialProductKey'}
            or next;

        next unless $object->{'LicenseStatus'};

        # Skip operating system license as still set from OS module
        next if ($object->{'Description'} && $object->{'Description'} =~ /Operating System/i);

        my $seenKey;
        if ($object->{'ID'} && $seenProducts->{lc($object->{'ID'})}) {
            $seenKey = $seenProducts->{lc($object->{'ID'})};
            # Skip if found License for related ProductCode
            if ($seenKey->{'/ProductCode'}) {
                my $ProductCodeUuid =  lc( $seenKey->{'/ProductCode'} =~ /([-\w]+)/ && $1 );
                next if $seenProducts->{$ProductCodeUuid} &&
                    $seenProducts->{$ProductCodeUuid}->{'/DigitalProductID'};
            }
        }

        if ($key && length($key) == 5) {
            $key = sprintf("XXXXX-XXXXX-XXXXX-XXXXX-%s", $key);
        }

        my $channel = $object->{'ProductKeyChannel'} || '';
        my $license = {
            KEY       => $key,
            PRODUCTID => $object->{'ProductKeyID2'} ||
                $object->{'ApplicationID'} || $object->{'ProductKeyID'},
            OEM       => $channel =~ /OEM/i ? 1 : 0,
            FULLNAME  => $object->{'Description'},
            NAME      => $object->{'Name'}
        };

        if ($seenKey) {
            # Update FULLNAME if seen ProductName in registry
            $license->{FULLNAME} = encodeFromRegistry($seenKey->{'/ProductName'})
                if $seenKey->{'/ProductName'};
            $license->{TRIAL} = 1
                if ($seenKey->{'/ProductNameBrand'} && $seenKey->{'/ProductNameBrand'} =~ /trial/i);
        }

        push @licences, $license;
    }

    return @licences;
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

            my $cleanUuidKey = lc( $uuidKey =~ /([-\w]+)/ && $1 );
            # Keep in memory seen product with ProductCode value
            $seenProducts->{$cleanUuidKey} = $registrationKey->{$uuidKey}
                if ($registrationKey->{$uuidKey}->{'/ProductCode'});

            next unless $registrationKey->{$uuidKey}->{'/DigitalProductID'};
            push @licences, _getOfficeLicense($registrationKey->{$uuidKey});

            # Keep seen product to not add again them in _getWmiSoftwareLicensingProducts()
            $seenProducts->{$cleanUuidKey} = $registrationKey->{$uuidKey};
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
