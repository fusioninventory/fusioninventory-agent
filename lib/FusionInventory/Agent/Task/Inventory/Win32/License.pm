package FusionInventory::Agent::Task::Inventory::Win32::License;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools::License;
use FusionInventory::Agent::Tools::Win32;
use FusionInventory::Agent::Tools;

# Key : UUID, Value : Hash With two Keys, One 'REGISTRY' for registry information, one 'WMI' for WMI information
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

sub resetSeenProducts {
    $seenProducts = {};
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my @licenses;

    my $officeKey = getRegistryKey(
        path => "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Office"
    );
    _scanOfficeLicences($officeKey) if $officeKey;

    if (is64bit()) {
        my $officeKey32 = getRegistryKey(
            path => "HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/Microsoft/Office"
        );
        _scanOfficeLicences($officeKey32) if $officeKey32;
    }

    _scanWmiSoftwareLicensingProducts();

    push @licenses, _mergeSeenProduct() if %{$seenProducts};

    foreach my $license (@licenses) {
        $inventory->addEntry(
            section => 'LICENSEINFOS',
            entry   => $license
        );
    }

    resetSeenProducts();
}

sub _scanWmiSoftwareLicensingProducts {

    my ($licences) = @_;

    foreach my $object (getWMIObjects(
        moniker    => 'winmgmts:\\\\.\\root\\CIMV2',
        class      => 'SoftwareLicensingProduct',
        properties => [ qw/
            Name Description LicenseStatus PartialProductKey ID
            ProductKeyChannel ProductKeyID ProductKeyID2 ApplicationID
        / ]
    )) {
        next unless $object->{'PartialProductKey'} && $object->{'LicenseStatus'};

        # Skip operating system license as still set from OS module
        next if ($object->{'Description'} && $object->{'Description'} =~ /Operating System/i);

        $seenProducts->{lc($object->{'ID'})}->{'WMI'} = $object if $object->{'ID'};
    }
}

sub _mergeSeenProduct() {
    my @licenses;

    # uuid of ID Product already used by WMI to not create Duplicate when we read only Registry key
    my @uuidUsed;
    # Sort by presence of WMI Hash, that force implement WMI logic with @uuidUsed before Registry
    my @seenProductsValuesSorted = sort {exists($b->{'WMI'}) <=> exists($a->{'WMI'})} values %{$seenProducts};

    foreach my $seenProduct (@seenProductsValuesSorted) {
        my $license;
        my $updateByRegistry = 0;
        if ($seenProduct->{'WMI'}) {
            my $wmiKey = $seenProduct->{'WMI'}->{'PartialProductKey'};
            $license = _getWmiLicense($seenProduct->{'WMI'});
            if ($seenProduct->{'REGISTRY'}) {
                my $productCodeUuid = lc($seenProduct->{'REGISTRY'}->{'/ProductCode'} =~ /([-\w]+)/ && $1)
                    if $seenProduct->{'REGISTRY'}->{'/ProductCode'};
                my $templicense = _getOfficeLicense($seenProducts->{$productCodeUuid}->{'REGISTRY'}) 
                    if $productCodeUuid && $seenProducts->{$productCodeUuid}->{'REGISTRY'}->{'/DigitalProductID'};
                if ($templicense) {
                    push @uuidUsed, $productCodeUuid;
                    if ($templicense->{'KEY'} =~ m/$wmiKey$/) {
                        $license = $templicense;
                    } else {
                        $updateByRegistry = 1;
                    }
                } else {
                    $updateByRegistry = 1;
                }

                if ($updateByRegistry) {
                    $license->{'FULLNAME'} = encodeFromRegistry($seenProduct->{'REGISTRY'}->{'/ProductName'})
                        if $seenProduct->{'REGISTRY'}->{'/ProductName'};
                    $license->{'TRIAL'} = 1 
                        if $seenProduct->{'REGISTRY'}->{'/ProductNameBrand'} && $seenProduct->{'REGISTRY'}->{'/ProductNameBrand'} =~ /trial/i;
                }
            }
        }
        if (!$seenProduct->{'WMI'} && $seenProduct->{'REGISTRY'}->{'/DigitalProductID'} && !first {$seenProducts->{$_} eq $seenProduct} @uuidUsed) {
            $license = _getOfficeLicense($seenProduct->{'REGISTRY'});
        }
        push @licenses, $license if $license;
    }
    return @licenses;
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

    foreach my $versionKey (keys %{$key}) {
        my $registrationKey = $key->{$versionKey}->{'Registration/'};
        next unless $registrationKey;

        foreach my $uuidKey (keys %{$registrationKey}) {

            my $cleanUuidKey = lc( $uuidKey =~ /([-\w]+)/ && $1 );
            # Keep in memory seen product with ProductCode value or DigitalProductID
            $seenProducts->{$cleanUuidKey}->{'REGISTRY'} = $registrationKey->{$uuidKey} 
                if ($registrationKey->{$uuidKey}->{'/ProductCode'} || $registrationKey->{$uuidKey}->{'/DigitalProductID'});
        }
    }
}

sub _getWmiLicense {
    my ($wmi) = @_;
    my $key = $wmi->{'PartialProductKey'};
    if ($key && length($key) == 5) {
        $key = sprintf("XXXXX-XXXXX-XXXXX-XXXXX-%s", $key);
    }
    my $channel = $wmi->{'ProductKeyChannel'} || '';
    my $license = {
        KEY       => $key,
        PRODUCTID => $wmi->{'ProductKeyID2'} || $wmi->{'ApplicationID'} || $wmi->{'ProductKeyID'},
        OEM       => $channel =~ /OEM/i ? 1 : 0,
        FULLNAME  => $wmi->{'Description'},
        NAME      => $wmi->{'Name'}
    };

    return $license;
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
