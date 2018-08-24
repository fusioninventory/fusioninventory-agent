package FusionInventory::Agent::Task::Inventory::Generic::Hostname;

use English qw(-no_match_vars);

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use Sys::Hostname;

use Net::Domain qw (hostname hostfqdn hostdomain);

use FusionInventory::Agent::Tools;

sub isEnabled {
    # We use WMI for Windows because of charset issue
    return $OSNAME ne 'MSWin32';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $hostname = hostfqdn();
    #$hostname =~ s/\..*//; # keep just the hostname

    $inventory->setHardware({NAME => $hostname});
}

1;
