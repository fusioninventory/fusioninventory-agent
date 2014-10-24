package FusionInventory::Agent::Task::Inventory::Win32::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{network};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my (@gateways, @dns, @ips);

    foreach my $interface (getInterfaces()) {
        push @gateways, $interface->{IPGATEWAY}
            if $interface->{IPGATEWAY};
        push @dns, $interface->{dns}
            if $interface->{dns};

        push @ips, $interface->{IPADDRESS}
            if $interface->{IPADDRESS};

        delete $interface->{dns};
        $interface->{TYPE} = _getMediaType($interface->{PNPDEVICEID});

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
        path   => "HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Control/Network/{4D36E972-E325-11CE-BFC1-08002BE10318}",
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

1;
