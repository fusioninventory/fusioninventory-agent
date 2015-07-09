package FusionInventory::Agent::SOAP::VMware::Host;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub new {
    my ($class, %params) = @_;

    my $self = {
        hash => $params{hash},
        vms  => $params{vms}
    };

    bless $self, $class;

    return $self;
}

sub _asArray {
    my $h = shift;

    return
        ref $h eq 'ARRAY' ? @$h  :
            $h            ? ($h) :
                            ()   ;
}

sub getBootTime {
    my ($self) = @_;

    return $self->{hash}[0]{summary}{runtime}{bootTime};
}

sub getHostname {
    my ($self) = @_;

    return $self->{hash}[0]{name}

}

sub getBiosInfo {
    my ($self) = @_;

    my $hardware   = $self->{hash}[0]{hardware};
    my $biosInfo   = $hardware->{biosInfo};
    my $systemInfo = $hardware->{systemInfo};
    my $ssn;

    return unless ref($biosInfo) eq 'HASH';

    my $identifierValue;
    if (ref($systemInfo->{otherIdentifyingInfo}) eq 'HASH') {
        $identifierValue = $systemInfo->{otherIdentifyingInfo}->{identifierValue};
    }
    elsif (ref($systemInfo->{otherIdentifyingInfo}) eq 'ARRAY') {
        foreach (@{$systemInfo->{otherIdentifyingInfo}}) {
            if ($_->{identifierType}->{key} eq 'ServiceTag') {
                $ssn = $_->{identifierValue};
                last;
            }
        }
    }

    return {
        BDATE         => $biosInfo->{releaseDate},
        BVERSION      => $biosInfo->{biosVersion},
        SMODEL        => $systemInfo->{model},
        SMANUFACTURER => $systemInfo->{vendor},
        ASSETTAG      => $identifierValue,
        SSN           => $ssn
    };
}

sub getHardwareInfo {
    my ($self) = @_;

    my $dnsConfig  = $self->{hash}[0]{config}{network}{dnsConfig};
    my $hardware   = $self->{hash}[0]{hardware};
    my $summary    = $self->{hash}[0]{summary};
    my $product    = $summary->{config}->{product};
    my $systemInfo = $hardware->{systemInfo};

    return {
        NAME       => $dnsConfig->{hostName},
        DNS        => join('/', _asArray($dnsConfig->{address})),
        WORKGROUP  => $dnsConfig->{domainName},
        MEMORY     => int($hardware->{memorySize} / (1024 * 1024)),
        UUID       => $summary->{hardware}->{uuid} || $systemInfo->{uuid},
        OSVERSION  => $product->{version},
        OSNAME     => $product->{name},
        OSCOMMENTS => $product->{fullName}
    };
}

sub getCPUs {
    my ($self) = @_;

    my %cpuManufacturor = (
        amd   => 'AMD',
        intel => 'Intel',
    );

    my $hardware    = $self->{hash}[0]{hardware};
    my $totalCore   = $hardware->{cpuInfo}{numCpuCores};
    my $totalThread = $hardware->{cpuInfo}{numCpuThreads};
    my $cpuEntries  = $hardware->{cpuPkg};

    my @cpus;
    foreach (_asArray($cpuEntries)) {
        push @cpus,
          {
            CORE         => $totalCore / _asArray($cpuEntries),
            MANUFACTURER => $cpuManufacturor{ $_->{vendor} } || $_->{vendor},
            NAME         => $_->{description},
            SPEED        => int( $_->{hz} / ( 1000 * 1000 ) ),
            THREAD       => eval { $totalThread / $totalCore }
          };
    }

    return @cpus;
}

