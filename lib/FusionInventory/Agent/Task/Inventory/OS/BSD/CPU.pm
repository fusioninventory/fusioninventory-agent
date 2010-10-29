package FusionInventory::Agent::Task::Inventory::OS::BSD::CPU;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 
        -r "/dev/mem" && # why is this needed ?
        can_run('dmidecode');
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my $hwModel = `sysctl -n hw.model`;
    chomp $hwModel;

    foreach my $cpu (_getCPUsFromDmidecode($logger)) {
        $cpu->{NAME} = $hwModel if !$cpu->{NAME};
        if ($hwModel =~ /([\.\d]+)GHz/) {
            $cpu->{SPEED} = $1 * 1000;
        }
        $inventory->addCPU($cpu);
    }
}

sub _getCPUsFromDmidecode {
    my ($logger, $file) = @_;

    my $infos = getInfosFromDmidecode(logger => $logger, file => $file);

    my @cpus;

    if ($infos->{4}) {
        foreach my $info (@{$infos->{4}}) {
            my $serial = $info->{ID};
            $serial =~ s/\s//g;

            push @cpus, {
                SERIAL       => $serial,
                MANUFACTURER => $info->{'Manufacturer'},
                THREAD       => ($info->{'Thread Count'} || 1),
                SPEED        => getCanonicalSpeed($info->{'Max Speed'}),
                NAME         => $info->{Version} || $info->{Family}
            }
        }
    }

    return @cpus;
}

1;
