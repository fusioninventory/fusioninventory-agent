package FusionInventory::Agent::Task::ESX;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use FusionInventory::Agent;
use FusionInventory::Agent::Recipient::Server;
use FusionInventory::Agent::HTTP::Client::Fusion;
use FusionInventory::Agent::Inventory;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Message::Outbound;
use FusionInventory::Agent::SOAP::VMware;

our $VERSION = $FusionInventory::Agent::VERSION;

sub getConfiguration {
    my ($self, %params) = @_;

    my $response = $params{response};
    if (!$response) {
        $self->{logger}->debug("Task not compatible with a local controller");
        return;
    }

    my $client = FusionInventory::Agent::HTTP::Client::Fusion->new(
        logger       => $self->{logger},
        user         => $params{user},
        password     => $params{password},
        proxy        => $params{proxy},
        ca_cert_file => $params{ca_cert_file},
        ca_cert_dir  => $params{ca_cert_dir},
        no_ssl_check => $params{no_ssl_check},
    );

    my $remoteConfig = $client->send(
        url  => $params{controller}->getUrl(),
        args => {
            action    => "getConfig",
            machineid => $params{deviceid},
            task      => { ESX => $VERSION },
        }
    );

    my $schedule = $remoteConfig->{schedule};
    return unless $schedule;
    return unless ref $schedule eq 'ARRAY';

    my @remotes =
        grep { $_ }
        map  { $_->{remote} }
        grep { $_->{task} eq "ESX" }
        @{$schedule};

    if (!@remotes) {
        $self->{logger}->debug("Task not scheduled");
        return;
    }

    my $jobs = $client->send(
        url  => $remotes[-1],
        args => {
            action    => "getJobs",
            machineid => $params{deviceid}
        }
    );

    if (!$jobs) {
        $self->{logger}->error("No host in the server request");
        return;
    }

    if (ref $jobs->{jobs} ne 'ARRAY') {
        $self->{logger}->error("Invalid server request format");
        return;
    }

    return (
        url  => $remotes[-1],
        jobs => $jobs->{jobs}
    );
}

sub run {
    my ($self, %params) = @_;

    $self->{logger}->info("Running ESX task");

    my @jobs = @{$self->{config}->{jobs}};
    if (!@jobs) {
        $self->{logger}->error("no VMware host(s) given, aborting");
        return;
    }
    $self->{logger}->debug(
        "got " . scalar @jobs . " VMware host(s) to inventory"
    );

    my $recipient =
        $params{recipient} ||
        FusionInventory::Agent::Recipient::Stdout->new();

    foreach my $job (@jobs) {

        if ( !$self->_connect(
                host     => $job->{host},
                user     => $job->{user},
                password => $job->{password}
        )) {
            $recipient->send(
                url      => $self->{config}->{url},
                filename => sprintf('esx_%s_ko.js', $job->{uuid}),
                control  => 1,
                message  => {
                    action    => 'setLog',
                    machineid => $self->{config}->{deviceid},
                    part      => 'login',
                    uuid      => $job->{uuid},
                    msg       => $self->{lastError},
                    code      => 'ko'
                }
            );

            next;
        }

        my $hostIds = $self->_getHostIds();
        foreach my $hostId (@$hostIds) {
            my $inventory = $self->_createInventory(
                $hostId, $self->{config}->{tag}
            );

            my $message = FusionInventory::Agent::Message::Outbound->new(
                query      => 'INVENTORY',
                deviceid   => $self->{config}->{deviceid},
                stylesheet => $self->{config}->{datadir} . '/inventory.xsl',
                content    => $inventory->getContent()
            );

            $recipient->send(message => $message);
        }
        $recipient->send(
            url      => $self->{config}->{url},
            filename => sprintf('esx_%s_ok.js', $job->{uuid}),
            control  => 1,
            message  => {
                action    => 'setLog',
                machineid => $self->{config}->{deviceid},
                uuid      => $job->{uuid},
                code      => 'ok'
            }
        );
    }

}

