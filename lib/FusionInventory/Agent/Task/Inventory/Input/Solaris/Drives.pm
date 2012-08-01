package FusionInventory::Agent::Task::Inventory::Input::Solaris::Drives;

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

# df --help is on STDERR on some system
# so $line is undef
    return ($line && $line =~ /GNU/) ?
        "df -P -k" :
        "df -k";
}

sub _getFsTypeFromMount {

    my %mountInfo;

    my $handle = getFileHandle(
        command => 'mount -v',
        @_
    );

    while (my $line = <$handle>) {
        next unless $line =~ /^(\S+)\son\s\S+\stype\s(\S+)/;

        $mountInfo{$1} = $2;
    }

    return %mountInfo;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get filesystems list
    my @filesystems =
        # exclude solaris 10 specific devices
        grep { $_->{VOLUMN} !~ /^\/(devices|platform)/ } 
        # exclude cdrom mount
        grep { $_->{TYPE} !~ /cdrom/ } 
        # get all file systems
        getFilesystemsFromDf(logger => $logger, command => _getDfCmd());


    my %fsTypeFromMount = _getFsTypeFromMount();

    # get indexed list of ZFS filesystems
    my %zfs_filesystems =
        map { $_ => 1 }
        map { (split(/\s+/, $_))[0] }
        getAllLines(command => 'zfs list -H');

    # set filesystem type, using fstyp if needed
    foreach my $filesystem (@filesystems) {

        if ($filesystem->{VOLUMN} eq 'swap') {
            $filesystem->{FILESYSTEM} = 'swap';
            next;
        }

        if ($zfs_filesystems{$filesystem->{VOLUMN}}) {
            $filesystem->{FILESYSTEM} = 'zfs';
            next;
        }

        my $type = getFirstLine(command => "fstyp $filesystem->{VOLUMN}");
        if ($type && $type !~ /^fstyp/) {
            $filesystem->{FILESYSTEM} = $type;
        }
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
