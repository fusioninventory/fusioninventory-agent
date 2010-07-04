package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Controllers;
use strict;
use warnings;

# Retrieve information from the pciid file
sub getInfoFromPciIds {
    my ($params) = @_;

    my $config = $params->{config};
    my $logger = $params->{logger};
    my $pciclass = $params->{pciclass};
    my $pciid = $params->{pciid};
    my $pcisubsystemid = $params->{pcisubsystemid};

    return unless $pciid;

    my ($vendorId, $deviceId) = split (/:/, $pciid);
    my ($subVendorId, $subDeviceId) = split (/:/, $pcisubsystemid || '');
    my $deviceName;
    my $subDeviceName;
    my $classId;
    my $subClassId;

    if ($pciclass && $pciclass =~ /^(\S\S)(\S\S)$/) {
        $classId = $1;
        $subClassId = $2;
    }

    return {} unless $vendorId;

    my %ret;
    my %current;
    if (!open PCIIDS, "<",$config->{'share-dir'}.'/pci.ids') {
        $logger->error("Failed to open ".$config->{'share-dir'}.'/pci.ids');
        return;
    }
    foreach (<PCIIDS>) {
        next if /^#/;

        if (/^(\S{4})\s+(.*)/) { # Vendor ID
            $current{classId} = '';
            $current{vendorId} = lc($1);
            $current{vendorName} = $2;
            $current{deviceName} = '';
            $current{subVendorId} = '';
            $current{subDeviceId} = '';

# information found in the previous section
#            return \%ret if keys %ret;
        } elsif (/^\t(\S{4})\s+(.*)/) { # Device ID
            $current{deviceId} = lc($1);
            $current{deviceName} = $2;
            $current{subVendorId} = '';
            $current{subDeviceId} = '';
        } elsif (/^\t\t(\S{4})\s(\S{4})\s(.*)/) { # Subdevice ID
            $current{subVendorId} = lc($1);
            $current{subDeviceId} = lc($2);
            $current{subDeviceName} = $3;
        } elsif (/^C\s(\S{2})\s\s(.*)/) { # Class ID
            $current{vendorId} = '';
            $current{vendorName} = '';
            $current{deviceName} = '';
            $current{subVendorId} = '';
            $current{subDeviceId} = '';
            $current{classId} = $1;
            $current{className} = $2;
        } elsif (/^\t(\S{2})\s\s(.*)/) { # SubClass ID
            $current{subClassId} = $1;
            $current{subClassName} = $2;
        } 

        if (!$ret{subDeviceName} && $current{vendorName} && $current{deviceName}) {
            if ($vendorId eq $current{vendorId}) {
                $ret{vendorName} = $current{vendorName};
                if ($deviceId eq $current{deviceId}) {
                    $ret{deviceName} = $current{deviceName};
                    $ret{fullName} = $current{deviceName};

                    if ($subVendorId && $subDeviceId) {
                        if ($subVendorId eq $current{subVendorId}) {
                            if ($subDeviceId eq $current{subDeviceId}) {
                                $ret{subDeviceName} = $current{subDeviceName};
                                $ret{fullName} =$current{subDeviceName};
                            }
                        }
                    }
                }
            }
        }
        if (defined($current{classId}) && $classId && ($classId eq $current{classId})) {
            $ret{className} = $current{className};
            $ret{fullClassName} = $current{className};
            if ($subClassId eq $current{subClassId}) {
                $ret{subClassName} = $current{subClassName};
                $ret{fullClassName} = $current{subClassName};
            }
        }
    }

    return \%ret;
}

sub isInventoryEnabled {
    return can_run("lspci");
}

sub doInventory {
    my $params = shift;
    my $config = $params->{config};
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my $driver;
    my $name;
    my $manufacturer;
    my $pciclass;
    my $pciid;
    my $pcislot;
    my $pcisubsystemid;
    my $type;
    my $version;

    foreach(`lspci -vvv -nn`){
        if (/^(\S+)\s+(\w+.*?):\s(.*)/) {
            $pcislot = $1;
            $name = $2;
            $manufacturer = $3;

            if ($name =~ s/^([a-f\d]+)$//i) {
                $pciclass = $1;
            } elsif ($name =~ s/\[([a-f\d]+)\]$//i) {
                $pciclass = $1;
            } elsif ($name =~ s/Class ([a-f\d]+)$//i) {
                $pciclass = $1;
            }

            if ($manufacturer =~ s/\s\(rev\s(\S+)\)//) {
                $version = $1;
            }
            $manufacturer =~ s/\ *$//; # clean up the end of the string
            $manufacturer =~ s/\s+\(prog-if \d+ \[.*?\]\)$//; # clean up the end of the string
            $manufacturer =~ s/\s+\(prog-if \d+\)$//;

            if ($manufacturer =~ s/([a-f\d]{4}:[a-f\d]{4})//i) {
                $pciid = $1;
            }

            $name =~ s/\s+$//; # Drop the trailing whitespace
        }
        if ($pcislot && /^\s+Kernel driver in use: (\w+)/) {
            $driver = $1;
        }

        if (/Subsystem:\s+([a-f\d]{4}:[a-f\d]{4})/i) {
            $pcisubsystemid = $1;
        }

        if ($pcislot && /^$/) {

            my $info = getInfoFromPciIds ({
                    config => $config,
                    logger => $logger,
                    pciclass => $pciclass,
                    pciid => $pciid,
                    pcisubsystemid => $pcisubsystemid,
                });


            $inventory->addController({
                'CAPTION'       => $info->{deviceName},
                'DRIVER'        => $driver,
                'NAME'          => $info->{fullName} || $name,
                'MANUFACTURER'  => $info->{vendorName} || $manufacturer,
                'PCICLASS'      => $pciclass,
                'PCIID'         => $pciid,
                'PCISUBSYSTEMID'=> $pcisubsystemid,
                'PCISLOT'       => $pcislot,
                'TYPE'          => $info->{fullClassName},
                'VERSION'           => $version,
            });
            $driver = $name = $pciclass = $pciid = undef;
            $pcislot = $manufacturer = undef;
            $type = $pcisubsystemid = undef;
        }
    }

}

1;
