package FusionInventory::Agent::Task::Inventory::Linux::AntiVirus::Armadito;

use strict;
use warnings;
use FusionInventory::Agent::HTTP::Client::ArmaditoAV;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{antivirus};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $logger = $params{logger};
    my $inventory = $params{inventory};

    my $version = "unknown";
    my $status = "0";

    if(_isArmaditoAvUp()) {
        $version = _getAntivirusVersion();
        $status = _getAntivirusStatus();

        my $antivirus = {
             COMPANY  => "Teclib",
             NAME     => "Armadito",
        #    GUID     => $object->{instanceGuid},
             VERSION  => $version,
        #    ENABLED  => $object->{onAccessScanningEnabled},
             UPTODATE => _isUpToDate($status)
        };

        $inventory->addEntry(
            section => 'ANTIVIRUS',
            entry   => $antivirus
        );
    }
}

sub _isArmaditoAvUp {
    my (%params) = @_;

    my $av_client = FusionInventory::Agent::HTTP::Client::ArmaditoAV->new();
    my $response = $av_client->sendRequest(
        url    => "/api/version",
        method => "GET"
    );

    return $response->is_success();
}

sub _isUpToDate {
    my ($status) = @_;
    return $status eq "up-to-date" ? 1 : 0;
}

sub _getAntivirusStatus {
    my (%params) = @_;

    my $av_client = FusionInventory::Agent::HTTP::Client::ArmaditoAV->new();
    $av_client->register();

    my $response = $av_client->sendRequest(
        url    => "/api/status",
        method => "GET"
    );

    return "unknown"
    if ( !$response->is_success() );

    my $status_event = $av_client->pollEvents();
    $av_client->unregister();

    return $status_event->{jobj}->{global_status};
}

sub _getAntivirusVersion {
    my (%params) = @_;

    my $av_client = FusionInventory::Agent::HTTP::Client::ArmaditoAV->new();
    my $jobj = $av_client->getAntivirusVersion();

    return defined($jobj->{"antivirus-version"}) ? $jobj->{"antivirus-version"} : "unknown";
}
1;