sub getControllers {
    my ($self) = @_;

    my @controllers;

    foreach ( @{ $self->{hash}[0]{hardware}{pciDevice} } ) {

        my $pciid = sprintf( "%x:%x", $_->{vendorId}, $_->{deviceId} );
        my $pcisubsystemid =
          sprintf( "%x:%x", $_->{subVendorId}, $_->{subDeviceId} );
        my $pciclass = sprintf( "%x", $_->{classId} );

        $pcisubsystemid = '' if $pcisubsystemid =~ /^[0:]+$/;

        # Workaround: sometime the pciid are odd negative number.
        # e.g: 111d:ffff8018, ffff8086:244e, ffff8086:ffffa02c
        foreach ( $pciid, $pcisubsystemid, $pciclass ) {
            s/(\w+:)/000$1:/;
            s/:(\w+)/:000$1/;
            s/.*(\w{4}:).*(\w{4}).*/$1$2/g;
        }
        push @controllers,
          {
            NAME           => $_->{deviceName},
            MANUFACTURER   => $_->{vendorName},
            PCICLASS       => $pciclass,
            PCIID          => $pciid,
            PCISUBSYSTEMID => $pcisubsystemid,
            PCISLOT        => $_->{id},
          };

    }

    return @controllers;
}

sub _getNic {
    my ($ref, $isVirtual) = @_;

    return {
        DESCRIPTION => $ref->{device},
        DRIVER      => $ref->{driver},
        IPADDRESS   => $ref->{spec}{ip}{ipAddress},
        IPMASK      => $ref->{spec}{ip}{subnetMask},
        MACADDR     => $ref->{mac} || $ref->{spec}{mac},
        MTU         => $ref->{spec}{mtu},
        PCISLOT     => $ref->{pci},
        STATUS      => $ref->{spec}{ip}{ipAddress} ? 'Up' : 'Down',
        VIRTUALDEV  => $isVirtual,
        SPEED       => $ref->{spec}{linkSpeed}{speedMb},
    }
}

sub getNetworks {
    my ($self) = @_;

    my @networks;

    my $seen = {};

    foreach my $nicType (qw/vnic pnic consoleVnic/)  {
        foreach (_asArray($self->{hash}[0]{config}{network}{$nicType}))
        {

            next if $seen->{$_->{device}}++;
            my $isVirtual = $nicType eq 'vnic'?1:0;
            push @networks, _getNic($_, $isVirtual);
        }
    }

    my @vnic;
    push @vnic, $self->{hash}[0]{config}{network}{consoleVnic}
        if $self->{hash}[0]{config}{network}{consoleVnic};
    push @vnic, $self->{hash}[0]{config}{vmotion}{netConfig}{candidateVnic}
        if $self->{hash}[0]{config}{vmotion}{netConfig}{candidateVnic};
    foreach my $entry (@vnic) {
        foreach (_asArray($entry)) {
            next if $seen->{$_->{device}}++;

            push @networks, _getNic($_, 1);
        }
    }

    return @networks;
}

sub getStorages {
    my ($self) = @_;

    my @storages;
    foreach my $entry (
        _asArray($self->{hash}[0]{config}{storageDevice}{scsiLun}))
    {
        my $serialnumber;
        my $size;

        # TODO
        #$volumnMapping{$entry->{canonicalName}} = $entry->{deviceName};

        foreach my $altName (_asArray($entry->{alternateName})) {
            next unless ref($altName) eq 'HASH';
            next unless $altName->{namespace};
            next unless $altName->{data};
            if ( $altName->{namespace} eq 'SERIALNUM' ) {
                $serialnumber .= $_ foreach ( @{ $altName->{data} } );
            }
        }
        if ( $entry->{capacity}{blockSize} && $entry->{capacity}{block} ) {
            $size = int(($entry->{capacity}{blockSize} *$entry->{capacity}{block})/1024/1024);
        }
        my $manufacturer;
        if ( $entry->{vendor} && ( $entry->{vendor} !~ /^\s*ATA\s*$/ ) ) {
            $manufacturer = $entry->{vendor};
        } else {
            $manufacturer = getCanonicalManufacturer( $entry->{model} );
        }

        $manufacturer =~ s/\s*(\S.*\S)\s*/$1/;

        my $model = $entry->{model};
        $model =~ s/\s*(\S.*\S)\s*/$1/;

        push @storages, {
            DESCRIPTION => $entry->{displayName},
            DISKSIZE    => $size,

            #        INTERFACE
            MANUFACTURER => $manufacturer,
            MODEL        => $model,
            NAME         => $entry->{deviceName},
            TYPE         => $entry->{deviceType},
            SERIAL       => $serialnumber,
            FIRMWARE     => $entry->{revision},

            #        SCSI_COID
            #        SCSI_CHID
            #        SCSI_UNID
            #        SCSI_LUN
        };

    }

    return @storages;

}

