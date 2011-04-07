package FusionInventory::Agent::Task::Inventory::OS::AIX::Softwares;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    my ($params) = @_;

    return
        !$params->{config}->{no_software} &&
        can_run('lslpp');
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    my @list;
    my $buff;
    foreach (`lslpp -c -l`) {
        my @entry = split /:/,$_;
        next unless (@entry);
        next unless ($entry[1]);
        next if $entry[1] =~ /^device/;

        $inventory->addSoftware({
            COMMENTS => $entry[6],
            FOLDER   => $entry[0],
            NAME     => $entry[1],
            VERSION  => $entry[2],
        });
    }
}

1;
