package FusionInventory::Agent::Task::Inventory::OS::Generic::Users;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('who');
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    my $handle = getFileHandle(
        logger  => $logger,
        command => 'who'
    );

    return unless $handle;

    while (my $line = <$handle>) {
        next unless $line =~ /^(\S+)/;
        $inventory->addUser({ LOGIN => $1 });
    }
    close $handle;

}

1;
