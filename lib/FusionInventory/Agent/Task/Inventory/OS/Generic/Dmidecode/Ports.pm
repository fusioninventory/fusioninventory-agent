package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Ports;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    my $ports = getPorts($logger);

    return unless $ports;

    foreach my $port (@$ports) {
        $inventory->addPorts($port);
    }
}

sub getPorts {
    my ($logger, $file) = @_;

    my $infos = getInfosFromDmidecode($logger, $file);

    return unless $infos->{8};

    my $ports;
    foreach my $info (@{$infos->{8}}) {
        my $port = {
            CAPTION     => $info->{'External Connector Type'},
            DESCRIPTION => $info->{'Internal Connector Type'},
            NAME        => $info->{'Internal Reference Designator'},
            TYPE        => $info->{'Port Type'},
        };

        cleanUnknownValues($port);

        push @$ports, $port;
    }

    return $ports;
}

1;
