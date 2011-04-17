package FusionInventory::Agent::Task::Inventory::OS::Solaris::Drives;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return can_run('df');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get drives list
    my @drives =
        # exclude solaris 10 specific devices
        grep { $_->{VOLUMN} !~ /^\/(devices|platform)/ } 
        # keep physical devices or swap
        grep { $_->{VOLUMN} =~ /^(\/|swap)/ } 
        # exclude cdrom mount
        grep { $_->{TYPE} !~ /cdrom/ } 
        # get all file systems
        getFilesystemsFromDf(logger => $logger, command => 'df -P -k');

    # get additional informations
    foreach my $drive (@drives) {

        if ($drive->{VOLUMN} eq 'swap') {
            $drive->{FILESYSTEM} = 'swap';
            next;
        }

        my $line = getFirstLine(
            command => "zfs get org.opensolaris.libbe:uuid $drive->{VOLUMN}"
        );

        if ($line =~ /org.opensolaris.libbe:uuid\s+(\S{5}\S+)/) {
            $drive->{UUID} = $1;
            $drive->{FILESYSTEM} = 'zfs';
            next;
        }

        $drive->{FILESYSTEM} =
            getFirstLine(command => "fstyp $drive->{VOLUMN}");
    }

    # add drives to the inventory
    foreach my $drive (@drives) {
        $inventory->addEntry({
            section => 'DRIVES',
            entry   => $drive
        });
    }
}

1;
