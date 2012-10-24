package FusionInventory::Agent::Task::Inventory::Input::Generic::Users;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return 
        canRun('who')  ||
        canRun('last') ||
        canRead('/etc/passwd');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @users = _getLocalUsers(logger => $logger);

    foreach my $user (@users) {
        $inventory->addEntry(
            section => 'USERS',
            entry   => $user
        );
    }

    my $last = _getLastUser(logger => $logger);
    $inventory->setHardware($last);
}

sub _getLocalUsers {
    my (%params) = (
        file => '/etc/passwd',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @users;

    while (my $line = <$handle>) {
        next if $line =~ /^#/;
        my ($login, undef, $uid, $gid, $gecos, $home, $shell) =
            split(/:/, $line);
        # assume users with lower uid are system users
        next if $uid < 500;
        next if $login eq 'nobody';
        push @users, {
            LOGIN => $login,
            UID   => $uid,
            GID   => $gid,
            NAME  => $gecos,
            HOME  => $home,
            SHELL => $shell
        };
    }
    close $handle;

    return @users;
}

sub _getLastUser {
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
