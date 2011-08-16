package FusionInventory::Agent::Task::Inventory::OS::Solaris::Drives;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isEnabled {
    return canRun('df');
}

sub _getDfCmd {
    my $line = getFirstLine(
        command => "df --version"
    );

    my $ret = ($line =~ /GNU/)?"df -P -k":"df -P -k";

    return $ret;
}
print _getDfCmd();

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get filesystems list
    my @filesystems =
        # exclude solaris 10 specific devices
        grep { $_->{VOLUMN} !~ /^\/(devices|platform)/ } 
        # keep physical devices or swap
        grep { $_->{VOLUMN} =~ /^(\/|swap)/ } 
        # exclude cdrom mount
        grep { $_->{TYPE} !~ /cdrom/ } 
        # get all file systems
        getFilesystemsFromDf(logger => $logger, command => _getDfCmd());

    # get additional informations
    foreach my $filesystem (@filesystems) {

        if ($filesystem->{VOLUMN} eq 'swap') {
            $filesystem->{FILESYSTEM} = 'swap';
            next;
        }

        my $line = getFirstLine(
            command => "zfs get org.opensolaris.libbe:uuid $filesystem->{VOLUMN}"
        );

        if ($line =~ /org.opensolaris.libbe:uuid\s+(\S{5}\S+)/) {
            $filesystem->{UUID} = $1;
            $filesystem->{FILESYSTEM} = 'zfs';
            next;
        }

        $filesystem->{FILESYSTEM} =
            getFirstLine(command => "fstyp $filesystem->{VOLUMN}");
    }

    # add filesystems to the inventory
    foreach my $filesystem (@filesystems) {
        $inventory->addEntry(
            section => 'DRIVES',
            entry   => $filesystem
        );
    }
}

1;
