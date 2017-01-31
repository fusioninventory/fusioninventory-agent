package FusionInventory::Agent::Task::Inventory::MacOS::Hostname;

use English qw(-no_match_vars);

use strict;
use warnings;

use Sys::Hostname;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    return canRun('/usr/bin/scutil');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    $inventory->setHardware({NAME => _gethostname()});
}

sub _gethostname {

    my $computername = getFirstLine(command => 'scutil --get ComputerName');

    if ($computername eq ""){
        $computername = hostname();
        $computername =~ s/\..*//; # keep just the hostname
    }
    return $computername

}

1;
