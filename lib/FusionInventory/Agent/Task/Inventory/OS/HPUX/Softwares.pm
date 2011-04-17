package FusionInventory::Agent::Task::Inventory::OS::HPUX::Softwares;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled  {
    my (%params) = @_;

    return
        !$params{config}->{no_software} &&
        can_run('swlist');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(
        command => 'swlist',
        logger => $logger
    );
    return unless $handle;

    while (my $line = <$handle>) {
        next if $line =~ /^#/;
        next if $line =~ /^  PH/;
        $line =~ tr/\t/ /s;
        $line =~ tr/ //s;
        chomp $line;

        if ($line =~ /^ (\S+)\s(\S+)\s(.+)/ ) {
            $inventory->addEntry({
                section => 'SOFTWARES',
                entry   => {
                    NAME      => $1,
                    VERSION   => $2,
                    COMMENTS  => $3,
                    PUBLISHER => 'HP'
                }
            });
        }
    }

    close $handle;

}

1;
