package FusionInventory::Agent::Task::Inventory::Virtualization::Xen;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

our $runMeIfTheseChecksFailed = ["FusionInventory::Agent::Task::Inventory::Virtualization::Libvirt"];

sub isEnabled {
    return canRun('xm') ||
           canRun('xl');
}

sub canRunOK {
    my ($cmd) = @_;

    return !system("$cmd >/dev/null 2>&1");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $isXM = canRunOK('xm list');
    my $isXL = canRunOK('xl list');

    my $toolstack = $isXM ? 'xm' :
                    $isXL ? 'xl' : undef;
    my $listParam = $isXM ? '-l' :
                    $isXL ? '-v' : undef;

    $logger->info("Xen $toolstack toolstack detected");

    my $command = "$toolstack list";
    foreach my $machine (_getVirtualMachines(command => $command, logger => $logger)) {
        $machine->{SUBSYSTEM} = $toolstack;
        my $uuid = _getUUID(
            command => "$command $listParam $machine->{NAME}",
            logger  => $logger
        );
        $machine->{UUID} = $uuid;
        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $machine
        );

        $logger->debug("$machine->{NAME}: [$uuid]");
    }
}

sub _getUUID {
    my (%params) = @_;

    return getFirstMatch(
        pattern => qr/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/xi,
        %params
    );
}

sub  _getVirtualMachines {

    my $handle = getFileHandle(@_);

    return unless $handle;

    # xm status
    my %status_list = (
        'r' => 'running',
        'b' => 'blocked',
        'p' => 'paused',
        's' => 'shutdown',
        'c' => 'crashed',
        'd' => 'dying',
    );

    # drop headers
    my $line  = <$handle>;

    my @machines;
    while (my $line = <$handle>) {
        chomp $line;
        my ($name, $vmid, $memory, $vcpu, $status);
        my @fields = split(' ', $line);
        if (@fields == 4) {
                ($name, $memory, $vcpu) = @fields;
                $status = 'off';
        } else {
                ($name, $vmid, $memory, $vcpu, $status) = @fields;
                $status =~ s/-//g;
                $status = $status ? $status_list{$status} : 'off';
               next if $vmid == 0;
        }
        next if $name eq 'Domain-0';

        my $machine = {
            MEMORY    => $memory,
            NAME      => $name,
            STATUS    => $status,
            SUBSYSTEM => 'xm',
            VMTYPE    => 'xen',
            VCPU      => $vcpu,
        };

        push @machines, $machine;

    }
    close $handle;

    return @machines;
}

1;
