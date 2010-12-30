package FusionInventory::Agent::Task::Inventory::Virtualization::Virtuozzo;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('vzlist');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(
        command => 'vzlist --all --no-header -o hostname,ctid,cpulimit,status,ostemplate',
        logger  => $logger
    );

    return unless $handle;

    # no service containers in glpi
    my $line = <$handle>;

    while (my $line = <$handle>) {

        chomp $line; 
        my ($name, $uuid, $cpus, $status, $subsys) = split(/[ \t]+/, $line);

        my ($memory) = getFirstMatch(
            file    => "/etc/vz/conf/$uuid.conf",
            pattern => qr/^SLMMEMORYLIMIT="\d+:(\d+)"$/,
            logger  => $logger,
        );
        $memory = $memory / 1024 / 1024 if $memory;
 
        $inventory->addVirtualMachine({
            NAME      => $name,
            VCPU      => $cpus,
            UUID      => $uuid,
            MEMORY    => $memory,
            STATUS    => $status,
            SUBSYSTEM => $subsys,
            VMTYPE    => "Virtuozzo",
        });

    }

    close $handle;
}

1;

