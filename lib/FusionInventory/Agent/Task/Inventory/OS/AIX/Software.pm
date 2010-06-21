package FusionInventory::Agent::Task::Inventory::OS::AIX::Software;

use strict;
use warnings;

sub isInventoryEnabled {
    my $params = shift;

    # Do not run an package inventory if there is the --nosoft parameter
    return if ($params->{config}->{nosoft});

    return unless can_run("lslpp");
    1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my @list;
    my $buff;
    foreach (`lslpp -c -l`) {
        my @entry = split /:/,$_;
        next unless (@entry);
        next unless ($entry[1]);
        next if $entry[1] =~ /^device/;

        $inventory->addSoftware({
            'COMMENTS'      => $entry[6],
            'FOLDER'	=> $entry[0],
            'NAME'          => $entry[1],
            'VERSION'       => $entry[2],
        });
    }
}

1;
