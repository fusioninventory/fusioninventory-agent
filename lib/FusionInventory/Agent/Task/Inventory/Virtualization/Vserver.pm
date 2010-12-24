package FusionInventory::Agent::Task::Inventory::Virtualization::Vserver;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('vserver');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $config    = $params{config};

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

    while (my $name = readdir($handle)) {
        next if $name =~ /^\./;
        next unless $name =~ /\S/;

        my $line = getFirstLine(command => "vserver $name status");
        my $status =
            $line =~ /is stopped/ ? 'off'     :
            $line =~ /is running/ ? 'running' :
                                    undef     ;

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
