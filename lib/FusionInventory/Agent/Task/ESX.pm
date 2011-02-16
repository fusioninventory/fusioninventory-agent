package FusionInventory::Agent::Task::ESX;

use strict;
use warnings;

use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Config;
use FusionInventory::VMware::SOAP;
use FusionInventory::Logger;

use Getopt::Long;

sub getArray {
    my $h = shift;


    if (ref($h) eq 'ARRAY') {
        return $h;
    } else {
        return [$h];
    }
}

sub createFakeDeviceid {
    my ($hostFullInfo) = @_;

    my $hostname = $hostFullInfo->[0]{name};
    my $bootTime = $hostFullInfo->[0]{summary}{runtime}{bootTime};
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



#my $hostInfo = $vpbs->getHostInfo();

    my $hostFullInfo = $vpbs->getHostFullInfo();

    my $inventory = FusionInventory::Agent::XML::Query::Inventory->new({
            logger => $logger,
            config => $config,
            target => { deviceid => createFakeDeviceid($hostFullInfo), path => '/tmp', vardir => '/tmp/toto' }
            });

    $inventory->{isInitialised}=1;
    $inventory->{h}{CONTENT}{HARDWARE}{ARCHNAME}=['remote'];




    $inventory->setBios({
            BDATE => $hostFullInfo->[0]{hardware}{biosInfo}{releaseDate},
            BVERSION => $hostFullInfo->[0]{hardware}{biosInfo}{biosVersion},
            SMODEL => $hostFullInfo->[0]{hardware}{systemInfo}{model},
            SMANUFACTURER => $hostFullInfo->[0]{hardware}{systemInfo}{vendor},
            ASSETTAG => $hostFullInfo->[0]{hardware}{systemInfo}{otherIdentifyingInfo}{identifierValue},
            });

    $inventory->setHardware({
            NAME => $hostFullInfo->[0]{config}{network}{dnsConfig}{hostName},
            DNS => $hostFullInfo->[0]{config}{network}{dnsConfig}{address},
            WORKGROUP => $hostFullInfo->[0]{config}{network}{dnsConfig}{domainName},
            MEMORY => int($hostFullInfo->[0]{hardware}{memorySize} / (1024*1024)),
            UUID => $hostFullInfo->[0]{summary}{hardware}{uuid} || $hostFullInfo->[0]{hardware}{systemInfo}{uuid},
#    VMSYSTEM => "VMware",
            OSVERSION => $hostFullInfo->[0]{summary}{config}{product}{version},
            OSNAME => $hostFullInfo->[0]{summary}{config}{product}{name},
            OSCOMMENTS => $hostFullInfo->[0]{summary}{config}{product}{fullName},
            });

    my %cpuManufacturor = (
            amd => 'AMD',
            intel => 'Intel',
            );
    foreach (@{getArray($hostFullInfo->[0]{hardware}{cpuPkg})}) {
        my $thread;
        my $core;


        $inventory->addCPU({
                CORE => $hostFullInfo->[0]{hardware}{cpuInfo}{numCpuCores},
                MANUFACTURER =>  $cpuManufacturor{$_->{vendor}} || $_->{vendor},
                NAME => $_->{description},
                SPEED => int($_->{hz}/(1000*1000)),
                THREAD => eval{$hostFullInfo->[0]{hardware}{cpuInfo}{numCpuThreads} / $hostFullInfo->[0]{hardware}{cpuInfo}{numCpuCores}}
                });
    }
    delete($hostFullInfo->[0]{hardware}{cpuPkg});
    my %ipaddr;
    foreach (@{$hostFullInfo->[0]{hardware}{pciDevice}}) {
        $ipaddr{$_->{ip}{ipAddress}}=1 if $_->{ip}{ipAddress};

        my $pciclass = sprintf("%x", $_->{classId});
        $inventory->addController({
                NAME => $_->{deviceName},
                MANUFACTURER => $_->{vendorName},
                PCICLASS => $pciclass,
                PCIID => sprintf("%x:%x", $_->{vendorId}, $_->{deviceId}),
                PCISUBSYSTEMID => sprintf("%x:%x", $_->{subVendorId}, $_->{subDeviceId}),
                PCISLOT => $_->{id},
                });

        if ($pciclass && ($pciclass eq '300')) {
            $inventory->addVideo({
                    NAME => $_->{deviceName},
                    PCISLOT => $_->{id},
                    }) 
        }
    }

    foreach (@{getArray($hostFullInfo->[0]{config}{network}{pnic})}) {
        $ipaddr{$_->{ip}{ipAddress}}=1 if $_->{ip}{ipAddress};
        $inventory->addNetwork({
                DESCRIPTION => $_->{device},
                DRIVER => $_->{driver},
                IPADDRESS => $_->{ip}{ipAddress},
#            IPGATEWAY => '',
                IPMASK => $_->{ip}{subnetMask},
#            IPSUBNET => '',
                MACADDR => $_->{mac},
#            MTU => '',
                PCISLOT => $_->{pci},
                STATUS => $_->{ip}{ipAddress}?'Up':'Down',
#            TYPE => '',
#            VIRTUALDEV => '',
#            SLAVES => '',
#            MANAGEMENT => '',
                SPEED => $_->{spec}{linkSpeed}{speedMb},
                });
    }

    foreach (@{getArray($hostFullInfo->[0]{config}{network}{vnic})}) {
        $ipaddr{$_->{ip}{ipAddress}}=1 if $_->{ip}{ipAddress};
        $inventory->addNetwork({
                DESCRIPTION => $_->{device},
                DRIVER => $_->{driver},
                IPADDRESS => $_->{ip}{ipAddress},
#            IPGATEWAY => '',
                IPMASK => $_->{ip}{subnetMask},
#            IPSUBNET => '',
                MACADDR => $_->{mac},
#            MTU => '',
                PCISLOT => $_->{pci},
                STATUS => $_->{ip}{ipAddress}?'Up':'Down',
#            TYPE => '',
                VIRTUALDEV => '1',
#            SLAVES => '',
#            MANAGEMENT => '',
                SPEED => $_->{spec}{linkSpeed}{speedMb},
                });
    }

    foreach ($hostFullInfo->[0]{config}{network}{consoleVnic}, $hostFullInfo->[0]{config}{vmotion}{netConfig}{candidateVnic}) {
        next if ref($_) ne 'HASH';
        $ipaddr{$_->{spec}{ip}{ipAddress}}=1 if $_->{spec}{ip}{ipAddress};

        $inventory->addNetwork({
                DESCRIPTION => $_->{device},
                IPADDRESS => $_->{spec}{ip}{ipAddress},
                IPMASK => $_->{spec}{ip}{subnetMask},
                MACADDR => $_->{spec}{mac},
                MTU => $_->{spec}{ip}{mtu},
                STATUS => $_->{spec}{ip}{ipAddress}?'Up':'Down',
                VIRTUALDEV => '1',
                });
    }

    $inventory->setHardware({IPADDR => join '/', (keys %ipaddr)});



    foreach (@{$hostFullInfo->[0]{config}{fileSystemVolume}{mountInfo}}) {

    }

    my %volumnMapping;
    foreach my $entry (@{getArray($hostFullInfo->[0]{config}{storageDevice}{scsiLun})}) {
        my $serialnumber;
        my $size;


        $volumnMapping{$entry->{canonicalName}} = $entry->{deviceName};


        foreach my $altName (@{getArray($entry->{alternateName})}) {
            next unless ref($altName) eq 'HASH';
            next unless $altName->{namespace};
            next unless $altName->{data};
            if ($altName->{namespace} eq 'SERIALNUM') {
                $serialnumber .= $_ foreach (@{$altName->{data}});
            }
        }
        if ($entry->{capacity}{blockSize} && $entry->{capacity}{block}) {
            $size = int($entry->{capacity}{blockSize} *$entry->{capacity}{block})/1000;
        }
        $inventory->addStorage({
                DESCRIPTION => $entry->{displayName},
                DISKSIZE => $size,
#        INTERFACE
                MANUFACTURER => getCanonicalManufacturer($entry->{model}) || $entry->{vendor},
                MODEL => $entry->{model},
                NAME => $entry->{deviceName},
                TYPE => $entry->{deviceType},
                SERIAL => $serialnumber,
                FIRMWARE => $entry->{revision},
#        SCSI_COID
#        SCSI_CHID
#        SCSI_UNID
#        SCSI_LUN
                });

    }

    foreach (@{getArray($hostFullInfo->[0]{config}{fileSystemVolume}{mountInfo})}) {
        my $volumn;
        if ($_->{volume}{type} && ($_->{volume}{type} =~ /NFS/i)) {
            $volumn = $_->{volume}{remoteHost}.':'.$_->{volume}{remotePath};
        } else {
            $volumn = $volumnMapping{$_->{volume}{extent}{diskName}}." ".$_->{volume}{extent}{partition};
        }
        $inventory->addDrive({
                SERIAL => $_->{volume}{uuid},
                TOTAL => int (($_->{volume}{capacity} || 0) / (1000*1000)),
                TYPE => $_->{mountInfo}{path},
                VOLUMN => $volumn,
                NAME => $_->{volume}{name},
                FILESYSTEM => lc($_->{volume}{type})
                });
    }


    my $machineIdList = $vpbs->getVirtualMachineList();
    foreach my $id (@$machineIdList) {
        my $machine = $vpbs->getVirtualMachineById($id);

        my $status;
        if ($machine->[0]{summary}{runtime}{powerState} eq 'poweredOn') {
                $status = 'running';
        }

        if (!$status) {
            print Dumper($machine->[0]);
        }

        $inventory->addVirtualMachine({
                VMID => $machine->[0]{summary}{vm},
                NAME => $machine->[0]{name},
                STATUS => $status,
                UUID => $machine->[0]{summary}{config}{uuid},
                MEMORY => $machine->[0]{summary}{config}{memorySizeMB},
                VMTYPE => 'VMware',
                VCPU => $machine->[0]{summary}{config}{numCpu},

                });

    }

    return $inventory;

}


1;
