package FusionInventory::Agent::Task::Inventory::OS::Generic::Users;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 
        can_run('who') ||
        can_run('last');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(
        logger  => $logger,
        command => 'who'
    );

    if ($handle) {
        while (my $line = <$handle>) {
            next unless $line =~ /^(\S+)/;
            $inventory->addUser({ LOGIN => $1 });
        }
        close $handle;
    }

    my ($lastUser, $lastDate);
    my $last = getFirstLine(command => 'last -R');
    if ($last &&
        $last =~ /^(\S+) \s+ \S+ \s+ (\S+ \s+ \S+ \s+ \S+ \s+ \S+)/x
    ) {
        $lastUser = $1;
        $lastDate = $2;
    }

    $inventory->setHardware({
        LASTLOGGEDUSER     => $lastUser,
        DATELASTLOGGEDUSER => $lastDate
    });

}

1;
