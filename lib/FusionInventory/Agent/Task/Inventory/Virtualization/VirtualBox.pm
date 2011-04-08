package FusionInventory::Agent::Task::Inventory::Virtualization::VirtualBox;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
#use FusionInventory::Agent::Tools::Unix;

use File::Glob ':glob';

use English qw(-no_match_vars);
use File::Basename;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    return unless can_run('VBoxManage');
    my ( $version ) = ( `VBoxManage --version` =~ m/^(\d\.\d).*$/ ) ;
    return unless $version > 2.1;
    1;
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
            if ($machine) {
                $machine->{VCPU}      = 1;
                $machine->{SUBSYSTEM} = 'Oracle VM VirtualBox';
                $machine->{VMTYPE}    = 'VirtualBox';
                push @machines, $machine;
            }
            $machine = {
                NAME => $1
            }
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
    if ($machine) {
        $machine->{VCPU}      = 1;
        $machine->{SUBSYSTEM} = 'Oracle VM VirtualBox';
        $machine->{VMTYPE}    = 'VirtualBox';
        push @machines, $machine;
    }

    return @machines;
}


sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};
    my $scanhomedirs = $params->{config}{'scan-homedirs'};

    my $cmd_list_vms = "VBoxManage -nologo list --long vms";

    my $owner;
    if ( $REAL_USER_ID != 0 ) {
        $owner = getpwuid $REAL_USER_ID;
    }

    foreach my $machine (_parseVBoxManage(logger => $logger, command => $cmd_list_vms)) {
        $machine->{OWNER} = $owner;
        $inventory->addVirtualMachine ($machine);
    }


# If home directories scan is authorized
    if ($scanhomedirs == 1 && $REAL_USER_ID == 0) {
        my $homeDir = "/home";

        if ($OSNAME =~ /^DARWIN$/i) {
            $homeDir = "/Users";
        }
        my @homeDirlist = glob("$homeDir/*");
        return if @homeDirlist > 10; # To many users, ignored.
        foreach (@homeDirlist) {
            my $login = basename($_);
            next unless getpwnam ($login); # Invalid account
                my $cmd_list_vms = "su \"$login\" -c \"VBoxManage -nologo list --long vms\"";
            foreach my $machine (_parseVBoxManage(logger => $logger, command => $cmd_list_vms)) {
                $machine->{OWNER} = $login;
                $inventory->addVirtualMachine ($machine);
            }

        }
    }
}

1;
