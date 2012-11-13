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

    foreach my $user (_getLocalUsers(logger => $logger)) {
        $inventory->addEntry(
            section => 'LOCALUSERS',
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
    my %groups = _getLocalGroups(logger => $params{logger});

    while (my $line = <$handle>) {
        next if $line =~ /^#/;
        my ($login, undef, $uid, $gid, $gecos, $home, $shell) =
            split(/:/, $line);
        # assume users with lower uid are system users
        next if $uid < 500;
        next if $login eq 'nobody';

        my @groups = scalar getgrgid($gid); # primary group
        push @groups, @{$groups{$login}} if $groups{$login};

        push @users, {
            LOGIN => $login,
            ID    => $uid,
            GROUP => \@groups,
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

    my %groups;

    while (my $line = <$handle>) {
        next if $line =~ /^#/;
        chomp $line;
        my ($group, undef, undef, $members) = split(/:/, $line);
        my @members = split(/,/, $members);
        foreach my $member (@members) {
            push @{$groups{$member}}, $group;
        }
    }
    close $handle;

    return %groups;
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
