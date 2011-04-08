# UNMERGED YET
package FusionInventory::Agent::Task::Inventory::Virtualization::VirtualBox;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Glob qw(:glob);
use XML::TreePP;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

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
    my ($params) = @_;

    my $inventory    = $params->{inventory};
    my $logger       = $params->{logger};
    my $scanhomedirs = $params->{config}->{'scan-homedirs'};

    my $version = getFirstMatch(
        command => 'VBoxManage --version',
        pattern =>  qr/^(\d\.\d)/
    );
    my $command = $version > 2.1 ?
        "VBoxManage -nologo list --long vms" : "VBoxManage -nologo list vms";

    foreach my $machine (_parseVBoxManage(logger => $logger, command => $command)) {
        $inventory->addVirtualMachine ($machine);
    }

    return unless $scanhomedirs;

    my $homeDir = $OSNAME eq 'darwin' ? '/Users' : '/home';

    # Read every Machines Xml File of every user
    foreach my $file (bsd_glob("$homeDir/*/.VirtualBox/Machines/*/*.xml")) {
        # Open config file ...
        my $tpp = XML::TreePP->new();
        my $data = $tpp->parse($file);
          
        # ... and read it
        if ($data->{Machine}->{uuid}) {
            my $uuid = $data->{Machine}->{uuid};
            $uuid =~ s/^{?(.{36})}?$/$1/;

            $inventory->addVirtualMachine ({
                NAME      => $data->{Machine}->{name},
                VCPU      => $data->{Machine}->{Hardware}->{CPU}->{count},
                UUID      => $uuid,
                MEMORY    => $data->{Machine}->{Hardware}->{Memory}->{RAMSize},
#                STATUS    => $status,
                SUBSYSTEM => "Sun xVM VirtualBox",
                VMTYPE    => "VirtualBox",
            });
        }
    }



    foreach my $file (bsd_glob("$homeDir/*/.VirtualBox/VirtualBox.xml")) {
        # Open config file ...
        my $tpp = XML::TreePP->new();
        my $data = $tpp->parse($file);
        
        # ... and read it
        my $defaultMachineFolder =
            $data->{Global}->{SystemProperties}->{defaultMachineFolder};
        if (
            $defaultMachineFolder != 0 and
            $defaultMachineFolder != "Machines" and
            $defaultMachineFolder =~ /^\$homeDir\/S+\/.VirtualBox\/Machines$/
        ) {
          
            foreach my $file (bsd_glob($defaultMachineFolder."/*/*.xml")) {
                my $tpp = XML::TreePP->new();
                my $data = $tpp->parse($file);
            
                if ($data->{Machine} != 0 and $data->{Machine}->{uuid} != 0 ) {
                    my $uuid = $data->{Machine}->{uuid};
                    $uuid =~ s/^{?(.{36})}?$/$1/;
                    my $status = $runningMachines{$uuid} ? 'running' : 'off';

                    $inventory->addVirtualMachine ({
                        NAME      => $data->{Machine}->{name},
                        VCPU      => $data->{Machine}->{Hardware}->{CPU}->{count},
                        UUID      => $uuid,
                        MEMORY    => $data->{Machine}->{Hardware}->{Memory}->{RAMSize},
                        STATUS    => $status,
                        SUBSYSTEM => "Sun xVM VirtualBox",
                        VMTYPE    => "VirtualBox",
                    });
                }
            }
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
            if ($machine) {
                $machine->{VCPU}      = 1;
                $machine->{SUBSYSTEM} = 'Sun xVM VirtualBox';
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
=======
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

>>>>>>> 2.1.x
        }
    }
    close $handle;

    # push last remaining machine
    if ($machine) {
        $machine->{VCPU}      = 1;
        $machine->{SUBSYSTEM} = 'Sun xVM VirtualBox';
        $machine->{VMTYPE}    = 'VirtualBox';
        push @machines, $machine;
    }

    return @machines;
}

1;
