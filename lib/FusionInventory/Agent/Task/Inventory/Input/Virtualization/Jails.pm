package FusionInventory::Agent::Task::Inventory::Input::Virtualization::Jails;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('jls');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{inventory};

    my $command = 'jls -n';
    foreach my $machine (_getVirtualMachines(logger => $logger)) {
        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $machine
        );
    }
}

sub  _getVirtualMachines {
    my (%params) = (
        command => 'jls -n',
        @_
    );

    my $handle = getFileHandle(%params);

    return unless $handle;

    my @machines;
    while (my $line = <$handle>) {
        my $info;
        foreach my $item (split(' ', $line)) {
            next unless $item =~ /(\S+)=(\S+)/;
            my $key   = $1;
            my $value = $2;
            $info->{$1} = $2;
        }

        my $machine = {
            VMTYPE    => 'jail',
            NAME      => $info->{'host.hostname'},
            VMID      => $info->{'jid'},
            STATUS    => 'running'
        };

        push @machines, $machine;

    }
    close $handle;

    return @machines;
}

1;
