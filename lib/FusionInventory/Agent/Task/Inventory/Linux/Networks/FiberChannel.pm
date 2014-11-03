package FusionInventory::Agent::Task::Inventory::Linux::Networks::FiberChannel;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('systool');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @interfaces = _getInterfacesFromFcHost(logger => $logger);

    foreach my $interface (@interfaces) {
        $inventory->addEntry(
            section => 'NETWORKS',
            entry   => $interface
        );
    }
}

sub _getInterfacesFromFcHost {
    my $handle = getFileHandle(command => 'systool -c fc_host -v');
    return unless $handle;

    my @interfaces;
    my $interface;

    while (my $line = <$handle>) {
        if ($line =~ /Class Device = "(.+)"/) {
            $interface = {
                DESCRIPTION => $1,
                TYPE        => 'ethernet'
            };
        } elsif ($line =~ /port_name\s+= "0x(\w+)"/) {
            $interface->{'MACADDR'} = join(':', unpack '(A2)*', $1);
        } elsif ($line =~ /port_state\s+= "(\w+)"/) {
            if ($1 eq 'Online') {
                $interface->{'STATUS'} = 'Up';
            } elsif ($1 eq 'Linkdown') {
                $interface->{'STATUS'} = 'Down';
            }
        } elsif ($line =~ /speed\s+= "(.+)"/) {
            $interface->{'SPEED'} = $1 if ($1 ne 'unknown');

            push @interfaces, $interface;
        }
    }

    return @interfaces;
}

1;