sub _connect {
    my ($self, %params) = @_;

    my $url = 'https://' . $params{host} . '/sdk/vimService';

    my $vpbs =
        FusionInventory::Agent::SOAP::VMware->new(url => $url, vcenter => 1 );
    if ( !$vpbs->connect( $params{user}, $params{password} ) ) {
        $self->{lastError} = $vpbs->{lastError};
        return;
    }

    $self->{vpbs} = $vpbs;
}

sub _createFakeDeviceid {
    my ($self, $host) = @_;

    my $hostname = $host->getHostname();
    my $bootTime = $host->getBootTime();
    my ( $year, $month, $day, $hour, $min, $sec );
    if ( $bootTime =~
        /(\d{4})-(\d{1,2})-(\d{1,2})T(\d{1,2}):(\d{1,2}):(\d{1,2})/
    ) {
        $year  = $1;
        $month = $2;
        $day   = $3;
        $hour  = $4;
        $min   = $5;
        $sec   = $6;
    } else {
        my $ty;
        my $tm;
        ( $ty, $tm, $day, $hour, $min, $sec ) =
          ( localtime(time) )[ 5, 4, 3, 2, 1, 0 ];
        $year  = $ty + 1900;
        $month = $tm + 1;
    }
    my $deviceid = sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
      $hostname, $year, $month, $day, $hour, $min, $sec;

    return $deviceid;
}

sub _createInventory {
    my ($self, $id, $tag) = @_;

    die unless $self->{vpbs};

    my $vpbs = $self->{vpbs};

    my $host;
    $host = $vpbs->getHostFullInfo($id);

    my $inventory = FusionInventory::Agent::Inventory->new(
        logger => $self->{logger},
        tag    => $tag
    );
    $inventory->{deviceid} = $self->_createFakeDeviceid($host);

    $inventory->{isInitialised} = 1;
    $inventory->{h}{CONTENT}{HARDWARE}{ARCHNAME} = ['remote'];

    $inventory->setBios( $host->getBiosInfo() );

    $inventory->setHardware( $host->getHardwareInfo() );

    foreach my $cpu ($host->getCPUs()) {
        $inventory->addEntry(section => 'CPUS', entry => $cpu);
    }

    foreach my $controller ($host->getControllers()) {
        $inventory->addEntry(section => 'CONTROLLERS', entry => $controller);

        if ($controller->{PCICLASS} && $controller->{PCICLASS} eq '300') {
            $inventory->addEntry(
                section => 'VIDEOS',
                entry   => {
                    NAME    => $controller->{NAME},
                    PCISLOT => $controller->{PCISLOT},
                }
            );
        }
    }

    my %ipaddr;
    foreach my $network ($host->getNetworks()) {
        $ipaddr{ $network->{IPADDRESS} } = 1 if $network->{IPADDRESS};
        $inventory->addEntry(section => 'NETWORKS', entry => $network);
    }

    $inventory->setHardware( { IPADDR => join '/', ( keys %ipaddr ) } );

    # TODO
    #    foreach (@{$host->[0]{config}{fileSystemVolume}{mountInfo}}) {
    #
    #    }

    foreach my $storage ($host->getStorages()) {
        # TODO
        #        $volumnMapping{$entry->{canonicalName}} = $entry->{deviceName};
        $inventory->addEntry(section => 'STORAGES', entry => $storage);
    }

    foreach my $drive ($host->getDrives()) {
        $inventory->addEntry( section => 'DRIVES', entry => $drive);
    }

    foreach my $machine ($host->getVirtualMachines()) {
        $inventory->addEntry(section => 'VIRTUALMACHINES', entry => $machine);
    }

    return $inventory;

}

#sub getJobs {
#    my ($self) = @_;
#
#    my $logger = $self->{logger};
#    my $network = $self->{network};
#
#    my $jsonText = $network->get ({
#        source => $self->{backendURL}.'/?a=getJobs&d=TODO',
#        timeout => 60,
#        });
#    if (!defined($jsonText)) {
#        $logger->debug("No answer from server for deployment job.");
#        return;
#    }
#
#
#    return from_json( $jsonText, { utf8  => 1 } );
#}

sub _getHostIds {
    my ($self) = @_;

    return $self->{vpbs}->getHostIds();
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::ESX - ESX inventory task
