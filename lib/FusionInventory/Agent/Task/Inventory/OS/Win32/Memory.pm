package FusionInventory::Agent::Task::Inventory::OS::Win32::Memory;

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::Win32;

sub isInventoryEnabled {
# Only if dmidecode is not avalaible
    return !can_run('dmidecode');
}

my @formFactorVal = qw/
Unknown 
Other
SIP
DIP
ZIP
SOJ
Proprietary
SIMM
DIMM
TSOP
PGA
RIMM
SODIMM
SRIMM
SMD
SSMP
QFP
TQFP
SOIC
LCC
PLCC
BGA
FPBGA
LGA
/;



my @memoryTypeVal = qw/
Unknown
Other
DRAM
Synchronous DRAM
Cache DRAM
EDO
EDRAM
VRAM
SRAM
RAM
ROM
Flash
EEPROM
FEPROM
EPROM
CDRAM
3DRAM
SDRAM
SGRAM
RDRAM
DDR
DDR-2
/;

my @memoryErrorProtection = ( 
        undef,
        'Other',
        undef,
        'None',
        'Parity',
        'Single-bit ECC',
        'Multi-bit ECC',
        'CRC',
        );



sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};


    my $cpt = 0;
    my @memories;

        foreach my $Properties
            (getWmiProperties('Win32_PhysicalMemory',
qw/Capacity Caption Description FormFactor Removable Speed MemoryType
SerialNumber/)) {

        my $capacity = sprintf("%i",$Properties->{Capacity}/(1024*1024));
        my $caption = $Properties->{Caption};
        my $description = $Properties->{Description};
        my $formfactor = $formFactorVal[$Properties->{FormFactor}];
        my $removable = $Properties->{Removable}?1:0;
        my $speed = $Properties->{Speed};
        my $type = $memoryTypeVal[$Properties->{MemoryType}];
        my $numslots = $cpt++;
        my $serialnumber = $Properties->{SerialNumber};

        push @memories, {
            CAPACITY => $capacity,
                     CAPTION => $caption,
                     DESCRIPTION => $description,
                     FORMFACTOR => $formfactor,
                     REMOVABLE => $removable,
                     SPEED => $speed,
                     TYPE => $type,
                     NUMSLOTS => $numslots,
                     SERIALNUMBER => $serialnumber
        }

    }


        foreach my $Properties
            (getWmiProperties('Win32_PhysicalMemoryArray',
qw/MemoryDevices SerialNumber PhysicalMemoryCorrection/)) {

        my $memory = $memories[$Properties->{MemoryDevices} - 1];
        if (!$memory->{SERIALNUMBER}) {
            $memory->{SERIALNUMBER} =
                $Properties->{SerialNumber};
        }

        if ($Properties->{PhysicalMemoryCorrection}) {
            $memory->{MEMORYCORRECTION} =
                $memoryErrorProtection[$Properties->{PhysicalMemoryCorrection}];
        }

        if ($memory->{MEMORYCORRECTION}) {
            $memory->{DESCRIPTION} .= " (".$memory->{MEMORYCORRECTION}.")";
        }
    }




    foreach my $memory (@memories) {
        $inventory->addMemory($memory);
    }




    my $fullMemory = 0;
    my $swapMemory = 0;
    foreach my $Properties
        (getWmiProperties('Win32_ComputerSystem',
qw/TotalPhysicalMemory/)) {
        $fullMemory = $Properties->{TotalPhysicalMemory};
    }
    foreach my $Properties
        (getWmiProperties('Win32_OperatingSystem',
qw/TotalSwapSpaceSize/)) {
        $swapMemory = $Properties->{TotalSwapSpaceSize};
    }





    $inventory->setHardware({

            MEMORY =>  int($fullMemory/(1024*1024)),
            SWAP =>  int(($swapMemory || 0)/(1024)),

            });


}

1;
