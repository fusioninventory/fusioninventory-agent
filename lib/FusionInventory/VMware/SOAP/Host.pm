package FusionInventory::VMware::SOAP::Host;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub new {
    my ( undef, $hash, $vms ) = @_;

    my $self = {
        hash => $hash,
        vms  => $vms
    };

    bless $self;
}

sub getArray {
    my $h = shift;

    if ( ref($h) eq 'ARRAY' ) {
        return $h;
    }
    elsif ($h) {
        return [$h];
    }
    else {
        return [];
    }
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

    my $bdate;
    my $bversion;
    my $smodel;
    my $smanufacturer;
    my $assettag;

    eval { $bdate    = $self->{hash}[0]{hardware}{biosInfo}{releaseDate}; };
    eval { $bversion = $self->{hash}[0]{hardware}{biosInfo}{biosVersion}; };
    eval { $smodel   = $self->{hash}[0]{hardware}{systemInfo}{model}; };
    eval { $smanufacturer = $self->{hash}[0]{hardware}{systemInfo}{vendor}; };
    eval {
        $assettag =
          $self->{hash}[0]{hardware}{systemInfo}{otherIdentifyingInfo}
          {identifierValue};
    };

    return {
        BDATE         => $bdate,
        BVERSION      => $bversion,
        SMODEL        => $smodel,
        SMANUFACTURER => $smanufacturer,
        ASSETTAG      => $assettag,

    };
}

sub getHardwareInfo {
    my ($self) = @_;

    my $name = $self->{hash}[0]{config}{network}{dnsConfig}{hostName};
    my $dns  = join '/',
      @{ getArray( $self->{hash}[0]{config}{network}{dnsConfig}{address} ) };
    my $workgroup = $self->{hash}[0]{config}{network}{dnsConfig}{domainName};
    my $memory =
      int( $self->{hash}[0]{hardware}{memorySize} / ( 1024 * 1024 ) );
    my $uuid = $self->{hash}[0]{summary}{hardware}{uuid}
      || $self->{hash}[0]{hardware}{systemInfo}{uuid};
    my $osversion  = $self->{hash}[0]{summary}{config}{product}{version};
    my $osname     = $self->{hash}[0]{summary}{config}{product}{name};
    my $oscomments = $self->{hash}[0]{summary}{config}{product}{fullName};
    return {
        NAME       => $name,
        DNS        => $dns,
        WORKGROUP  => $workgroup,
        MEMORY     => $memory,
        UUID       => $uuid,
        OSVERSION  => $osversion,
        OSNAME     => $osname,
        OSCOMMENTS => $oscomments,
    };
}

sub getCPUs {
    my ($self) = @_;

    my %cpuManufacturor = (
        amd   => 'AMD',
        intel => 'Intel',
    );

    my $totalCore;
    my $totalThread;
    my $cpuEntries;
    eval { $totalCore   = $self->{hash}[0]{hardware}{cpuInfo}{numCpuCores} };
    eval { $totalThread = $self->{hash}[0]{hardware}{cpuInfo}{numCpuThreads} };
    eval { $cpuEntries  = $self->{hash}[0]{hardware}{cpuPkg} };
    my $ret = [];
    foreach ( @{ getArray($cpuEntries) } ) {
        my $thread;
        push @$ret,
          {
            CORE         => $totalCore / @{ getArray($cpuEntries) },
            MANUFACTURER => $cpuManufacturor{ $_->{vendor} } || $_->{vendor},
            NAME         => $_->{description},
            SPEED        => int( $_->{hz} / ( 1000 * 1000 ) ),
            THREAD       => eval { $totalThread / $totalCore }
          };
    }

    return $ret;
}

sub getControllers {
    my ($self) = @_;

    my $ret = [];

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
        push @$ret,
          {
            NAME           => $_->{deviceName},
            MANUFACTURER   => $_->{vendorName},
            PCICLASS       => $pciclass,
            PCIID          => $pciid,
            PCISUBSYSTEMID => $pcisubsystemid,
            PCISLOT        => $_->{id},
          };

    }

    return $ret;
}

sub _getNic {
    my ($ref, $isVirtual) = @_;

    return {
        DESCRIPTION => $ref->{device},
        DRIVER      => $ref->{driver},
        IPADDRESS   => eval { $ref->{spec}{ip}{ipAddress} },
        IPMASK      => eval { $ref->{spec}{ip}{subnetMask} },
        MACADDR     => eval { $ref->{spec}{mac} },
        MTU         => eval { $ref->{spec}{mtu} },
        PCISLOT     => $ref->{pci},
        STATUS      => $ref->{ip}{ipAddress} ? 'Up' : 'Down',
        VIRTUALDEV  => $isVirtual,
        SPEED       => eval { $ref->{spec}{linkSpeed}{speedMb} },
    }
}

