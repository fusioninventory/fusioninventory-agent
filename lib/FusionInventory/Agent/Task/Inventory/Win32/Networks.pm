package FusionInventory::Agent::Task::Inventory::Win32::Networks;

use strict;
use warnings;

use Storable 'dclone';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::Win32;


my $networkRegistryKey = "HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Control/Network/{4D36E972-E325-11CE-BFC1-08002BE10318}";

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{network};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $wmiParams = {};
    $wmiParams->{WMIService} = dclone ($params{inventory}->{WMIService}) if $params{inventory}->{WMIService};
    my (@gateways, @dns, @ips);

    my $dataFromRegistry = $wmiParams->{WMIService} ?
        _getDataFromRemoteRegistry(
            %$wmiParams,
            path => $networkRegistryKey,
            logger => $params{logger}
        ) :
        {};

    foreach my $interface (getInterfaces(%$wmiParams, logger => $params{logger})) {
        push @gateways, $interface->{IPGATEWAY}
            if $interface->{IPGATEWAY};
        push @dns, $interface->{dns}
            if $interface->{dns};

        push @ips, $interface->{IPADDRESS}
            if $interface->{IPADDRESS};

        delete $interface->{dns};
        if ($wmiParams->{WMIService}) {
            if ($dataFromRegistry->{$interface->{PNPDEVICEID}}) {
                $interface->{TYPE} = $dataFromRegistry->{$interface->{PNPDEVICEID}};
            }
        } else {
            $interface->{TYPE} = _getMediaType($interface->{PNPDEVICEID}, $params{logger});
        }

        $inventory->addEntry(
            section => 'NETWORKS',
            entry   => $interface
        );
    }

    $inventory->setHardware({
        DEFAULTGATEWAY => join('/', uniq @gateways),
        DNS            => join('/', uniq @dns),
        IPADDR         => join('/', uniq @ips),
    });

}

sub _getMediaType {
    my ($deviceId, $logger) = @_;

    return unless defined $deviceId;

    my $key = getRegistryKey(
        path   => $networkRegistryKey,
        logger => $logger
    );

    foreach my $subkey_name (keys %$key) {
        # skip variables
        next if $subkey_name =~ m{^/};
        my $subkey = $key->{$subkey_name};
        next unless
            $subkey->{'Connection/'}                     &&
            $subkey->{'Connection/'}->{'/PnpInstanceID'} &&
            $subkey->{'Connection/'}->{'/PnpInstanceID'} eq $deviceId;
        my $subtype = $subkey->{'Connection/'}->{'/MediaSubType'};
        return
            !defined $subtype        ? 'ethernet' :
            $subtype eq '0x00000001' ? 'ethernet' :
            $subtype eq '0x00000002' ? 'wifi'     :
                                       undef;
    }

    ## no critic (ExplicitReturnUndef)
    return undef;
}

sub _getDataFromRemoteRegistry {
    my (%params) = @_;

    return unless $params{WMIService};
    my $path = $params{path};
    my $logger = $params{logger};

    my $subKeys = getRegistryKey(
        WMIService => $params{WMIService},
        path   => $path,
        logger => $logger
    );
    my $data = {};
    return $data unless $subKeys;
    $logger->debug2('ref $subKeys : ' . ref $subKeys);
    foreach my $subkey_name (@$subKeys) {
        # skip variables
        next if $subkey_name =~ m{^/}
            || $subkey_name =~ /Descriptions/;

        my $subkeyPath = $path . '/' . $subkey_name;
        my $subKeyKeys = getRegistryKey(
            WMIService => $params{WMIService},
            path   => $subkeyPath,
            logger => $logger,
            retrieveValuesForKeyName => ['Connection'],
        );
        next unless $subKeyKeys;
        next unless ref $subKeyKeys eq 'HASH';
        my %keys = map { $_ => 1 } keys %$subKeyKeys;
        my $keyName = 'Connection';
        next unless $keys{$keyName};

        my $values = $subKeyKeys->{$keyName};
        next unless $values;

        $keyName = 'PnpInstanceID';
        next unless $values->{$keyName};

        my $subtype = $values->{MediaSubType};

        $data->{$values->{$keyName}} =
                !defined $subtype        ? 'ethernet' :
                $subtype eq '0x00000001' ? 'ethernet' :
                    $subtype eq '0x00000002' ? 'wifi'     :
                    undef;
    }

    ## no critic (ExplicitReturnUndef)
    return $data;
}

1;
