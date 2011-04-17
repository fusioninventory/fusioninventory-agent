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
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $cpt = 0;
    my @memories;

    foreach my $object (getWmiObjects(
        class      => 'Win32_PhysicalMemory',
        properties => [ qw/
            Capacity Caption Description FormFactor Removable Speed MemoryType
            SerialNumber
        / ]
    )) {
        # Ignore ROM storages (BIOS ROM)
        my $type = $memoryTypeVal[$object->{MemoryType}];
        next if $type && $type eq 'ROM';

        $object->{Capacity} = $object->{Capacity} / (1024 * 1024)
            if $object->{Capacity};

        push @memories, {
            CAPACITY     => $object->{Capacity},
            CAPTION      => $object->{Caption},
            DESCRIPTION  => $object->{Description},
            FORMFACTOR   => $formFactorVal[$object->{FormFactor}],
            REMOVABLE    => $object->{Removable} ? 1 : 0,
            SPEED        => $object->{Speed},
            TYPE         => $memoryTypeVal[$object->{MemoryType}],
            NUMSLOTS     => $cpt++,
            SERIALNUMBER => $object->{SerialNumber}
        }
    }

    foreach my $object (getWmiObjects(
        class      => 'Win32_PhysicalMemoryArray', 
        properties => [ qw/
            MemoryDevices SerialNumber PhysicalMemoryCorrection
        / ]
    )) {

        my $memory = $memories[$object->{MemoryDevices} - 1];
        if (!$memory->{SERIALNUMBER}) {
            $memory->{SERIALNUMBER} = $object->{SerialNumber};
        }

        if ($object->{PhysicalMemoryCorrection}) {
            $memory->{MEMORYCORRECTION} =
                $memoryErrorProtection[$object->{PhysicalMemoryCorrection}];
        }

        if ($memory->{MEMORYCORRECTION}) {
            $memory->{DESCRIPTION} .= " (".$memory->{MEMORYCORRECTION}.")";
        }
    }

    foreach my $memory (@memories) {
        $inventory->addEntry({
            section => 'MEMORIES',
            entry   => $memory
        });
    }

}

1;
