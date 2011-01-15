package FusionInventory::Agent::Task::Inventory::Virtualization::VirtualBox;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Glob ':glob';
use XML::TreePP;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return
        can_run('VBoxManage');
}

sub doInventory {
    my (%params) = @_;

    my $inventory    = $params{inventory};
    my $logger       = $params{logger};
    my $scanhomedirs = $params{scan_homedirs};

    my $version = getFirstMatch(
        command => 'VBoxManage --version',
        pattern =>  qr/^(\d\.\d)/
    );
    my $command = $version > 2.1 ?
        "VBoxManage -nologo list --long vms" : "VBoxManage -nologo list vms";

    foreach my $machine (_parseVBoxManage(logger => $logger, command => $command)) {
        $inventory->addVirtualMachine ($machine);
    }

    # try to identify machines running under other uid
    my %runningMachines;
    my $pscommand = $OSNAME eq 'solaris' ?
        'ps -A -o user,pid,pcpu,pmem,vsz,rss,tty,s,stime,time,comm' : 'ps aux';

    foreach my $process (getProcessesFromPs(
        logger => $logger, command => $command
    )) {
        next if $process->{USER} eq 'root'|| $process->{USER} == 0;
        next unless $process->{CMD} =~ /VirtualBox (.*)/;
        my @options = split(/\s+/, $1);
        my ($name, $uuid);
        foreach my $option (@options) {
            if ($option eq '--comment') {
                $name = shift @options;
            } elsif ($option eq '--startvm') {
                $uuid = shift @options;
            }
        }

        if ($scanhomedirs == 1) {
            # the machine will get inventoried later, just
            # register its running state
            $runningMachines{$uuid} = 1;
        } else {
            # add it to the inventory immediatly
            $inventory->addVirtualMachine({
                NAME      => $name,
                VCPU      => 1,
                UUID      => $uuid,
                STATUS    => "running",
                SUBSYSTEM => "Sun xVM VirtualBox",
                VMTYPE    => "VirtualBox",
            });
        }
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
