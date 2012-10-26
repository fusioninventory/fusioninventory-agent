package FusionInventory::Agent::Task::Inventory::Input::Generic::LocalGroups;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return
        canRead('/etc/group');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @groups = _getLocalGroups(logger => $logger);

    foreach my $group (@groups) {
        $inventory->addEntry(
            section => 'LOCALGROUPS',
            entry   => $group
        );
    }

}


sub _getLocalGroups {
    my (%params) = (
        file => '/etc/group',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @groups;

    while (my $line = <$handle>) {
        next if $line =~ /^#/;
        chomp $line;
        my ($name, undef, $id, $members) = split(/:/, $line);
        my  @members = split(/,/, $members);
        if ($members) {
            push @groups, {
                NAME   => $name,
                ID     => $id,
                MEMBER => \@members
            };
        } else {
            push @groups, {
                NAME   => $name,
                ID     => $id
            };
        }
    }
    close $handle;

    return @groups;
}

1;
