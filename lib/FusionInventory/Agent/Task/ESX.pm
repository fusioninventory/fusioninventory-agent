package FusionInventory::Agent::Task::ESX;

our $VERSION = "0.0.1";

use strict;
use warnings;

use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Agent::Config;
use FusionInventory::VMware::SOAP;
use FusionInventory::Logger;

use Data::Dumper;


sub connect {
    my ($self, $job) = @_;

    my $url = 'http://'.$job->{addr}.'/sdk/vimService';

    my $vpbs = FusionInventory::VMware::SOAP->new({ url => $url, vcenter => 1 });
    if (!$vpbs->connect($job->{login}, $job->{passwd})) {
        die "failed to log in\n";
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


sub getJobs {
    my ($self) = @_;

    my $logger = $self->{logger};
    my $network = $self->{network};

    my $jsonText = $network->get ({
        source => $self->{backendURL}.'/?a=getJobs&d=TODO',
        timeout => 60,
        });
    if (!defined($jsonText)) {
        $logger->debug("No answer from server for deployment job.");
        return;
    }


    return from_json( $jsonText, { utf8  => 1 } );
}

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

    return unless $target->{type} eq 'server';

    $self->{backendURL} = $target->{path}."/esx/";
    # DEBUG:
    $self->{backendURL} = "http://nana.rulezlan.org/deploy/ocsinventory/esx/";

    my $network = $self->{network} = FusionInventory::Agent::Network->new ({

            logger => $logger,
            config => $config,
            target => $target,

        });

    my $jobs = $self->getJobs();
    return unless $jobs;
    return unless ref($jobs) eq 'ARRAY';
    foreach my $job (@$jobs) {
        my $esx = FusionInventory::Agent::Task::ESX->new({
                config => $config
        });

        $esx->connect($job);

        my $hostIds = $esx->getHostIds();
        foreach my $hostId (@$hostIds) {
            my $inventory = $esx->createInventory($hostId);

            $inventory->writeXML();
        }
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
