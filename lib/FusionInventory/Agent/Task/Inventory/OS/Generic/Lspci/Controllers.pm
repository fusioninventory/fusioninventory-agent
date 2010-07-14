package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Controllers;
use strict;
use warnings;

use FusionInventory::Agent::Tools;

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
                'VERSION'       => $version,
            });
            $driver = $name = $pciclass = $pciid = undef;
            $pcislot = $manufacturer = undef;
            $type = $pcisubsystemid = undef;
        }
    }

}

1;
