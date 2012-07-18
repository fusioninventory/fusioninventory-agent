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

    # get additional informations
    foreach my $filesystem (@filesystems) {

        if ($filesystem->{VOLUMN} eq 'swap') {
            $filesystem->{FILESYSTEM} = 'swap';
            next;
        }

        my $line = getFirstLine(
           command => "zfs get -H creation $filesystem->{VOLUMN}" # i add -H to not have header of zfs command
        );
        if ($line && $line =~ /creation\s+(\S.*\S+)\s*-/) {
            $filesystem->{FILESYSTEM} = 'zfs';
            next;
        }

# i add this to analyse eache line and if ftsyp return error set fs type to undef
        my $line2 = getFirstLine(command => "fstyp $filesystem->{VOLUMN}");
        if ($line2 && $line2 !~ /^fstyp/) {
            $filesystem->{FILESYSTEM} = $line2;
        }

# add filesystems to the inventory
        foreach my $filesystem (@filesystems) {
            $inventory->addEntry(
                    section => 'DRIVES',
                    entry   => $filesystem
                    );
        }
    }
}
1;
