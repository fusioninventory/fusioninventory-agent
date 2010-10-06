package FusionInventory::Agent::Task::Inventory::OS::BSD::Drives;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run("df");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my $drives;

    if ($OSNAME eq 'freebsd') {
        # FreeBSD df command support the -T flag, allowing to fetch all
        # filesystems at once
        $drives = getFilesystemsFromDf($logger, 'df -P -T -k -t ffs,ufs', '-|');
    } else {
        # other BSD flavours don't support this flag, forcing to use 
        # successives calls
        my $ffs_drives = getFilesystemsFromDf($logger, 'df -P -k -t ffs', '-|');
        if ($ffs_drives) {
            foreach my $drive (@$ffs_drives) {
                $drive->{FILESYSTEM} = 'ffs';
            }
            push @$drives, @$ffs_drives;
        }

        my $ufs_drives = getFilesystemsFromDf($logger, 'df -P -k -t ufs', '-|');
        if ($ufs_drives) {
            foreach my $drive (@$ufs_drives) {
                $drive->{FILESYSTEM} = 'ufs';
            }
            push @$drives, @$ufs_drives;
        }
    }

    foreach my $drive (@$drives) {
        $inventory->addDrive($drive);
    }
}


1;
