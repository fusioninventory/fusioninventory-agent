package FusionInventory::Agent::Task::Inventory::Generic::Firewall::Fedora;

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::Generic::Firewall;
use FusionInventory::Agent::Tools;

our $runMeIfTheseChecksFailed = ["FusionInventory::Agent::Task::Inventory::Generic::Firewall::Ubuntu"];

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{firewall};
    return
        # Ubuntu
        canRun('systemctl');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

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
        command => 'systemctl status firewalld.service',
        pattern => qr/^\s*Loaded: loaded [^;]+firewalld[^;]*; ([^;]+);/,
        %params
    );
    if ($status && $status eq 'enabled') {
        $status = FusionInventory::Agent::Task::Inventory::Generic::Firewall::STATUS_ON;
    } else {
        $status = FusionInventory::Agent::Task::Inventory::Generic::Firewall::STATUS_OFF;
    }

    return $status;
}

1;
