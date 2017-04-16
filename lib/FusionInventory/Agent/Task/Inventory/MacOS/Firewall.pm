package FusionInventory::Agent::Task::Inventory::MacOS::Firewall;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::Inventory::Generic::Firewall;


sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{firewall};
    return canRun('defaults');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger = $params{logger};

    my $firewallStatus = _getFirewallStatus(
        logger => $logger
    );
    $inventory->addEntry(
        section => 'FIREWALL',
        entry   => {
            STANDARD_STATUS => $firewallStatus
        }
    );

}

sub _getFirewallStatus {
    my (%params) = @_;

    my $status = getFirstMatch(
        command => 'defaults read /Library/Preferences/com.apple.alf globalstate',
        pattern => qr/^(\d)$/,
        %params
    );
    if ($status && $status eq '1') {
        $status = FusionInventory::Agent::Task::Inventory::Generic::Firewall::STATUS_ON;
    } else {
        $status = FusionInventory::Agent::Task::Inventory::Generic::Firewall::STATUS_OFF;
    }

    return $status;
}

1;
