package FusionInventory::Agent::Task::Inventory::OS::HPUX::Software;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled  {
    my $params = shift;

    # Do not run an package inventory if there is the --nosoft parameter
    return if $params->{params}->{nosoft};

    return can_run('swlist');
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $command = 'swlist';

    my $handle;
    if (!open $handle, '-|', $command) {
        warn "Can't run $command: $ERRNO";
        return;
    }

    while (my $line = <$handle>) {
        next if $line =~ /^#/;
        next if $line =~ /^  PH/;
        $line =~ tr/\t/ /s;
        $line =~ tr/ //s;
        chomp $line;

        if ($line =~ /^ (\S+)\s(\S+)\s(.+)/ ) {
            $inventory->addSoftware({
                NAME      => $1,
                VERSION   => $2,
                COMMENTS  => $3,
                PUBLISHER => 'HP'
            });
        }
    }

    close $handle;

}

1;
