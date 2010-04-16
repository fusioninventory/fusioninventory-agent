package FusionInventory::Agent::Task::Inventory::OS::Win32::Memory;

use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;

Win32::OLE-> Option(CP=>CP_UTF8);

use Win32::OLE::Enum;

use Encode qw(encode);

sub isInventoryEnabled {1}



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



    my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

    if (!$WMIServices) {
        print Win32::OLE->LastError();
    }

    my $cpt = 0;
    my @memories;

    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_PhysicalMemory' ) ) )
    {

        my $capacity = sprintf("%i",$Properties->{Capacity}/(1024*1024));
        my $caption = encode('UTF-8', $Properties->{Caption});
        my $description = encode('UTF-8', $Properties->{Description});
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





    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_PhysicalMemoryArray' ) ) )
    {
        my $memory = $memories[$Properties->{MemoryDevices} - 1];
        if (!$memory->{SERIALNUMBER}) {
            $memory->{SERIALNUMBER} =
                $Properties->{SerialNumber};
        }
        $memory->{MEMORYCORRECTION} =
            $memoryErrorProtection[$Properties->{PhysicalMemoryCorrection}];

        if ($memory->{MEMORYCORRECTION}) {
            $memory->{DESCRIPTION} .= " (".$memory->{MEMORYCORRECTION}.")";
        }
    }




    foreach my $memory (@memories) {
        $inventory->addMemory($memory);
    }




    my $fullMemory = 0;
    my $swapMemory = 0;
    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_ComputerSystem' ) ) )
    {
        $fullMemory = $Properties->{TotalPhysicalMemory};
    }
    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_OperatingSystem' ) ) )
    {
        $swapMemory = $Properties->{TotalSwapSpaceSize};
    }





    $inventory->setHardware({

            MEMORY =>  int($fullMemory/(1024*1024)),
            SWAP =>  int($swapMemory/(1024)),

            });


}

1;
