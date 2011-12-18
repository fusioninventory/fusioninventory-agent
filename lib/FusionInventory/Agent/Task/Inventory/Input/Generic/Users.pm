package FusionInventory::Agent::Task::Inventory::Input::Generic::Users;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

my $seen;

sub isEnabled {
    return 
        canRun('who') ||
        canRun('last');
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
            my $user = { LOGIN => $1 };

            # avoid duplicates
            next if $seen->{$user->{LOGIN}}++;

            $inventory->addEntry(
                section => 'USERS',
                entry   => $user
            );
        }
        close $handle;
    }

    my ($lastUser, $lastDate);
    my $last = getFirstLine(command => 'last');
    if ($last &&
        $last =~ /^(\S+) \s+ \S+ \s+ \S+ \s+ (\S+ \s+ \S+ \s+ \S+ \s+ \S+)/x
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
