package FusionInventory::Agent::Task::Inventory::OS::Solaris::Drives;

use strict;

#Filesystem            kbytes    used   avail capacity  Mounted on
#/dev/vx/dsk/bootdg/rootvol 16525754 5423501 10936996    34%    /
#/devices                   0       0       0     0%    /devices
#ctfs                       0       0       0     0%    /system/contract
#proc                       0       0       0     0%    /proc
#mnttab                     0       0       0     0%    /etc/mnttab

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return can_run('df');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @drives =
        # exclude solaris 10 specific devices
        grep { $_->{VOLUMN} !~ /^\/(devices|platform)/; } 
        # keep physical devices or swap
        grep { $_->{VOLUMN} =~ /^(\/|swap)/; } 
        # exclude cdrom mount
        grep { $_->{TYPE} !~ /cdrom/; } 
        # get all file systems
        getFilesystemsFromDf( logger => $logger, string => getDfoutput() );

    foreach my $drive (@drives) {

        # compute filesystem type
        if ($drive->{VOLUMN} eq 'swap') {
            $drive->{FILESYSTEM} = 'swap';
        } elsif (
            `zfs get org.opensolaris.libbe:uuid $drive->{VOLUMN} 2>&1`
                =~ /org.opensolaris.libbe:uuid\s+(\S{5}\S+)/
        ) {
            $drive->{UUID} = $1;
            $drive->{FILESYSTEM} = 'zfs';
        } else {
            my $fs = `fstyp $drive->{VOLUMN} 2>/dev/null`;
            chomp $fs;
            $drive->{FILESYSTEM} = $fs;
        }

        $inventory->addDrive($drive);
    }
}

1;
