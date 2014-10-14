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
    my $logger    = $params{inventory};

    foreach my $machine (_getVirtualMachines(logger => $logger)) {
        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $machine
        );
    }
}

sub _getVirtualMachines {

    FusionInventory::Agent::Tools::Win32->use();

    my $hostname = getHostname(short => 1);

    my @machines;

    # index memory and cpu information
    my %memory;
    foreach my $object (getWMIObjects(
        moniker    => 'winmgmts://./root/virtualization',
        class      => 'MSVM_MemorySettingData',
        properties => [ qw/InstanceID VirtualQuantity/ ]
    )) {
        my $id = $object->{InstanceID};
        next unless $id =~ /^Microsoft:([^\\]+)/;
        $memory{$1} = $object->{VirtualQuantity};
    }

    my %vcpu;
    foreach my $object (getWMIObjects(
        moniker    => 'winmgmts://./root/virtualization',
        class      => 'MSVM_ProcessorSettingData',
        properties => [ qw/InstanceID VirtualQuantity/ ]
    )) {
        my $id = $object->{InstanceID};
        next unless $id =~ /^Microsoft:([^\\]+)/;
        $vcpu{$1} = $object->{VirtualQuantity};
    }

    foreach my $object (getWMIObjects(
        moniker    => 'winmgmts://./root/virtualization',
        class      => 'MSVM_ComputerSystem',
        properties => [ qw/ElementName EnabledState Name/ ]
    )) {
        # skip host
        next if lc($object->{Name}) eq lc($hostname);

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
            UUID      => $object->{Name},
            MEMORY    => $memory{$object->{Name}},
            VCPU      => $vcpu{$object->{Name}},
        };

        push @machines, $machine;

    }

    return @machines;
}

1;
