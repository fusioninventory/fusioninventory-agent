package FusionInventory::VMware::SOAP::Host;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub new {
    my (undef, $hash, $vms) = @_;


    my $self = {
        hash => $hash,
        vms => $vms
    };


    bless $self;
}

sub getArray {
    my $h = shift;


    if (ref($h) eq 'ARRAY') {
        return $h;
    } else {
        return [$h];
    }
}

sub getBootTime {
    my ($self) = @_;

    return $self->{hash}[0]{summary}{runtime}{bootTime}
}

sub getHostname {
    my ($self) = @_;

    return $self->{hash}[0]{name}

}

sub getBiosInfo {
    my ($self) = @_;

    my $bdate = $self->{hash}[0]{hardware}{biosInfo}{releaseDate};
    my $bversion = $self->{hash}[0]{hardware}{biosInfo}{biosVersion};
    my $smodel = $self->{hash}[0]{hardware}{systemInfo}{model};
    my $smanufacturer = $self->{hash}[0]{hardware}{systemInfo}{vendor};
    my $assettag = $self->{hash}[0]{hardware}{systemInfo}{otherIdentifyingInfo}{identifierValue};

    return {
        BDATE => $bdate,
              BVERSION => $bversion,
              SMODEL => $smodel,
              SMANUFACTURER => $smanufacturer,
              ASSETTAG => $assettag,

    }
}

sub getHardwareInfo {
    my ($self) = @_;

    my $name = $self->{hash}[0]{config}{network}{dnsConfig}{hostName};
    my $dns = join '/', @{getArray($self->{hash}[0]{config}{network}{dnsConfig}{address})};
    my $workgroup = $self->{hash}[0]{config}{network}{dnsConfig}{domainName};
    my $memory = int($self->{hash}[0]{hardware}{memorySize} / (1024*1024));
    my $uuid = $self->{hash}[0]{summary}{hardware}{uuid} || $self->{hash}[0]{hardware}{systemInfo}{uuid};
    my $osversion = $self->{hash}[0]{summary}{config}{product}{version};
    my $osname = $self->{hash}[0]{summary}{config}{product}{name};
    my $oscomments = $self->{hash}[0]{summary}{config}{product}{fullName};
    return {
        NAME => $name,
             DNS => $dns,
             WORKGROUP => $workgroup, 
             MEMORY => $memory,
             UUID => $uuid,
             OSVERSION => $osversion,
             OSNAME => $osname,
             OSCOMMENTS => $oscomments,
    };
}

sub getCPUs {
    my ($self) = @_;

    my %cpuManufacturor = (
            amd => 'AMD',
            intel => 'Intel',
            );


    my $ret = [];
    foreach (@{getArray($self->{hash}[0]{hardware}{cpuPkg})}) {
        my $thread;
        my $core;

        push @$ret, {
            CORE => $self->{hash}[0]{hardware}{cpuInfo}{numCpuCores},
                 MANUFACTURER =>  $cpuManufacturor{$_->{vendor}} || $_->{vendor},
                 NAME => $_->{description},
                 SPEED => int($_->{hz}/(1000*1000)),
                 THREAD => eval{$self->{hash}[0]{hardware}{cpuInfo}{numCpuThreads} / $self->{hash}[0]{hardware}{cpuInfo}{numCpuCores}}
        };
    }


    return $ret;
}

sub getControllers {
    my ($self) = @_;

    my $ret = [];

    foreach (@{$self->{hash}[0]{hardware}{pciDevice}}) {


        my $pciid = sprintf("%x:%x", $_->{vendorId}, $_->{deviceId});
        my $pcisubsystemid = sprintf("%x:%x", $_->{subVendorId}, $_->{subDeviceId});
        my $pciclass = sprintf("%x", $_->{classId});

        # Workaround: sometime the pciid are odd negative number
        foreach ($pciid, $pcisubsystemid, $pciclass) {
                s/(f{4}f+)//g;
        }
        push @$ret, {
            NAME => $_->{deviceName},
                 MANUFACTURER => $_->{vendorName},
                 PCICLASS => $pciclass,
                 PCIID => $pciid,
                 PCISUBSYSTEMID => $pcisubsystemid,
                 PCISLOT => $_->{id},
        };

    }

    return $ret;
}

sub getNetworks {
    my ($self) = @_;

    my $ret = [];
    foreach (@{getArray($self->{hash}[0]{config}{network}{pnic})}) {
        push @$ret, {
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
                };
    }

    foreach (@{getArray($self->{hash}[0]{config}{network}{vnic})}) {
        push @$ret, {
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
                };
    }

    foreach ($self->{hash}[0]{config}{network}{consoleVnic}, $self->{hash}[0]{config}{vmotion}{netConfig}{candidateVnic}) {
        next if ref($_) ne 'HASH';

        push @$ret, {
                DESCRIPTION => $_->{device},
                IPADDRESS => $_->{spec}{ip}{ipAddress},
                IPMASK => $_->{spec}{ip}{subnetMask},
                MACADDR => $_->{spec}{mac},
                MTU => $_->{spec}{ip}{mtu},
                STATUS => $_->{spec}{ip}{ipAddress}?'Up':'Down',
                VIRTUALDEV => '1',
                };
    }

    return $ret;
}

sub getStorages {
    my ($self) = @_;

    my $ret = [];
    foreach my $entry (@{getArray($self->{hash}[0]{config}{storageDevice}{scsiLun})}) {
        my $serialnumber;
        my $size;


        # TODO 
        #$volumnMapping{$entry->{canonicalName}} = $entry->{deviceName};


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
        push @$ret, {
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
                };

    }

    return $ret;

}

sub getDrives {
    my ($self) = @_;

    my $ret = [];

    foreach (@{getArray($self->{hash}[0]{config}{fileSystemVolume}{mountInfo})}) {
        my $volumn;
        if ($_->{volume}{type} && ($_->{volume}{type} =~ /NFS/i)) {
            $volumn = $_->{volume}{remoteHost}.':'.$_->{volume}{remotePath};
            # TODO
#        } else {
#            $volumn = $volumnMapping{$_->{volume}{extent}{diskName}}." ".$_->{volume}{extent}{partition};
        }
        push @$ret, {
                SERIAL => $_->{volume}{uuid},
                TOTAL => int (($_->{volume}{capacity} || 0) / (1000*1000)),
                TYPE => $_->{mountInfo}{path},
                VOLUMN => $volumn,
                NAME => $_->{volume}{name},
                FILESYSTEM => lc($_->{volume}{type})
                };
    }

    return $ret;
}

sub getVirtualMachines {
    my ($self) = @_;

    my $ret = [];

    foreach (@{$self->{vms}}) {
        my $status;
        if ($_->[0]{summary}{runtime}{powerState} eq 'poweredOn') {
            $status = 'running';
        }

        if (!$status) {
            print Dumper($_->[0]);
        }

        push @$ret, {
            VMID => $_->[0]{summary}{vm},
            NAME => $_->[0]{name},
            STATUS => $status,
            UUID => $_->[0]{summary}{config}{uuid},
            MEMORY => $_->[0]{summary}{config}{memorySizeMB},
            VMTYPE => 'VMware',
            VCPU => $_->[0]{summary}{config}{numCpu},
        };
    }

    return $ret;
}

1;
