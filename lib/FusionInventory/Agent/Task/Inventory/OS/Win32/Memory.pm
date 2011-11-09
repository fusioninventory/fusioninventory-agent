package FusionInventory::Agent::Task::Inventory::OS::Win32::Memory;

use strict;
use warnings;

our $runMeIfTheseChecksFailed = ["FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode"];

use FusionInventory::Agent::Task::Inventory::OS::Win32;

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

    foreach my $Properties (getWmiProperties('Win32_PhysicalMemory', qw/
        Capacity Caption Description FormFactor Removable Speed MemoryType
        SerialNumber
    /)) {
        if (defined($memoryTypeVal[$Properties->{MemoryType}])) {
# See: #1334
                next if $memoryTypeVal[$Properties->{MemoryType}] eq 'Flash';
# Ignore ROM storages (BIOS ROM)
                next if $memoryTypeVal[$Properties->{MemoryType}] eq 'ROM';
        }

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

    foreach my $Properties (getWmiProperties('Win32_PhysicalMemoryArray', qw/
        MemoryDevices SerialNumber PhysicalMemoryCorrection
    /)) {

        my $memory = $memories[$Properties->{MemoryDevices} - 1];
        if (!$memory->{SERIALNUMBER}) {
            $memory->{SERIALNUMBER} = $Properties->{SerialNumber};
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

}

1;
