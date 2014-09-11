package FusionInventory::Agent::Task::Inventory::Solaris::Drives;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{drive};
    return canRun('df');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get filesystems list
    my $line = getFirstLine(logger => $logger, command => "df --version");
    # df --help is on STDERR on some system, so $line may be undef
    my $command = $line && $line =~ /GNU/ ? "df -P -k" : "df -k";

    my @filesystems =
        # exclude solaris 10 specific devices
        grep { $_->{VOLUMN} !~ /^\/(devices|platform)/ }
        # exclude cdrom mount
        grep { $_->{TYPE} !~ /cdrom/ }
        # get all file systems
        getFilesystemsFromDf(logger => $logger, command => $command);

    # get indexed list of filesystems types
    my %filesystems_types =
        map { /^(\S+) on \S+ type (\w+)/; $1 => $2 }
        getAllLines(logger => $logger, command => '/usr/sbin/mount -v');

    # set filesystem type based on that information
    foreach my $filesystem (@filesystems) {
        if ($filesystem->{VOLUMN} eq 'swap') {
            $filesystem->{FILESYSTEM} = 'swap';
            next;
        }

        $filesystem->{FILESYSTEM} = $filesystems_types{$filesystem->{VOLUMN}};
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
