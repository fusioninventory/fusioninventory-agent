package FusionInventory::Agent::Task::Inventory::OS::BSD::Drives;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run("df");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $drives = _parseDf("df -P -T -t ffs,ufs -k 2>&1", '-|');
    foreach my $drive (@$drives) {
        $inventory->addDrive($drive);
    }
}

sub _parseDf {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my $drives;

    # drop headers line
    my $line = <$handle>;
    while (my $line = <$handle>) {
        next unless $line =~ /^
            (\S+) \s+ # nme
            (\S+) \s+ # type
            (\S+) \s+ # size
             \S+  \s+ # used
            (\S+) \s+ # available
             \S+  \s+ # capacity
            (\S+)     # mount point
            $/x;

        push @$drives, {
            FREE       => sprintf("%i", $4 / 1024),
            FILESYSTEM => $2,
            TOTAL      => sprintf("%i", $3 / 1024),
            TYPE       => $5,
            VOLUMN     => $1
        };
    }
    close $handle;

    return $drives;
}

1;
