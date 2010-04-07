package FusionInventory::Agent::Task::Inventory::Virtualization::Vserver;

use strict;

sub isInventoryEnabled { return can_run('vserver') }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $config = $params->{config};



    my $utilVserver;
    my $cfgDir;
    foreach (`vserver-info`) {
        $cfgDir = $1 if /^\s+cfg-Directory:\s+(.*)$/;
        $utilVserver = $1 if /^\s+util-vserver:\s+(.*)$/;
    }

    return unless -d $cfgDir;

    if (!opendir(DH, $cfgDir)) {
        return;
    }

    my $name;
    my $status;
    while (($name = readdir(DH))) {
        next if $name =~ /^\./;
        next unless $name =~ /\S/;
        chomp( my $statusString = `vserver "$name" status`);
        if ($statusString =~ /is stopped/) {
            $status = 'off';
        } elsif ($statusString =~ /is running/) {
            $status = 'running';
        }

        $inventory->addVirtualMachine ({
                NAME      => $name,
                STATUS    => $status,
                SUBSYSTEM => $utilVserver,
                VMTYPE    => "vserver",
            });
    }
}

1;