sub getNetworks {
    my ($self) = @_;

    my $ret = [];

    my $seen = {};

    foreach my $nicType (qw/vnic pnic consoleVnic/)  {
        foreach ( eval { @{ getArray( $self->{hash}[0]{config}{network}{$nicType} ) } }
                )
        {

            next if $seen->{$_->{device}}++;
            my $isVirtual = $nicType eq 'vnic'?1:0;
            push @$ret, _getNic($_, $isVirtual);
        }
    }

    my @vnic;
    eval { push @vnic, $self->{hash}[0]{config}{network}{consoleVnic} if $self->{hash}[0]{config}{network}{consoleVnic}; };
    eval { push @vnic, $self->{hash}[0]{config}{vmotion}{netConfig}{candidateVnic} if $self->{hash}[0]{config}{vmotion}{netConfig}{candidateVnic} };
    foreach (@vnic) {
        next if ref($_) ne 'HASH';
        next if $seen->{$_->{device}}++;

        push @$ret, _getNic($_, 1);
    }

    return $ret;
}

sub getStorages {
    my ($self) = @_;

    my $ret = [];
    foreach my $entry (
        @{ getArray( $self->{hash}[0]{config}{storageDevice}{scsiLun} ) } )
    {
        my $serialnumber;
        my $size;

        # TODO
        #$volumnMapping{$entry->{canonicalName}} = $entry->{deviceName};

        foreach my $altName ( @{ getArray( $entry->{alternateName} ) } ) {
            next unless ref($altName) eq 'HASH';
            next unless $altName->{namespace};
            next unless $altName->{data};
            if ( $altName->{namespace} eq 'SERIALNUM' ) {
                $serialnumber .= $_ foreach ( @{ $altName->{data} } );
            }
        }
        if ( $entry->{capacity}{blockSize} && $entry->{capacity}{block} ) {
            $size =
              int( $entry->{capacity}{blockSize} * $entry->{capacity}{block} ) /
              1000;
        }
        my $manufacturer;
        if ( $entry->{vendor} && ( $entry->{vendor} !~ /^\s*ATA\s*$/ ) ) {
            $manufacturer = $entry->{vendor};
        }
        else {
            $manufacturer = getCanonicalManufacturer( $entry->{model} );
        }

        $manufacturer =~ s/\s*(\S.*\S)\s*/$1/;

        my $model = $entry->{model};
        $model =~ s/\s*(\S.*\S)\s*/$1/;

        push @$ret, {
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

    return $ret;

}

sub getDrives {
    my ($self) = @_;

    my $ret = [];

    foreach (
        @{ getArray( $self->{hash}[0]{config}{fileSystemVolume}{mountInfo} ) } )
    {
        my $volumn;
        if ( $_->{volume}{type} && ( $_->{volume}{type} =~ /NFS/i ) ) {
            $volumn = $_->{volume}{remoteHost} . ':' . $_->{volume}{remotePath};

# TODO
#        } else {
#            $volumn = $volumnMapping{$_->{volume}{extent}{diskName}}." ".$_->{volume}{extent}{partition};
        }
        push @$ret,
          {
            SERIAL => $_->{volume}{uuid},
            TOTAL  => int( ( $_->{volume}{capacity} || 0 ) / ( 1000 * 1000 ) ),
            TYPE   => $_->{mountInfo}{path},
            VOLUMN => $volumn,
            NAME   => $_->{volume}{name},
            FILESYSTEM => lc( $_->{volume}{type} )
          };
    }

    return $ret;
}

sub getVirtualMachines {
    my ($self) = @_;

    my $ret = [];

    foreach ( @{ $self->{vms} } ) {
        my $status;
        if ( $_->[0]{summary}{runtime}{powerState} eq 'poweredOn' ) {
            $status = 'running';
        }
        elsif ( $_->[0]{summary}{runtime}{powerState} eq 'poweredOff' ) {
            $status = 'off';
        }

        my @mac;
        foreach ( @{ getArray( $_->[0]{config}{hardware}{device} ) } ) {
            push @mac, $_->{macAddress} if $_->{macAddress};
        }

        if ( !$status ) {
            print "Unknown status\n";

            #            print Dumper($_->[0]);
        }
        my $comment = eval { $_->[0]{config}{annotation} };

        # hack to preserve  annotation / comment formating
        $comment =~ s/\n/&#10;/gm if $comment;

        push @$ret,
          {
            VMID    => eval       { $_->[0]{summary}{vm} },
            NAME    => eval       { $_->[0]{name} },
            STATUS  => $status,
            UUID    => eval       { $_->[0]{summary}{config}{uuid} },
            MEMORY  => eval       { $_->[0]{summary}{config}{memorySizeMB} },
            VMTYPE  => 'VMware',
            VCPU    => eval       { $_->[0]{summary}{config}{numCpu} },
            MAC     => join( '/', @mac ),
            COMMENT => $comment
          };
    }

    return $ret;
}

1;
