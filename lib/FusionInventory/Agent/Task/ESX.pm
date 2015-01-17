package FusionInventory::Agent::Task::ESX;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use FusionInventory::Agent::Inventory;
use FusionInventory::Agent::Message::Outbound;
use FusionInventory::Agent::SOAP::VMware;

use Parallel::ForkManager;

our $VERSION = $FusionInventory::Agent::VERSION;

sub getConfiguration {
    my ($self, %params) = @_;

    my $config = $params{spec}->{config};

    return (
        jobs => $config->{jobs}
    );
}

sub run {
    my ($self, %params) = @_;

    my $target = $params{target}
        or die "no target provided, aborting";
    my @jobs = @{$self->{config}->{jobs}}
        or die "no jobs provided, aborting";
    my $max_workers = $self->{config}->{workers} || 0;

    $self->{target} = $target;

    # no need for more workers than jobs to process
    my $workers_count = $max_workers > @jobs ? @jobs : $max_workers;
    my $manager = Parallel::ForkManager->new($workers_count);

    foreach my $job (@jobs) {
        $manager->start() and next;
        $self->_processJob(job => $job);
        $manager->finish();
    }

    $manager->wait_all_children();
}

sub _processJob {
    my ($self, %params) = @_;

    my $job = $params{job};

    my $vpbs = FusionInventory::Agent::SOAP::VMware->new(
        url     => "https://$job->{host}/sdk/vimService",
        vcenter => 1
    );

    if (!$vpbs->connect($job->{user}, $job->{password})) {
        $self->{target}->send(
            message  => {
                action    => 'setLog',
                machineid => $self->{config}->{deviceid},
                part      => 'login',
                uuid      => $job->{uuid},
                msg       => $vpbs->{lastError},
                code      => 'ko'
            }
        );
        return;
    }

    my $hostIds = $vpbs->_getHostIds();
    foreach my $hostId (@$hostIds) {
        my $inventory = $self->_createInventory(
            $hostId, $self->{config}->{tag}, $vpbs
        );

        my $message = FusionInventory::Agent::Message::Outbound->new(
            query      => 'INVENTORY',
            deviceid   => $self->{config}->{deviceid},
            stylesheet => $self->{config}->{datadir} . '/inventory.xsl',
            content    => $inventory->getContent()
        );

        $self->{target}->send(message => $message);
    }

    $self->{target}->send(
        message  => {
            action => 'setLog',
            machineid => $self->{config}->{deviceid},
            uuid      => $job->{uuid},
            code      => 'ok'
        }
    );
}

sub _createFakeDeviceid {
    my ( $self, $host ) = @_;

    my $hostname = $host->getHostname();
    my $bootTime = $host->getBootTime();
    my ($year, $month, $day, $hour, $min, $sec);
    if ($bootTime =~
        /(\d{4})-(\d{1,2})-(\d{1,2})T(\d{1,2}):(\d{1,2}):(\d{1,2})/ )
    {
        ($year, $month, $day, $hour, $min, $sec) = ($1, $2, $3, $4, $5, $6);
    } else {
        ($year, $month, $day, $hour, $min, $sec) =
          (localtime(time))[ 5, 4, 3, 2, 1, 0 ];
        $year  = $year + 1900;
        $month = $month + 1;
    }
    my $deviceid = sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
      $hostname, $year, $month, $day, $hour, $min, $sec;

    return $deviceid;
}

sub _createInventory {
    my ($self, $id, $tag, $vpbs) = @_;

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

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::ESX - ESX inventory support

=head1 DESCRIPTION

This module allows the FusionInventory agent to retrieve an inventory from a
remote ESX host SOAP protocol.
