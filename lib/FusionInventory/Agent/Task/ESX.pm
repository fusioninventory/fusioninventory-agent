package FusionInventory::Agent::Task::ESX;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use FusionInventory::Agent::Inventory;
use FusionInventory::Agent::Message::Outbound;
use FusionInventory::Agent::SOAP::VMware;

our $VERSION = $FusionInventory::Agent::VERSION;

sub getConfiguration {
    my ($self, %params) = @_;

    my $spec   = $params{spec};
    my $client = $params{client};

    my $jobs = $client->sendJSON(
        url  => $spec->{remote},
        args => {
            action    => "getJobs",
            machineid => $params{deviceid}
        }
    );

    die "No host in the server request"
        if !$jobs;

    die "Invalid server request format"
        if ref $jobs->{jobs} ne 'ARRAY';

    return (
        url  => $spec->{remote},
        jobs => $jobs->{jobs}
    );
}

sub run {
    my ($self, %params) = @_;

    my $target = $params{target}
        or die "no target provided, aborting";
    my @jobs = @{$self->{config}->{jobs}}
        or die "no jobs provided, aborting";

    foreach my $job (@jobs) {

        if ( !$self->_connect(
                host     => $job->{host},
                user     => $job->{user},
                password => $job->{password}
        )) {
            $target->send(
                message  => {
                    action    => 'setLog',
                    machineid => $self->{deviceid},
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
                deviceid   => $self->{deviceid},
                stylesheet => $self->{datadir} . '/inventory.xsl',
                content    => $inventory->getContent()
            );

            $target->send(message => $message);
        }
        $target->send(
            message  => {
                action => 'setLog',
                machineid => $self->{deviceid},
                uuid      => $job->{uuid},
                code      => 'ok'
            }
        );
    }

    return $self;
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
    my ( $self, $host ) = @_;

    my $hostname = $host->getHostname();
    my $bootTime = $host->getBootTime();
    my ( $year, $month, $day, $hour, $min, $sec );
    if ( $bootTime =~
        /(\d{4})-(\d{1,2})-(\d{1,2})T(\d{1,2}):(\d{1,2}):(\d{1,2})/ )
    {
        $year  = $1;
        $month = $2;
        $day   = $3;
        $hour  = $4;
        $min   = $5;
        $sec   = $6;
    }
    else {
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
    my ( $self, $id, $tag ) = @_;

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

sub _getHostIds {
    my ($self) = @_;

    return $self->{vpbs}->_getHostIds();
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::ESX - ESX inventory support

=head1 DESCRIPTION

This module allows the FusionInventory agent to retrieve an inventory from a
remote ESX host SOAP protocol.