sub getDrives {
    my ($self) = @_;

    my @drives;

    foreach (
        _asArray($self->{hash}[0]{config}{fileSystemVolume}{mountInfo}))
    {
        my $volumn;
        if ( $_->{volume}{type} && ( $_->{volume}{type} =~ /NFS/i ) ) {
            $volumn = $_->{volume}{remoteHost} . ':' . $_->{volume}{remotePath};

# TODO
#        } else {
#            $volumn = $volumnMapping{$_->{volume}{extent}{diskName}}." ".$_->{volume}{extent}{partition};
        }
        push @drives,
          {
            SERIAL => $_->{volume}{uuid},
            TOTAL  => int( ( $_->{volume}{capacity} || 0 ) / ( 1000 * 1000 ) ),
            TYPE   => $_->{mountInfo}{path},
            VOLUMN => $volumn,
            NAME   => $_->{volume}{name},
            FILESYSTEM => lc( $_->{volume}{type} )
          };
    }

    return @drives;
}

sub getVirtualMachines {
    my ($self) = @_;

    my @virtualMachines;

    foreach my $vm (@{$self->{vms}}) {
        my $machine = $vm->[0];
        my $status =
            $machine->{summary}{runtime}{powerState} eq 'poweredOn'  ? 'running' :
            $machine->{summary}{runtime}{powerState} eq 'poweredOff' ? 'off'     :
            $machine->{summary}{runtime}{powerState} eq 'suspended'  ? 'pause'   :
                                                                    undef     ;
        print "Unknown status (".$machine->{summary}{runtime}{powerState}.")\n" if !$status;

        my @mac;
        foreach my $device (_asArray($machine->{config}{hardware}{device})) {
            push @mac, $device->{macAddress} if $device->{macAddress};
        }

        my $comment = $machine->{config}{annotation};

        # hack to preserve  annotation / comment formating
        $comment =~ s/\n/&#10;/gm if $comment;

        if (
            defined($_->[0]{summary}{config}{template})
            &&
            $_->[0]{summary}{config}{template} eq 'true'
            ) {
            next;
        }

        push @virtualMachines,
          {
            NAME    => $machine->{name},
            STATUS  => $status,
            UUID    => $machine->{summary}{config}{uuid},
            MEMORY  => $machine->{summary}{config}{memorySizeMB},
            VMTYPE  => 'VMware',
            VCPU    => $machine->{summary}{config}{numCpu},
            MAC     => join( '/', @mac ),
            COMMENT => $comment
          };
    }

    return @virtualMachines;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::SOAP::VMware::Host - VMware Host abstraction layer

=head1 DESCRIPTION

The module is an abstraction layer to access the VMware host.

=head1 FUNCTIONS

=head2 new($class, %params)

Returns an object.

=head2 getBootTime( $self )

Returns the date in the following format: 2012-12-31T12:59:59

=head2 getHostname( $self )

Returns the host name.

=head2 getBiosInfo( $self )

Returns the BIOS (BDATE, BVERSION, SMODEL, SMANUFACTURER, ASSETTAG, SSN)
information in an HASH reference.

=head2 getHardwareInfo( $self )

Returns hardware information in a hash reference.

=head2 getCPUs( $self )

Returns CPU information (hash ref) in an array.

=head2 getControllers( $self )

Returns PCI controller information (hash ref) in an
array.

=head2 getNetworks( $self )

Returns the networks configuration in an array.


=head2 getStorages( $self )

Returns the storage devices in an array.

=head2 getDrives( $self )

Returns the hard drive partitions in an array.

=head2 getVirtualMachines( $self )

Retuns the Virtual Machines in an array.
