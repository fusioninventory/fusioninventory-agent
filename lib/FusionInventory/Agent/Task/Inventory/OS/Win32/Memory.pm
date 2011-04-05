package FusionInventory::Agent::Task::Inventory::OS::Win32::Memory;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;

our $runMeIfTheseChecksFailed =
    ["FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode"];

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

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    my $cpt = 0;
    my @memories;

    foreach my $Properties (getWmiProperties('Win32_PhysicalMemory', qw/
        Capacity Caption Description FormFactor Removable Speed MemoryType
        SerialNumber
    /)) {
        # Ignore ROM storages (BIOS ROM)
        my $type = $memoryTypeVal[$Properties->{MemoryType}];
        next if $type && $type eq 'ROM';

        push @memories, {
            CAPACITY     => sprintf("%i",$Properties->{Capacity}/(1024*1024)),
            CAPTION      => $Properties->{Caption},
            DESCRIPTION  => $Properties->{Description},
            FORMFACTOR   => $formFactorVal[$Properties->{FormFactor}],
            REMOVABLE    => $Properties->{Removable} ? 1 : 0,
            SPEED        => $Properties->{Speed},
            TYPE         => $memoryTypeVal[$Properties->{MemoryType}],
            NUMSLOTS     => $cpt++,
            SERIALNUMBER => $Properties->{SerialNumber}
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
