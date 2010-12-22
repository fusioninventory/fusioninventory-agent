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

    my $name;
    my $version;
    my $comments;
    my $publisher;
    foreach (`pkginfo -l`) {
        if (/^\s*$/) {
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

        } elsif (/PKGINST:\s+(.+)/) {
            $name = $1;
        } elsif (/VERSION:\s+(.+)/) {
            $version = $1;
        } elsif (/VENDOR:\s+(.+)/) {
            $publisher = $1;
        } elsif (/DESC:\s+(.+)/) {
            $comments = $1;
        }
    }


}



1;
