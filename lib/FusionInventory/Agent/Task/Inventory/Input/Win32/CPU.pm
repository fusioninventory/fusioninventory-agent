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

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $serial;
    my $id;
    my $speed;

    my $vmsystem;

    # http://forge.fusioninventory.org/issues/379
    my(@osver) = Win32::GetOSVersion();
    my $isWin2003 = ($osver[4] == 2 && $osver[1] == 5 && $osver[2] == 2);

    my $dmidecodeCpu = getCpusFromDmidecode();

    my $cpuId = 0;
    foreach my $object (getWmiObjects(
        class      => 'Win32_Processor',
        properties => [ qw/NumberOfCores ProcessorId MaxClockSpeed/ ]
    )) {

        # the CPU description in WMI is false, we use the registry instead
        # Hardware\Description\System\CentralProcessor\1
        # thank you Nicolas Richard 
        my $info = getRegistryValue(
            path   => "HKEY_LOCAL_MACHINE/Hardware/Description/System/CentralProcessor/$cpuId",
            logger => $logger
        );

#        my $cache = $object->{L2CacheSize}+$object->{L3CacheSize};
        my $core = $object->{NumberOfCores};
        my $description = $info->{Identifier};
        my $name = $info->{ProcessorNameString};
        my $manufacturer = $info->{VendorIdentifier};
        my $id = $dmidecodeCpu->[$cpuId]->{ID} || $object->{ProcessorId};
        my $serial = $dmidecodeCpu->[$cpuId]->{SERIAL};
        my $speed = $dmidecodeCpu->[$cpuId]->{SPEED} || $object->{MaxClockSpeed};

        if ($manufacturer) {
            $manufacturer =~ s/Genuine//;
            $manufacturer =~ s/(TMx86|TransmetaCPU)/Transmeta/;
            $manufacturer =~ s/CyrixInstead/Cyrix/;
            $manufacturer=~ s/CentaurHauls/VIA/;
        }
        if ($serial) {
            $serial =~ s/\s//g;
        }

        if ($name) {
            $name =~ s/^\s+//;
            $name =~ s/\s+$//;

            $vmsystem = "QEMU"if $name =~ /QEMU/i;

            if ($name =~ /([\d\.]+)s*(GHZ)/i) {
                $speed = {
                    ghz => 1000,
                    mhz => 1,
                }->{lc($2)}*$1;
            }

        }

        $inventory->addEntry(
            section => 'CPUS',
            entry   => {
                CORE         => $core,
                DESCRIPTION  => $description,
                NAME         => $name,
                MANUFACTURER => $manufacturer,
                SERIAL       => $serial,
                SPEED        => $speed,
                ID           => $id
            }
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
