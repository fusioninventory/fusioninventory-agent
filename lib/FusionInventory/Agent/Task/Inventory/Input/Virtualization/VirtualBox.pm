package FusionInventory::Agent::Task::Inventory::Input::Virtualization::VirtualBox;

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
    my $scanhomedirs = $params{scan_homedirs};

    my $command = "VBoxManage -nologo list --long vms";

    foreach my $machine (_parseVBoxManage(
        logger => $logger, command => $command
    )) {
        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $machine
        );
    }

    return unless $scanhomedirs == 1 && $REAL_USER_ID == 0;

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
            $machine->{STATUS} = $1 eq 'powered off' ? 'off' : $1;
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
