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

    my @users = _getLoggedUsers(logger => $logger);

    foreach my $user (@users) {
        # avoid duplicates
        next if $seen->{$user->{LOGIN}}++;

        $inventory->addEntry(
            section => 'USERS',
            entry   => $user
        );
    }

    my $last = _getLastUser(logger => $logger);
    $inventory->setHardware($last);
}

sub _getLoggedUsers {
    my (%params) = (
        command => 'who',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @users;

    while (my $line = <$handle>) {
        next unless $line =~ /^(\S+)/;
        push @users, { LOGIN => $1 };
    }

    return @users;
}

sub _getLasUser {
    my (%params) = (
        command => 'last',
        @_
    );

    my $last = getFirstLine(%params);
    return unless $last;
    return unless
        $last =~ /^(\S+) \s+ \S+ \s+ \S+ \s+ (\S+ \s+ \S+ \s+ \S+ \s+ \S+)/x;

    return {
        LASTLOGGEDUSER     => $1,
        DATELASTLOGGEDUSER => $2
    };
}

1;
