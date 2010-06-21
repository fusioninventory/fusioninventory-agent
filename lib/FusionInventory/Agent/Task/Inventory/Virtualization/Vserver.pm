package FusionInventory::Agent::Task::Inventory::Virtualization::Vserver;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    return can_run('vserver');
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $config = $params->{config};

    my $utilVserver;
    my $cfgDir;
    foreach (`vserver-info 2>&1`) {
        $cfgDir = $1 if /^\s+cfg-Directory:\s+(.*)$/;
        $utilVserver = $1 if /^\s+util-vserver:\s+(.*)$/;
    }

    return unless -d $cfgDir;

    my $handle;
    if (!opendir $handle, $cfgDir) {
        warn "Can't open $cfgDir: $ERRNO";
        return;
    }

    my $name;
    my $status;
    while ($name = readdir($handle)) {
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
    close $handle;
}

1;
