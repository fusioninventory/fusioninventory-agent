package FusionInventory::Agent::Task::Inventory::Input::Win32::CPU;

use strict;
use warnings;

use English qw(-no_match_vars);
use Win32;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @dmidecodeCpu = getCpusFromDmidecode();

    my $vmsystem;
    my $cpuId = 0;

    foreach my $object (getWmiObjects(
        class      => 'Win32_Processor',
        properties => [ qw/NumberOfCores ProcessorId MaxClockSpeed/ ]
    )) {

        # the CPU description in WMI is false, we use the registry instead
        # Hardware\Description\System\CentralProcessor\1
        # thank you Nicolas Richard 
        my $registryInfo = getRegistryValue(
            path   => "HKEY_LOCAL_MACHINE/Hardware/Description/System/CentralProcessor/$cpuId",
            logger => $logger
        );

        my $dmidecodeInfo = $dmidecodeCpu[$cpuId];

        my $cpu = {
            CORE         => $dmidecodeInfo->{CORE} || $object->{NumberOfCores},
            THREAD       => $dmidecodeInfo->{THREAD},
            DESCRIPTION  => $registryInfo->{Identifier},
            NAME         => $registryInfo->{ProcessorNameString},
            MANUFACTURER => $registryInfo->{VendorIdentifier},
            SERIAL       => $dmidecodeInfo->{SERIAL},
            SPEED        => $dmidecodeInfo->{SPEED} || $object->{MaxClockSpeed},
            ID           => $dmidecodeInfo->{ID} || $object->{ProcessorId}
        };

        # Some information are missing on Win2000
        if (!$cpu->{NAME}) {
            $cpu->{NAME} = $ENV{PROCESSOR_IDENTIFIER};
            if ($cpu->{NAME} =~ s/,\s(\S+)$//) {
                $cpu->{MANUFACTURER} = $1;
            }
        }

        if ($cpu->{MANUFACTURER}) {
            $cpu->{MANUFACTURER} =~ s/Genuine//;
            $cpu->{MANUFACTURER} =~ s/(TMx86|TransmetaCPU)/Transmeta/;
            $cpu->{MANUFACTURER} =~ s/CyrixInstead/Cyrix/;
            $cpu->{MANUFACTURER} =~ s/CentaurHauls/VIA/;
        }

        if ($cpu->{SERIAL}) {
            $cpu->{SERIAL} =~ s/\s//g;
        }

        if ($cpu->{NAME}) {
            $cpu->{NAME} =~ s/^\s+//;
            $cpu->{NAME} =~ s/\s+$//;

            $vmsystem = "QEMU" if $cpu->{NAME} =~ /QEMU/i;

            if ($cpu->{NAME} =~ /([\d\.]+)s*(GHZ)/i) {
                $cpu->{SPEED} = {
                    ghz => 1000,
                    mhz => 1,
                }->{lc($2)} * $1;
            }
        }

        $inventory->addEntry(
            section => 'CPUS',
            entry   => $cpu
        );

        $cpuId++;
    }

    if ($vmsystem) {
        $inventory->setHardware ({
            VMSYSTEM => $vmsystem 
        });
    }
}

1;
