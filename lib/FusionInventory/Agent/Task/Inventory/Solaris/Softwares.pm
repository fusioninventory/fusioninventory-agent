package FusionInventory::Agent::Task::Inventory::Solaris::Softwares;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    my (%params) = @_;

    return
        !$params{no_category}->{software} &&
        canRun('pkginfo');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(
        command => 'pkginfo -l',
        logger  => $logger,
    );

    return unless $handle;

    my $software;
    while (my $line = <$handle>) {
        if ($line =~ /^\s*$/) {
            $inventory->addEntry(
                section => 'SOFTWARES',
                entry   =>  $software
            );
            undef $software;
        } elsif ($line =~ /PKGINST:\s+(.+)/) {
            $software->{NAME} = $1;
        } elsif ($line =~ /VERSION:\s+(.+)/) {
            $software->{VERSION} = $1;
        } elsif ($line =~ /VENDOR:\s+(.+)/) {
            $software->{PUBLISHER} = $1;
        } elsif ($line =~  /DESC:\s+(.+)/) {
            $software->{COMMENTS} = $1;
        }
    }

    close $handle;
}

1;
