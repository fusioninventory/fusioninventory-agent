package FusionInventory::Agent::Task::Inventory::Input::Virtualization::VirtualBox;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Basename;
use File::Glob qw(:glob);

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

    my $owner = getpwuid $REAL_USER_ID;

    foreach my $machine (_parseVBoxManage(
        logger => $logger, command => $command
    )) {
        $machine->{OWNER} = $owner;
        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $machine
        );
    }

    return unless $scanhomedirs == 1 && $REAL_USER_ID == 0;

    my $homeDir = $OSNAME eq 'darwin' ?
        "/Users" : "/home";

    my @homeDirs = glob("$homeDir/*");
    return if @homeDirs > 10; # Too many users, ignored.
    foreach my $homeDir (@homeDirs) {
        my $login = basename($homeDir);
        next unless getpwnam ($login); # Invalid account
        my $command = "su '$login' -c 'VBoxManage -nologo list --long vms'";
        foreach my $machine (_parseVBoxManage(
            logger => $logger, command => $command
        )) {
            $machine->{OWNER} = $login;
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
