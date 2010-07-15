package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Ports;

use strict;
use warnings;

use English qw(-no_match_vars);

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my ($ports) = parseDmidecode('/usr/sbin/dmidecode', '-|');

    foreach my $port (@$ports) {
        $inventory->addPorts($port);
    }
}

sub parseDmidecode {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my ($ports, $port, $type);

     while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /DMI type (\d+)/) {
            $type = $1;
            if ($port) {
                push @$ports, $port;
                undef $port;
            }
            next;
        }

        next unless defined $type;

        if ($type == 8) {
            if ($line =~ /^\s+External Connector Type: (.*\S)/) {
                $port->{CAPTION} = $1;
            } elsif ($line =~ /^\s+Internal Connector Type: (.*\S)/) {
                $port->{DESCRIPTION} = $1;
            } elsif ($line =~ /^\s+Internal Reference Designator: (.*\S)/) {
                $port->{NAME} = $1;
            } elsif ($line =~ /^\s+Port Type: (.*\S)/) {
                $port->{TYPE} = $1;
            }
        }
    }
    close $handle;

    return $ports;
}

1;
