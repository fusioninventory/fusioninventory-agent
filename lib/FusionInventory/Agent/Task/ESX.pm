package FusionInventory::Agent::Task::ESX;

our $VERSION = "1.1.0";

use Data::Dumper;
use strict;
use warnings;

use FusionInventory::Agent::REST;
use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Agent::Config;
use FusionInventory::VMware::SOAP;
use FusionInventory::Logger;

sub connect {
    my ($self, $job) = @_;

    my $url = 'https://'.$job->{addr}.'/sdk/vimService';

    my $vpbs = FusionInventory::VMware::SOAP->new({ url => $url, vcenter => 1 });
    if (!$vpbs->connect($job->{login}, $job->{passwd})) {
        $self->{lastError} = $vpbs->{lastError};
        return;
    }

    $self->{vpbs} = $vpbs;
}

sub createFakeDeviceid {
    my ($self, $host) = @_;

    my $hostname = $host->getHostname();
    my $bootTime = $host->getBootTime();
    my ($year, $month, $day, $hour, $min, $sec);
    if ($bootTime =~ /(\d{4})-(\d{1,2})-(\d{1,2})T(\d{1,2}):(\d{1,2}):(\d{1,2})/) {
        $year = $1;
        $month = $2;
        $day = $3;
        $hour = $4;
        $min = $5;
        $sec = $6;
    } else {
        my $ty;
        my $tm;
        ($ty, $tm, $day, $hour, $min, $sec) = (localtime
                (time))[5,4,3,2,1,0];
        $year = $ty + 1900;
        $month = $tm + 1;
    }
    my $deviceid =sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
       $hostname, $year, $month, $day, $hour, $min, $sec;

    return $deviceid;
}

sub createInventory {
    my ($self, $id) = @_;

    die unless $self->{vpbs};

    my $vpbs = $self->{vpbs};

    my $host;
    $host = $vpbs->getHostFullInfo($id);

    my $inventory = FusionInventory::Agent::XML::Query::Inventory->new({
            logger => $self->{logger},
            config => $self->{config},
            target => { deviceid => $self->createFakeDeviceid($host), path => '/tmp', vardir => '/tmp/toto' }
            });

    $inventory->{isInitialised}=1;
    $inventory->{h}{CONTENT}{HARDWARE}{ARCHNAME}=['remote'];

    $inventory->setBios($host->getBiosInfo());

    $inventory->setHardware($host->getHardwareInfo());

    foreach my $cpu (@{$host->getCPUs()})
    {
        $inventory->addCPU($cpu);
    }

    foreach (@{$host->getControllers()}) {
        $inventory->addController($_);

        if ($_->{PCICLASS} && ($_->{PCICLASS} eq '300')) {
            $inventory->addVideo({
                    NAME => $_->{NAME},
                    PCISLOT => $_->{PCISLOT},
                    })
        }
    }

    my %ipaddr;
    foreach (@{$host->getNetworks()}) {
        $ipaddr{$_->{IPADDRESS}}=1 if $_->{IPADDRESS};
        $inventory->addNetwork($_);
    }
    $inventory->setHardware({IPADDR => join '/', (keys %ipaddr)});


# TODO
#    foreach (@{$host->[0]{config}{fileSystemVolume}{mountInfo}}) {
#
#    }

    my %volumnMapping;
    foreach (@{$host->getStorages()}) {

# TODO
#        $volumnMapping{$entry->{canonicalName}} = $entry->{deviceName};

        $inventory->addStorage($_);
    }

    foreach (@{$host->getDrives()}) {
        $inventory->addDrive($_);
    }

    foreach (@{$host->getVirtualMachines()}) {
        $inventory->addVirtualMachine($_);
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

sub getHostIds {
    my ($self) = @_;

    return $self->{vpbs}->getHostIds();
}

sub main {
    my ( undef ) = @_;

    my $self = {};
    bless $self;


    my $storage = FusionInventory::Agent::Storage->new({
            target => {
                vardir => $ARGV[0],
            }
        });

    my $data = $storage->restore({
            module => "FusionInventory::Agent"
        });

    my $config = $self->{config} = $data->{config};
    my $target = $self->{'target'} = $data->{'target'};
    my $logger = $self->{logger} = FusionInventory::Logger->new ({
            config => $self->{config}
        });

    return unless $target;
    return unless $target->{type} eq 'server';

    my $network = $self->{network} = FusionInventory::Agent::Network->new ({

            logger => $logger,
            config => $config,
            target => $target,

        });


    my $globalRest = FusionInventory::Agent::REST->new(
            "url" => $target->{path},
            "network" => $network
            );
    my $globalRemoteConfig = $globalRest->getConfig(
            d => $target->{deviceid},
            task => { ESX => $VERSION},
            array => [ 'aa', 'bb', 'cc' ]
    );
    return unless $globalRemoteConfig->{schedule};
    return unless ref($globalRemoteConfig->{schedule}) eq 'ARRAY';

    my $esxRemote;
    foreach my $job (@{$globalRemoteConfig->{schedule}}) {
        next unless $job->{task} eq "ESX";
        $esxRemote = $job->{remote};
    }
    my $esxRest = FusionInventory::Agent::REST->new(
            "url" => $esxRemote,
            "network" => $network
            );


    my $jobs = $esxRest->getJobs();
    my $uuid = $jobs->{uuid};

    return unless $jobs;
    return unless ref($jobs->{jobs}) eq 'ARRAY';

    my $esx = FusionInventory::Agent::Task::ESX->new({
            config => $config
            });


    foreach my $jobId (1..@{$jobs->{jobs}}) {
        my $job = $jobs->{jobs}[$jobId-1];

        if (!$esx->connect($job)) {
           $esxRest->setLog(
              d => $target->{deviceid},
              p => 'login',
              j => $jobId,
              u => $uuid,
              msg => $esx->{lastError},
              code => 'ko'
           );
           next;
        }

        my $hostIds = $esx->getHostIds();
        foreach my $hostId (@$hostIds) {
            my $inventory = $esx->createInventory($hostId);

            $inventory->writeXML();
        }
        $esxRest->setLog(
                d => $target->{deviceid},
                j => $jobId,
                u => $uuid,
                code => 'ok'
        );

    }

    return $self;
}

# Only used by the command line tool
sub new {
    my (undef, $params) = @_;

    my $logger = FusionInventory::Logger->new ();


    my $self = { config => $params->{config}, logger => $logger };
    bless $self;
}

1;
