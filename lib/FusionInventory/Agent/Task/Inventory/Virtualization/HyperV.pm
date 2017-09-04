package FusionInventory::Agent::Task::Inventory::Virtualization::HyperV;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Hostname;

sub isEnabled {
    return $OSNAME eq 'MSWin32';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};
    my $wmiParams = {};
    $wmiParams->{WMIService} = dclone($params{inventory}->{WMIService}) if $params{inventory}->{WMIService};
    $wmiParams->{WMIService}->{root} = "root\\virtualization";

    foreach my $machine (_getVirtualMachines(%$wmiParams, logger => $logger)) {
        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $machine
        );
    }
}

sub _getVirtualMachines {
    my (%params) = @_;

    FusionInventory::Agent::Tools::Win32->require();

    my $hostname = $params{WMIService} ? getHostname(short => 1) : undef;

    my @machines;

    # index memory, cpu and BIOS UUID information
    my %memory;
    foreach my $object (FusionInventory::Agent::Tools::Win32::getWMIObjects(
        %params,
        moniker    => 'winmgmts://./root/virtualization/v2',
        altmoniker => 'winmgmts://./root/virtualization',
        class      => 'MSVM_MemorySettingData',
        properties => [ qw/InstanceID VirtualQuantity/ ]
    )) {
        my $id = $object->{InstanceID};
        next unless $id =~ /^Microsoft:([^\\]+)/;
        $memory{$1} = $object->{VirtualQuantity};
    }

    my %vcpu;
    foreach my $object (FusionInventory::Agent::Tools::Win32::getWMIObjects(
        %params,
        moniker    => 'winmgmts://./root/virtualization/v2',
        altmoniker => 'winmgmts://./root/virtualization',
        class      => 'MSVM_ProcessorSettingData',
        properties => [ qw/InstanceID VirtualQuantity/ ]
    )) {
        my $id = $object->{InstanceID};
        next unless $id =~ /^Microsoft:([^\\]+)/;
        $vcpu{$1} = $object->{VirtualQuantity};
    }

    my %biosguid;
    foreach my $object (FusionInventory::Agent::Tools::Win32::getWMIObjects(
        %params,
        moniker    => 'winmgmts://./root/virtualization/v2',
        altmoniker => 'winmgmts://./root/virtualization',
        class      => 'MSVM_VirtualSystemSettingData',
        properties => [ qw/InstanceID BIOSGUID/ ]
    )) {
        my $id = $object->{InstanceID};
        next unless $id =~ /^Microsoft:([^\\]+)/;
        $biosguid{$1} = $object->{BIOSGUID};
        $biosguid{$1} =~ tr/{}//d;
    }

    foreach my $object (FusionInventory::Agent::Tools::Win32::getWMIObjects(
        %params,
        moniker    => 'winmgmts://./root/virtualization/v2',
        altmoniker => 'winmgmts://./root/virtualization',
        class      => 'MSVM_ComputerSystem',
        properties => [ qw/ElementName EnabledState Name/ ]
    )) {
        # skip host
        next if ($hostname && lc($object->{Name}) eq lc($hostname));

        my $status =
            $object->{EnabledState} == 2     ? 'running'  :
            $object->{EnabledState} == 3     ? 'shutdown' :
            $object->{EnabledState} == 32768 ? 'paused'   :
                                               'unknown'  ;
        my $machine = {
            SUBSYSTEM => 'MS HyperV',
            VMTYPE    => 'HyperV',
            STATUS    => $status,
            NAME      => $object->{ElementName},
            UUID      => $biosguid{$object->{Name}},
            MEMORY    => $memory{$object->{Name}},
            VCPU      => $vcpu{$object->{Name}},
        };

        push @machines, $machine;

    }

    return @machines;
}

1;
