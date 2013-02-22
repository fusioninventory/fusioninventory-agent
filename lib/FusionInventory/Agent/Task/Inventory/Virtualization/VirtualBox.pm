package FusionInventory::Agent::Task::Inventory::Virtualization::VirtualBox;

use strict;
use warnings;

use English qw(-no_match_vars);
use User::pwent;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return unless canRun('VBoxManage');

    my ($major, $minor) = getFirstMatch(
        command => 'VBoxManage --version',
        pattern => qr/^(\d)\.(\d)/
    );

    return compareVersion($major, $minor, 2, 1);
}

sub doInventory {
    my (%params) = @_;

    my $inventory    = $params{inventory};
    my $logger       = $params{logger};

    my $command = "VBoxManage -nologo list --long vms";

    foreach my $machine (_parseVBoxManage(
        logger => $logger, command => $command
    )) {
        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $machine
        );
    }

    return unless $params{scan_homedirs} && $REAL_USER_ID == 0;

    # assume all system users with a suitable homedir is an actual human user
    my $pattern = $OSNAME eq 'darwin' ?
        qr{^/Users} : qr{^/home};

    my @users;
    while (my $user = getpwent()) {
        next unless $user->dir() =~ /$pattern/;
        push @users, $user->name();
    }

    # abort if too many users
    return if @users > 10;

    foreach my $user (@users) {
        my $command = "su '$user' -c 'VBoxManage -nologo list --long vms'";
        foreach my $machine (_parseVBoxManage(
            logger => $logger, command => $command
        )) {
            $machine->{OWNER} = $user;
            $inventory->addEntry(
                section => 'VIRTUALMACHINES', entry => $machine
            );
        }
    }
}

sub _parseVBoxManage {
    my $handle = getFileHandle(@_);

    return unless $handle;

    my (@machines, $machine, $index);

    my %status_list = (
        'powered off' => 'off',
        'saved'   => 'off',
        'teleported'   => 'off',
        'aborted'    => 'crashed',
        'stuck' => 'blocked',
        'teleporting'   => 'paused',
        'live snapshotting'     => 'running',
        'starting'   => 'running',
        'stopping' => 'dying',
        'saving' => 'dying',
        'restoring' => 'running',
        'running' => 'running',
        'paused' => 'paused'
    );
    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ m/^Name:\s+(.*)$/) {
            # this is a little tricky, because USB devices also have a 'name'
            # field, so let's use the 'index' field to disambiguate
            if (defined $index) {
                $index = undef;
                next;
            }
            push @machines, $machine if $machine;
            $machine = {
                NAME      => $1,
                VCPU      => 1,
                SUBSYSTEM => 'Oracle VM VirtualBox',
                VMTYPE    => 'VirtualBox'
            };
        } elsif ($line =~ m/^UUID:\s+(.+)/) {
            $machine->{UUID} = $1;
        } elsif ($line =~ m/^Memory size:\s+(.+)/ ) {
            $machine->{MEMORY} = $1;
        } elsif ($line =~ m/^State:\s+(.+) \(/) {
            $machine->{STATUS} = $status_list{$1};
        } elsif ($line =~ m/^Index:\s+(\d+)$/) {
            $index = $1;
        }
    }
    close $handle;

    # push last remaining machine
    push @machines, $machine if $machine;

    return @machines;
}

1;
