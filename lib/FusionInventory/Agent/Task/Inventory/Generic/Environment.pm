package FusionInventory::Agent::Task::Inventory::Generic::Environment;

use English qw(-no_match_vars);

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    my (%params) = @_;

    return
        # We use WMI for Windows because of charset issue
        $OSNAME ne 'MSWin32' &&
        !$params{no_category}->{environment};
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach my $key (keys %ENV) {
        $inventory->addEntry(
            section => 'ENVS',
            entry   => {
                KEY => $key,
                VAL => $ENV{$key}
            }
        );
    }
}

1;
