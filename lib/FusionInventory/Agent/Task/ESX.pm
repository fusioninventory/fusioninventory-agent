package FusionInventory::Agent::Task::ESX;

our $VERSION = "0.0.1";

use strict;
use warnings;

use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Agent::Config;
use FusionInventory::VMware::SOAP;
use FusionInventory::Logger;

use Data::Dumper;


sub createFakeDeviceid {
    my ($host) = @_;

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

sub createEsxInventory {
    my ($params) = @_;


    my $logger = FusionInventory::Logger->new();
    my $config = FusionInventory::Agent::Config::load();


    my $url = 'http://'.$params->{host}.'/sdk/vimService';

    my $vpbs = FusionInventory::VMware::SOAP->new({ url => $url });
    if (!$vpbs->login($params->{user}, $params->{password})) {
        die "failed to log in\n";
    }



    my $host = $vpbs->getHostFullInfo();

    my $inventory = FusionInventory::Agent::XML::Query::Inventory->new({
            logger => $logger,
            config => $config,
            target => { deviceid => createFakeDeviceid($host), path => '/tmp', vardir => '/tmp/toto' }
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
                    NAME => $_->{deviceName},
                    PCISLOT => $_->{id},
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


1;
