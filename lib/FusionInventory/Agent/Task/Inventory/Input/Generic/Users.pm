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

    my %users;

    if (!$params{no_category}->{local_user}) {
        foreach my $user (_getLocalUsers(logger => $logger)) {
            # record user -> primary group relationship
            push @{$users{$user->{gid}}}, $user->{LOGIN};
            delete $user->{gid};

            $inventory->addEntry(
                section => 'LOCAL_USERS',
                entry   => $user
            );
        }
    }

    if (!$params{no_category}->{local_group}) {
        foreach my $group (_getLocalGroups(logger => $logger)) {
            # add users having this group as primary group, if any
            push @{$group->{MEMBER}}, @{$users{$group->{ID}}}
                if $users{$group->{ID}};

            $inventory->addEntry(
                section => 'LOCAL_GROUPS',
                entry   => $group
            );
        }
    }

    foreach my $user (_getLoggedUsers(logger => $logger)) {
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

        push @users, {
            LOGIN => $login,
            ID    => $uid,
            gid   => $gid,
            NAME  => $gecos,
            HOME  => $home,
            SHELL => $shell
        };
    }
    close $handle;

    return @users;
}

sub _getLocalGroups {
    my (%params) = (
        file => '/etc/group',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @groups;

    while (my $line = <$handle>) {
        next if $line =~ /^#/;
        chomp $line;
        my ($name, undef, $gid, $members) = split(/:/, $line);

        my @members = split(/,/, $members);

        push @groups, {
            ID     => $gid,
            NAME   => $name,
            MEMBER => \@members,
        };
    }
    close $handle;

    return @groups;
}

sub _getLoggedUsers {
    my (%params) = (
        command => 'who',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @users;
    my $seen;

    while (my $line = <$handle>) {
        next unless $line =~ /^(\S+)/;
        next if $seen->{$1}++;
        push @users, { LOGIN => $1 };
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
