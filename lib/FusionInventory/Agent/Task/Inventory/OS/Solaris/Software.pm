package FusionInventory::Agent::Task::Inventory::OS::Solaris::Software;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    my (%params) = @_;

    return 
        !$params{no_software} &&
        can_run('pkginfo');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger = $params{logger};

    my $handle = getFileHandle(
        command => 'pkginfo -l',
        logger  => $logger,
    );

    return unless $handle;

    my $name;
    my $version;
    my $comments;
    my $publisher;

    while (my $line = <$handle>) {
        if ($line =~ /^\s*$/) {
            $inventory->addSoftware({
                NAME      => $name,
                VERSION   => $version,
                COMMENTS  => $comments,
                PUBLISHER => $publisher,
            });

            $name = '';
            $version = '';
            $comments = '';
            $publisher = '';

        } elsif ($line =~ /PKGINST:\s+(.+)/) {
            $name = $1;
        } elsif ($line =~ /VERSION:\s+(.+)/) {
            $version = $1;
        } elsif ($line =~ /VENDOR:\s+(.+)/) {
            $publisher = $1;
        } elsif ($line =~  /DESC:\s+(.+)/) {
            $comments = $1;
        }
    }

    close $handle;
}

1;
