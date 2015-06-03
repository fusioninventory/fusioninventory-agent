#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Tools::Generic;

my %dmidecode_tests = (
    'freebsd-6.2' =>  {
        6 => [
            {
                'Installed Size' => '512 MB (Single-bank Connection)',
                'Socket Designation' => 'A0',
                'Type' => 'Other',
                'Error Status' => 'OK',
                'Enabled Size' => '512 MB (Single-bank Connection)',
                'Current Speed' => '37 ns',
                'Bank Connections' => '0'
            }
        ],
        32 => [
            {
                 'Status' => 'No errors detected'
            }
        ],
        3 => [
            {
                'Type' => 'Desktop',
                'OEM Information' => '0x00000000',
            }
        ],
        7 => [
            {
                'Installed Size' => '32 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'Internal Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'Installed SRAM Type' => 'Synchronous',
                'Associativity' => '4-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '32 KB'
            },
            {
                'Installed Size' => '0 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'Internal Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'Installed SRAM Type' => 'Synchronous',
                'Location' => 'External',
                'Maximum Size' => '0 KB'
            }
        ],
        9 => [
            {
                ID             => '1',
                'Length' => 'Long',
                'Designation' => 'PCI0',
                'Type' => '32-bit PCI',
                'Current Usage' => 'Available'
            }
        ],
        17 => [
            {
                 'Part Number' => 'None',
                 'Serial Number' => 'None',
                 'Type Detail' => 'None',
                 'Set' => 'None',
                 'Size' => '512 MB',
                 'Manufacturer' => 'None',
                 'Bank Locator' => 'Bank0/1',
                 'Array Handle' => '0x0013',
                 'Asset Tag' => 'None',
                 'Locator' => 'A0',
                 'Error Information Handle' => 'Not Provided',
                 'Form Factor' => 'DIMM'
            }
        ],
        2 => [
            {
                'Product Name' => 'CN700-8237R'
            }
        ],
        20 => [
            {
                 'Memory Array Mapped Address Handle' => '0x0015',
                 'Range Size' => '512 MB',
                 'Physical Device Handle' => '0x0014',
                 'Partition Row Position' => '1',
                 'Starting Address' => '0x00000000000',
                 'Ending Address' => '0x0001FFFFFFF'
            }
        ],
        8 => [
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'PRIMARY IDE',
                'Internal Connector Type' => 'On Board IDE'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'SECONDARY IDE',
                'Internal Connector Type' => 'On Board IDE'
            },
            {
                'Port Type' => '8251 FIFO Compatible',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'FDD',
                'Internal Connector Type' => 'On Board Floppy'
            },
            {
                'Port Type' => 'Serial Port 16450 Compatible',
                'External Connector Type' => 'DB-9 male',
                'Internal Reference Designator' => 'COM1',
                'Internal Connector Type' => '9 Pin Dual Inline (pin 10 cut)'
            },
            {
                'Port Type' => 'Serial Port 16450 Compatible',
                'External Connector Type' => 'DB-9 male',
                'Internal Reference Designator' => 'COM2',
                'Internal Connector Type' => '9 Pin Dual Inline (pin 10 cut)'
            },
            {
                'Port Type' => 'Parallel Port ECP/EPP',
                'External Connector Type' => 'DB-25 female',
                'Internal Reference Designator' => 'LPT1',
                'Internal Connector Type' => 'DB-25 female'
            },
            {
                'Port Type' => 'Keyboard Port',
                'External Connector Type' => 'PS/2',
                'Internal Reference Designator' => 'Keyboard',
                'Internal Connector Type' => 'PS/2'
            },
            {
                'Port Type' => 'Mouse Port',
                'External Connector Type' => 'PS/2',
                'Internal Reference Designator' => 'PS/2 Mouse',
                'Internal Connector Type' => 'PS/2'
            },
            {
                'External Reference Designator' => 'USB0',
                'Port Type' => 'USB',
                'External Connector Type' => 'Other',
                'Internal Connector Type' => 'None'
            }
        ],
        1 => [
            {
                'Wake-up Type' => 'Power Switch'
            }
        ],
        4 => [
            {
                ID             => 'A9 06 00 00 FF BB C9 A7',
                'Socket Designation' => 'NanoBGA2',
                'Status' => 'Populated, Enabled',
                'Max Speed' => '2000 MHz',
                'External Clock' => '100 MHz',
                'Family' => 'Other',
                'Current Speed' => '2000 MHz',
                'L2 Cache Handle' => '0x0007',
                'Type' => 'Central Processor',
                'Version' => 'VIA C7',
                'Upgrade' => 'None',
                'L1 Cache Handle' => '0x0006',
                'Voltage' => '1.1 V',
                'Manufacturer' => 'VIA',
                'L3 Cache Handle' => 'Not Provided'
            }
        ],
        19 => [
            {
                 'Range Size' => '512 MB',
                 'Partition Width' => '0',
                 'Starting Address' => '0x00000000000',
                 'Physical Array Handle' => '0x0013',
                 'Ending Address' => '0x0001FFFFFFF'
            }
        ],
        16 => [
            {
                 'Number Of Devices' => '1',
                 'Error Correction Type' => 'None',
                 'Error Information Handle' => 'Not Provided',
                 'Location' => 'System Board Or Motherboard',
                 'Maximum Capacity' => '512 MB',
                 'Use' => 'System Memory'
            }
        ],
        13 => [
            {
                 'Installable Languages' => '3',
                 'Currently Installed Language' => 'n|US|iso8859-1'
            }
        ],
        5 => [
            {
                'Error Detecting Method' => 'None',
                'Maximum Memory Module Size' => '1024 MB',
                'Enabled Error Correcting Capabilities' => 'None',
                'Associated Memory Slots' => '1',
                'Current Interleave' => 'Four-way Interleave',
                'Memory Module Voltage' => '2.9 V',
                'Supported Interleave' => 'Eight-way Interleave',
                'Maximum Total Memory Size' => '1024 MB'
            }
        ]
    },
    'freebsd-8.1' => {
        32 => [
            {
                'Status' => 'No errors detected'
            }
        ],
        11 => [
            {
                'String 1' => '$HP$',
                'String 3' => 'ABS 70/71 79 7A 7B 7C',
                'String 2' => 'LOC#ABF',
                'String 4' => 'CNB1 039C130000241310000020000'
            }
        ],
        21 => [
            {
                'Type' => 'Touch Pad',
                'Buttons' => '4',
                'Interface' => 'PS/2'
            }
        ],
        7 => [
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Installed Size' => '3072 kB',
                'Operational Mode' => 'Write Through',
                'Socket Designation' => 'L3 Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 3',
                'Installed SRAM Type' => 'Synchronous',
                'System Type' => 'Unified',
                'Associativity' => 'Other',
                'Location' => 'Internal',
                'Maximum Size' => '3072 kB'
            },
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Installed Size' => '32 kB',
                'Operational Mode' => 'Write Through',
                'Socket Designation' => 'L1 Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'Installed SRAM Type' => 'Synchronous',
                'System Type' => 'Data',
                'Associativity' => '8-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '32 kB'
            },
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Installed Size' => '256 kB',
                'Operational Mode' => 'Write Through',
                'Socket Designation' => 'L2 Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'Installed SRAM Type' => 'Synchronous',
                'System Type' => 'Unified',
                'Associativity' => '8-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '256 kB'
            },
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Installed Size' => '32 kB',
                'Operational Mode' => 'Write Through',
                'Socket Designation' => 'L1 Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'Installed SRAM Type' => 'Synchronous',
                'System Type' => 'Instruction',
                'Associativity' => '4-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '32 kB'
            }
        ],
        17 => [
            {
                'Part Number' => 'HMT125S6BFR8C-H9',
                'Serial Number' => '1A1541FC',
                'Type Detail' => 'Synchronous',
                'Set' => 'None',
                'Speed' => '1067 MHz',
                'Size' => '2048 MB',
                'Manufacturer' => 'Hynix',
                'Bank Locator' => 'BANK 0',
                'Array Handle' => '0x001B',
                'Data Width' => '64 bits',
                'Total Width' => '64 bits',
                'Locator' => 'Bottom - Slot 1',
                'Error Information Handle' => '0x001D',
                'Form Factor' => 'SODIMM'
            },
            {
                'Part Number' => 'HMT125S6BFR8C-H9',
                'Serial Number' => '1A554239',
                'Type Detail' => 'Synchronous',
                'Set' => 'None',
                'Speed' => '1067 MHz',
                'Size' => '2048 MB',
                'Manufacturer' => 'Hynix',
                'Bank Locator' => 'BANK 1',
                'Array Handle' => '0x001B',
                'Data Width' => '64 bits',
                'Total Width' => '64 bits',
                'Locator' => 'Bottom - Slot 2',
                'Error Information Handle' => '0x0020',
                'Form Factor' => 'SODIMM'
            }
        ],
        2 => [
            {
                'Product Name' => '3659',
                'Chassis Handle' => '0x0003',
                'Serial Number' => 'CNF01207X6',
                'Asset Tag' => 'Base Board Asset Tag',
                'Version' => '32.25',
                'Type' => 'Motherboard',
                'Manufacturer' => 'Hewlett-Packard',
                'Location In Chassis' => 'Base Board Chassis Location',
                'Contained Object Handles' => '0'
            }
        ],
        22 => [
            {
                'Design Capacity' => '4400 mWh',
                'Maximum Error' => '1%',
                'OEM-specific Information' => '0xFFFFFFFF',
                'Chemistry' => 'Lithium Ion',
                'SBDS Manufacture Date' => '2010-01-15',
                'Design Voltage' => '10800 mV',
                'Location' => 'In the back',
                'Manufacturer' => 'LGC-LGC',
                'Name' => 'EV06047',
                'SBDS Version' => '3.1',
                'SBDS Serial Number' => '61E6'
            }
        ],
        1 => [
            {
                'Product Name' => 'HP Pavilion dv6 Notebook PC',
                'Family' => '103C_5335KV',
                'Serial Number' => 'CNF01207X6',
                'Version' => '039C130000241310000020000',
                'Wake-up Type' => 'Power Switch',
                'SKU Number' => 'WA017EA#ABF',
                'Manufacturer' => 'Hewlett-Packard',
                'UUID' => '30464E43-3231-3730-5836-C80AA93F35FA'
            }
        ],
        18 => [
            {
                'Type' => 'OK',
            },
            {
                'Type' => 'OK',
            },
            {
                'Type' => 'OK',
            }
        ],
        0 => [
            {
                'Version' => 'F.1C',
                'BIOS Revision' => '15.28',
                'Firmware Revision' => '50.37',
                'ROM Size' => '1536 kB',
                'Release Date' => '05/17/2010',
                'Vendor' => 'Hewlett-Packard'
            }
        ],
        16 => [
            {
                'Number Of Devices' => '2',
                'Error Correction Type' => 'None',
                'Error Information Handle' => 'No Error',
                'Location' => 'System Board Or Motherboard',
                'Maximum Capacity' => '8 GB',
                'Use' => 'System Memory'
            }
        ],
        3 => [
            {
                'Height' => 'Unspecified',
                'Power Supply State' => 'Safe',
                'Serial Number' => 'None',
                'Thermal State' => 'Safe',
                'Contained Elements' => '0',
                'Type' => 'Notebook',
                'Number Of Power Cords' => '1',
                'Security Status' => 'None',
                'Manufacturer' => 'Hewlett-Packard',
                'Boot-up State' => 'Safe',
                'OEM Information' => '0x00000113'
            }
        ],
        9 => [
            {
                'Bus Address' => '0000:00:1f.7',
                'Length' => 'Other',
                'Designation' => 'J5C1',
                'Type' => 'x16 PCI Express x16',
                'Current Usage' => 'Available'
            },
            {
                'Bus Address' => '0000:00:1f.7',
                'Length' => 'Other',
                'Designation' => 'J6C1',
                'Type' => 'x1 PCI Express x1',
                'Current Usage' => 'Available'
            },
            {
                'Bus Address' => '0000:00:1f.7',
                'Length' => 'Other',
                'Designation' => 'J6C2',
                'Type' => 'x1 PCI Express x1',
                'Current Usage' => 'Available'
            },
            {
                'Bus Address' => '0000:00:1f.7',
                'Length' => 'Other',
                'Designation' => 'J6D2',
                'Type' => 'x1 PCI Express x1',
                'Current Usage' => 'Available'
            },
            {
                'Bus Address' => '0000:00:1f.7',
                'Length' => 'Other',
                'Designation' => 'J7C1',
                'Type' => 'x1 PCI Express x1',
                'Current Usage' => 'Available'
            },
            {
                'Bus Address' => '0000:00:1f.7',
                'Length' => 'Other',
                'Designation' => 'J7D2',
                'Type' => 'x1 PCI Express x1',
                'Current Usage' => 'Available'
            },
            {
                'Bus Address' => '0000:00:1f.7',
                'Length' => 'Other',
                'Designation' => 'J8C2',
                'Type' => 'x16 PCI Express x16',
                'Current Usage' => 'Available'
            },
            {
                'Bus Address' => '0000:00:1f.7',
                'Length' => 'Other',
                'Designation' => 'J8C1',
                'Type' => 'x1 PCI Express x1',
                'Current Usage' => 'Available'
            }
        ],
        12 => [
            {
                'Option 2' => 'String2 for Type12 Equipment Manufacturer',
                'Option 3' => 'String3 for Type12 Equipment Manufacturer',
                'Option 1' => 'String1 for Type12 Equipment Manufacturer',
                'Option 4' => 'String4 for Type12 Equipment Manufacturer'
            }
        ],
        41 => [
            {
                'Bus Address' => '0000:01:00.0',
                'Type' => 'Video',
                'Reference Designation' => 'nVidia Video Graphics Controller',
                'Type Instance' => '1',
                'Status' => 'Enabled'
            },
            {
                'Bus Address' => '0000:02:00.0',
                'Type' => 'Other',
                'Reference Designation' => 'Puma Peak 2x2 abgn (MA) IntelR Wi-Fi Link 6200',
                'Type Instance' => '1',
                'Status' => 'Enabled'
            }
        ],
        20 => [
            {
                'Range Size' => '2 GB',
                'Partition Row Position' => '2',
                'Starting Address' => '0x00000000000',
                'Memory Array Mapped Address Handle' => '0x0023',
                'Physical Device Handle' => '0x001C',
                'Interleaved Data Depth' => '1',
                'Interleave Position' => '1',
                'Ending Address' => '0x0007FFFFFFF'
            },
            {
                'Range Size' => '2 GB',
                'Partition Row Position' => '2',
                'Starting Address' => '0x00000000000',
                'Memory Array Mapped Address Handle' => '0x0023',
                'Physical Device Handle' => '0x001F',
                'Interleaved Data Depth' => '1',
                'Interleave Position' => '2',
                'Ending Address' => '0x0007FFFFFFF'
            }
        ],
        15 => [
            {
                'Access Address' => '0x0000',
                'Access Method' => 'General-purpose non-volatile data functions',
                'Data Start Offset' => '0x0000',
                'Status' => 'Valid, Not Full',
                'Supported Log Type Descriptors' => '3',
                'Descriptor 1' => 'POST memory resize',
                'Descriptor 3' => 'Log area reset/cleared',
                'Data Format 1' => 'None',
                'Area Length' => '0 bytes',
                'Header Start Offset' => '0x0000',
                'Header Format' => 'OEM-specific',
                'Change Token' => '0x12345678',
                'Data Format 2' => 'POST results bitmap',
                'Data Format 3' => 'None',
                'Descriptor 2' => 'POST error'
            }
        ],
        4 => [
            {
                ID             => '52 06 02 00 FF FB EB BF',
                'Socket Designation' => 'CPU',
                'Status' => 'Populated, Enabled',
                'Max Speed' => '2266 MHz',
                'Family' => 'Core 2 Duo',
                'Thread Count' => '4',
                'Current Speed' => '2266 MHz',
                'L2 Cache Handle' => '0x0019',
                'Type' => 'Central Processor',
                'Signature' => 'Type 0, Family 6, Model 37, Stepping 2',
                'L1 Cache Handle' => '0x001A',
                'Manufacturer' => 'Intel(R) Corporation',
                'Core Enabled' => '2',
                'External Clock' => '1066 MHz',
                'Asset Tag' => 'FFFF',
                'Version' => 'Intel(R) Core(TM) i5 CPU M 430 @ 2.27GHz',
                'Upgrade' => 'ZIF Socket',
                'Core Count' => '2',
                'Voltage' => '0.0 V',
                'L3 Cache Handle' => '0x0017'
            }
        ],
        19 => [
            {
                'Range Size' => '4 GB',
                'Partition Width' => '0',
                'Starting Address' => '0x00000000000',
                'Physical Array Handle' => '0x001B',
                'Ending Address' => '0x000FFFFFFFF'
            }
        ],
        10 => [
            {
                'Type' => 'Video',
                'Status' => 'Enabled',
                'Description' => 'Video Graphics Controller'
            },
            {
                'Type' => 'Ethernet',
                'Status' => 'Enabled',
                'Description' => 'Realtek Lan Controller'
            }
        ]
    },
    'linux-2.6' => {
     32 => [
            {
                 'Status' => 'No errors detected'
            }
        ],
        11 => [
            {
                 'String 1' => 'Dell System',
                 'String 3' => '13[PP11L]',
                 'String 2' => '5[0003]'
            }
        ],
        21 => [
            {
                 'Type' => 'Touch Pad',
                 'Buttons' => '2',
                 'Interface' => 'Bus Mouse'
            }
        ],
        7 => [
            {
                'Error Correction Type' => 'None',
                'Installed Size' => '8 KB',
                'Operational Mode' => 'Write Back',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'System Type' => 'Data',
                'Associativity' => '4-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '8 KB'
            },
            {
                'Error Correction Type' => 'None',
                'Installed Size' => '2048 KB',
                'Operational Mode' => 'Varies With Memory Address',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'Installed SRAM Type' => 'Pipeline Burst',
                'System Type' => 'Unified',
                'Speed' => '15 ns',
                'Associativity' => 'Other',
                'Location' => 'Internal',
                'Maximum Size' => '2048 KB'
            }
        ],
        17 => [
            {
                 'Serial Number' => '02132010',
                 'Data Width' => '64 bits',
                 'Array Handle' => '0x1000',
                 'Type Detail' => 'Synchronous',
                 'Set' => 'None',
                 'Total Width' => '64 bits',
                 'Type' => 'DDR',
                 'Speed' => '533 MHz (1.9 ns)',
                 'Size' => '1024 MB',
                 'Error Information Handle' => 'Not Provided',
                 'Locator' => 'DIMM_A',
                 'Manufacturer' => 'C100000000000000',
                 'Form Factor' => 'DIMM'
            },
            {
                 'Serial Number' => '02132216',
                 'Data Width' => '64 bits',
                 'Array Handle' => '0x1000',
                 'Type Detail' => 'Synchronous',
                 'Set' => 'None',
                 'Total Width' => '64 bits',
                 'Type' => 'DDR',
                 'Speed' => '533 MHz (1.9 ns)',
                 'Size' => '1024 MB',
                 'Error Information Handle' => 'Not Provided',
                 'Locator' => 'DIMM_B',
                 'Manufacturer' => 'C100000000000000',
                 'Form Factor' => 'DIMM'
            }
        ],
        2 => [
            {
                'Product Name' => '0XD762',
                'Serial Number' => '.D8XD62J.CN4864363E7491.',
                'Manufacturer' => 'Dell Inc.'
            }
        ],
        22 => [
            {
                 'Design Capacity' => '48000 mWh',
                 'Maximum Error' => '3%',
                 'OEM-specific Information' => '0x00000001',
                 'Design Voltage' => '11100 mV',
                 'SBDS Manufacture Date' => '2006-03-11',
                 'SBDS Chemistry' => 'LION',
                 'Location' => 'Sys. Battery Bay',
                 'Manufacturer' => 'Samsung SDI',
                 'Name' => 'DELL C129563',
                 'SBDS Version' => '1.0',
                 'SBDS Serial Number' => '7734'
            }
        ],
        1 => [
            {
                'Wake-up Type' => 'Power Switch',
                'Product Name' => 'Latitude D610',
                'Serial Number' => 'D8XD62J',
                'Manufacturer' => 'Dell Inc.',
                'UUID' => '44454C4C-3800-1058-8044-C4C04F36324A'
            }
        ],
        0 => [
            {
                'Runtime Size' => '64 kB',
                'Version' => 'A06',
                'Address' => '0xF0000',
                'ROM Size' => '576 kB',
                'Release Date' => '10/02/2005',
                'Vendor' => 'Dell Inc.'
            }
        ],
        16 => [
            {
                 'Number Of Devices' => '2',
                 'Error Correction Type' => 'None',
                 'Error Information Handle' => 'Not Provided',
                 'Location' => 'System Board Or Motherboard',
                 'Maximum Capacity' => '4 GB',
                 'Use' => 'System Memory'
            }
        ],
        13 => [
            {
                 'Installable Languages' => '1',
                 'Currently Installed Language' => 'en|US|iso8859-1'
            }
        ],
        27 => [
            {
                 'Type' => 'Fan',
                 'Status' => 'OK',
                 'OEM-specific Information' => '0x0000DD00'
            }
        ],
        28 => [
            {
                 'Status' => 'OK',
                 'OEM-specific Information' => '0x0000DC00',
                 'Maximum Value' => '127.0 deg C',
                 'Resolution' => '1.000 deg C',
                 'Location' => 'Processor',
                 'Tolerance' => '0.5 deg C',
                 'Description' => 'CPU Internal Temperature'
            }
        ],
        3 => [
            {
                'Type' => 'Portable',
                'Power Supply State' => 'Safe',
                'Security Status' => 'None',
                'Serial Number' => 'D8XD62J',
                'Thermal State' => 'Safe',
                'Boot-up State' => 'Safe',
                'Manufacturer' => 'Dell Inc.'
            }
        ],
        9 => [
            {
                ID             => 'Adapter 0, Socket 0',
                'Length' => 'Other',
                'Designation' => 'PCMCIA 0',
                'Type' => '32-bit PC Card (PCMCIA)',
                'Current Usage' => 'Available'
            },
            {
                'Length' => 'Other',
                'Designation' => 'MiniPCI',
                'Type' => '32-bit Other',
                'Current Usage' => 'Available'
            }
        ],
        20 => [
            {
                 'Memory Array Mapped Address Handle' => '0x1300',
                 'Range Size' => '640 kB',
                 'Physical Device Handle' => '0x1100',
                 'Partition Row Position' => '1',
                 'Starting Address' => '0x00000000000',
                 'Ending Address' => '0x0000009FFFF'
            },
            {
                 'Memory Array Mapped Address Handle' => '0x1301',
                 'Range Size' => '1023 MB',
                 'Physical Device Handle' => '0x1100',
                 'Partition Row Position' => '1',
                 'Starting Address' => '0x00000100000',
                 'Ending Address' => '0x0003FFFFFFF'
            },
            {
                 'Memory Array Mapped Address Handle' => '0x1301',
                 'Range Size' => '1 GB',
                 'Physical Device Handle' => '0x1101',
                 'Partition Row Position' => '1',
                 'Starting Address' => '0x00040000000',
                 'Ending Address' => '0x0007FFFFFFF'
            }
        ],
        8 => [
            {
                'Port Type' => 'Parallel Port PS/2',
                'External Connector Type' => 'DB-25 female',
                'Internal Reference Designator' => 'PARALLEL',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Serial Port 16550A Compatible',
                'External Connector Type' => 'DB-9 male',
                'Internal Reference Designator' => 'SERIAL1',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'Internal Reference Designator' => 'USB',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Video Port',
                'External Connector Type' => 'DB-15 female',
                'Internal Reference Designator' => 'MONITOR',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'Infrared',
                'Internal Reference Designator' => 'IrDA',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Modem Port',
                'External Connector Type' => 'RJ-11',
                'Internal Reference Designator' => 'Modem',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Network Port',
                'External Connector Type' => 'RJ-45',
                'Internal Reference Designator' => 'Ethernet',
                'Internal Connector Type' => 'None'
            }
        ],
        4 => [
            {
                ID             => 'D8 06 00 00 FF FB E9 AF',
                'Socket Designation' => 'Microprocessor',
                'Status' => 'Populated, Enabled',
                'Max Speed' => '1800 MHz',
                'External Clock' => '133 MHz',
                'Family' => 'Pentium M',
                'Current Speed' => '1733 MHz',
                'L2 Cache Handle' => '0x0701',
                'Type' => 'Central Processor',
                'Signature' => 'Type 0, Family 6, Model 13, Stepping 8',
                'Upgrade' => 'None',
                'L1 Cache Handle' => '0x0700',
                'Voltage' => '3.3 V',
                'Manufacturer' => 'Intel',
                'L3 Cache Handle' => 'Not Provided'
            }
        ],
        10 => [
            {
                 'Type' => 'Video',
                 'Status' => 'Enabled',
                 'Description' => 'Intel 915GM Graphics'
            },
            {
                 'Type' => 'Sound',
                 'Status' => 'Enabled',
                 'Description' => 'Sigmatel 9751'
            }
        ],
        19 => [
            {
                 'Range Size' => '640 kB',
                 'Partition Width' => '0',
                 'Starting Address' => '0x00000000000',
                 'Physical Array Handle' => '0x1000',
                 'Ending Address' => '0x0000009FFFF'
            },
            {
                 'Range Size' => '2047 MB',
                 'Partition Width' => '0',
                 'Starting Address' => '0x00000100000',
                 'Physical Array Handle' => '0x1000',
                 'Ending Address' => '0x0007FFFFFFF'
            }
        ]
    },
    'openbsd-3.7' => {
         6 => [
            {
                'Installed Size' => 'Not Installed',
                'Socket Designation' => 'BANK_1',
                'Error Status' => 'OK',
                'Enabled Size' => 'Not Installed',
                'Current Speed' => '70 ns',
                'Bank Connections' => '2'
            },
            {
                'Installed Size' => '64 MB (Single-bank Connection)',
                'Socket Designation' => 'BANK_2',
                'Type' => 'DIMM SDRAM',
                'Error Status' => 'OK',
                'Enabled Size' => '64 MB (Single-bank Connection)',
                'Current Speed' => '70 ns',
                'Bank Connections' => '3'
            },
            {
                'Installed Size' => 'Not Installed',
                'Socket Designation' => 'BANK_3',
                'Error Status' => 'OK',
                'Enabled Size' => 'Not Installed',
                'Current Speed' => '70 ns',
                'Bank Connections' => '4'
            },
            {
                'Installed Size' => '64 MB (Single-bank Connection)',
                'Socket Designation' => 'BANK_4',
                'Type' => 'DIMM SDRAM',
                'Error Status' => 'OK',
                'Enabled Size' => '64 MB (Single-bank Connection)',
                'Current Speed' => '70 ns',
                'Bank Connections' => '5'
            },
            {
                'Installed Size' => '64 MB (Single-bank Connection)',
                'Socket Designation' => 'BANK_5',
                'Type' => 'DIMM SDRAM',
                'Error Status' => 'OK',
                'Enabled Size' => '64 MB (Single-bank Connection)',
                'Current Speed' => '70 ns',
                'Bank Connections' => '6'
            },
            {
                'Installed Size' => 'Not Installed',
                'Socket Designation' => 'BANK_6',
                'Error Status' => 'OK',
                'Enabled Size' => 'Not Installed',
                'Current Speed' => '70 ns',
                'Bank Connections' => '7'
            },
            {
                'Installed Size' => 'Not Installed',
                'Socket Designation' => 'BANK_7',
                'Error Status' => 'OK',
                'Enabled Size' => 'Not Installed',
                'Current Speed' => '70 ns',
                'Bank Connections' => '8'
            }
        ],
        7 => [
            {
                'Installed Size' => '32 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'Internal Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'Installed SRAM Type' => 'Synchronous',
                'Location' => 'Internal',
                'Maximum Size' => '32 KB'
            },
            {
                'Installed Size' => '512 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'External Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'Installed SRAM Type' => 'Synchronous',
                'Location' => 'External',
                'Maximum Size' => '2048 KB'
            }
        ],
        9 => [
            {
                ID             => '32',
                'Length' => 'Long',
                'Designation' => 'AGP',
                'Type' => '32-bit PCI',
                'Current Usage' => 'In Use'
            },
            {
                ID             => '12',
                'Length' => 'Long',
                'Designation' => 'PCI1',
                'Type' => '32-bit PCI',
                'Current Usage' => 'Available'
            },
            {
                ID             => '11',
                'Length' => 'Long',
                'Designation' => 'PCI2',
                'Type' => '32-bit PCI',
                'Current Usage' => 'Available'
            },
            {
                ID             => '10',
                'Length' => 'Long',
                'Designation' => 'PCI3',
                'Type' => '32-bit PCI',
                'Current Usage' => 'In Use'
            },
            {
                ID             => '9',
                'Length' => 'Long',
                'Designation' => 'PCI4',
                'Type' => '32-bit PCI',
                'Current Usage' => 'Available'
            },
            {
                ID             => '8',
                'Length' => 'Long',
                'Designation' => 'PCI5',
                'Type' => '32-bit PCI',
                'Current Usage' => 'Available'
            },
            {
                'Length' => 'Long',
                'Designation' => 'ISA',
                'Type' => '16-bit ISA',
            },
            {
                'Length' => 'Long',
                'Designation' => 'ISA',
                'Type' => '16-bit ISA',
            },
            {
                ID             => '0',
                'Length' => 'Long',
                'Designation' => 'PCIx',
                'Type' => '32-bit PCI',
            },
            {
                ID             => '0',
                'Length' => 'Long',
                'Designation' => 'PCIx',
                'Type' => '32-bit PCI',
            },
            {
                ID             => '0',
                'Length' => 'Long',
                'Designation' => 'PCIx',
                'Type' => '32-bit PCI',
            },
            {
                ID             => '0',
                'Length' => 'Long',
                'Designation' => 'PCIx',
                'Type' => '32-bit PCI',
            },
            {
                ID             => '0',
                'Length' => 'Long',
                'Designation' => 'PCIx',
                'Type' => '32-bit PCI',
            }
        ],
        2 => [
            {
                'Version' => 'Rev. 1.0',
                'Product Name' => 'P6PROA5',
                'Manufacturer' => 'Tekram Technology Co., Ltd.'
            }
        ],
        8 => [
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'PRIMARY IDE',
                'Internal Connector Type' => 'On Board IDE'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'SECONDARY IDE',
                'Internal Connector Type' => 'On Board IDE'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'FLOPPY',
                'Internal Connector Type' => 'On Board Floppy'
            },
            {
                'Port Type' => 'Serial Port 16550 Compatible',
                'External Connector Type' => 'DB-9 male',
                'Internal Reference Designator' => 'COM1',
                'Internal Connector Type' => '9 Pin Dual Inline (pin 10 cut)'
            },
            {
                'Port Type' => 'Serial Port 16550 Compatible',
                'External Connector Type' => 'DB-9 male',
                'Internal Reference Designator' => 'COM2',
                'Internal Connector Type' => '9 Pin Dual Inline (pin 10 cut)'
            },
            {
                'Port Type' => 'Parallel Port ECP/EPP',
                'External Connector Type' => 'DB-25 female',
                'Internal Reference Designator' => 'LPT1',
                'Internal Connector Type' => 'DB-25 female'
            },
            {
                'Port Type' => 'Keyboard Port',
                'External Connector Type' => 'PS/2',
                'Internal Reference Designator' => 'Keyboard',
                'Internal Connector Type' => 'Other'
            },
            {
                'Port Type' => 'Mouse Port',
                'External Connector Type' => 'PS/2',
                'Internal Reference Designator' => 'PS/2 Mouse',
                'Internal Connector Type' => 'Other'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'Infrared',
                'Internal Reference Designator' => 'IR_CON',
                'Internal Connector Type' => 'Other'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'Infrared',
                'Internal Reference Designator' => 'IR_CON2',
                'Internal Connector Type' => 'Other'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'Other',
                'Internal Reference Designator' => 'USB',
                'Internal Connector Type' => 'Other'
            }
        ],
        1 => [
            {
                'Product Name' => 'VT82C691',
                'Manufacturer' => 'VIA Technologies, Inc.'
            }
        ],
        4 => [
            {
                ID             => '52 06 00 00 FF F9 83 01',
                'Socket Designation' => 'SLOT 1',
                'Status' => 'Populated, Enabled',
                'Max Speed' => '500 MHz',
                'External Clock' => '100 MHz',
                'Family' => 'Pentium II',
                'Current Speed' => '400 MHz',
                'Type' => 'Central Processor',
                'Signature' => 'Type 0, Family 6, Model 5, Stepping 2',
                'Version' => 'Pentium II',
                'Upgrade' => 'Slot 1',
                'Voltage' => '3.3 V',
                'Manufacturer' => 'Intel'
            }
        ],
        0 => [
            {
                'Runtime Size' => '128 kB',
                'Version' => '4.51 PG',
                'Address' => '0xE0000',
                'ROM Size' => '256 kB',
                'Release Date' => '02/11/99',
                'Vendor' => 'Award Software International, Inc.'
            }
        ],
        5 => [
            {
                'Error Detecting Method' => '64-bit ECC',
                'Maximum Total Memory Size' => '2048 MB',
                'Supported Interleave' => 'Four-way Interleave',
                'Maximum Memory Module Size' => '256 MB',
                'Associated Memory Slots' => '8',
                'Current Interleave' => 'One-way Interleave',
                'Memory Module Voltage' => '5.0 V 3.3 V'
            }
        ]
    },
    'openbsd-3.8' => {
            32 => [
            {
                 'Status' => 'No errors detected'
            }
        ],
        11 => [
            {
                 'String 1' => 'Dell System',
                 'String 2' => '5[0000]'
            }
        ],
        7 => [
            {
                'Error Correction Type' => 'Parity',
                'Installed Size' => '16 KB',
                'Operational Mode' => 'Write Through',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'System Type' => 'Data',
                'Associativity' => '8-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '16 KB'
            },
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Installed Size' => '2048 KB',
                'Operational Mode' => 'Write Back',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'System Type' => 'Unified',
                'Associativity' => '8-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '2048 KB'
            },
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Installed Size' => '0 KB',
                'Operational Mode' => 'Write Back',
                'Configuration' => 'Enabled, Not Socketed, Level 3',
                'System Type' => 'Unified',
                'Associativity' => '2-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '0 KB'
            },
            {
                'Error Correction Type' => 'Parity',
                'Installed Size' => '0 KB',
                'Operational Mode' => 'Write Through',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'System Type' => 'Data',
                'Associativity' => '8-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '16 KB'
            },
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Installed Size' => '0 KB',
                'Operational Mode' => 'Write Back',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'System Type' => 'Unified',
                'Associativity' => '8-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '2048 KB'
            },
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Installed Size' => '0 KB',
                'Operational Mode' => 'Write Back',
                'Configuration' => 'Enabled, Not Socketed, Level 3',
                'System Type' => 'Unified',
                'Associativity' => '2-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '0 KB'
            }
        ],
        17 => [
            {
                 'Part Number' => 'M3 93T6450FZ0-CCC',
                 'Serial Number' => '50075483',
                 'Data Width' => '64 bits',
                 'Array Handle' => '0x1000',
                 'Type Detail' => 'Synchronous',
                 'Set' => '1',
                 'Asset Tag' => '010552',
                 'Total Width' => '72 bits',
                 'Speed' => '400 MHz (2.5 ns)',
                 'Size' => '512 MB',
                 'Error Information Handle' => 'Not Provided',
                 'Locator' => 'DIMM1_A',
                 'Manufacturer' => 'CE00000000000000',
                 'Form Factor' => 'DIMM'
            },
            {
                 'Part Number' => 'M3 93T6450FZ0-CCC',
                 'Serial Number' => '500355A1',
                 'Data Width' => '64 bits',
                 'Array Handle' => '0x1000',
                 'Type Detail' => 'Synchronous',
                 'Set' => '1',
                 'Asset Tag' => '010552',
                 'Total Width' => '72 bits',
                 'Speed' => '400 MHz (2.5 ns)',
                 'Size' => '512 MB',
                 'Error Information Handle' => 'Not Provided',
                 'Locator' => 'DIMM1_B',
                 'Manufacturer' => 'CE00000000000000',
                 'Form Factor' => 'DIMM'
            },
            {
                 'Data Width' => '64 bits',
                 'Array Handle' => '0x1000',
                 'Type Detail' => 'Synchronous',
                 'Set' => '2',
                 'Total Width' => '72 bits',
                 'Speed' => '400 MHz (2.5 ns)',
                 'Size' => 'No Module Installed',
                 'Error Information Handle' => 'Not Provided',
                 'Locator' => 'DIMM2_A',
                 'Form Factor' => 'DIMM'
            },
            {
                 'Data Width' => '64 bits',
                 'Array Handle' => '0x1000',
                 'Type Detail' => 'Synchronous',
                 'Set' => '2',
                 'Total Width' => '72 bits',
                 'Speed' => '400 MHz (2.5 ns)',
                 'Size' => 'No Module Installed',
                 'Error Information Handle' => 'Not Provided',
                 'Locator' => 'DIMM2_B',
                 'Form Factor' => 'DIMM'
            },
            {
                 'Data Width' => '64 bits',
                 'Array Handle' => '0x1000',
                 'Type Detail' => 'Synchronous',
                 'Set' => '3',
                 'Total Width' => '72 bits',
                 'Speed' => '400 MHz (2.5 ns)',
                 'Size' => 'No Module Installed',
                 'Error Information Handle' => 'Not Provided',
                 'Locator' => 'DIMM3_A',
                 'Form Factor' => 'DIMM'
            },
            {
                 'Data Width' => '64 bits',
                 'Array Handle' => '0x1000',
                 'Type Detail' => 'Synchronous',
                 'Set' => '3',
                 'Total Width' => '72 bits',
                 'Speed' => '400 MHz (2.5 ns)',
                 'Size' => 'No Module Installed',
                 'Error Information Handle' => 'Not Provided',
                 'Locator' => 'DIMM3_B',
                 'Form Factor' => 'DIMM'
            }
        ],
        2 => [
            {
                'Version' => 'A04',
                'Product Name' => '0P8611',
                'Serial Number' => '..CN717035A80217.',
                'Manufacturer' => 'Dell Computer Corporation'
            }
        ],
        1 => [
            {
                'Wake-up Type' => 'Power Switch',
                'Product Name' => 'PowerEdge 1800',
                'Serial Number' => '2K1012J',
                'Manufacturer' => 'Dell Computer Corporation',
                'UUID' => '44454C4C-4B00-1031-8030-B2C04F31324A'
            }
        ],
        0 => [
            {
                'Runtime Size' => '64 kB',
                'Version' => 'A05',
                'Address' => '0xF0000',
                'ROM Size' => '1024 kB',
                'Release Date' => '09/21/2005',
                'Vendor' => 'Dell Computer Corporation'
            }
        ],
        16 => [
            {
                 'Number Of Devices' => '6',
                 'Error Correction Type' => 'Multi-bit ECC',
                 'Error Information Handle' => 'Not Provided',
                 'Location' => 'System Board Or Motherboard',
                 'Maximum Capacity' => '12 GB',
                 'Use' => 'System Memory'
            }
        ],
        13 => [
            {
                 'Installable Languages' => '1',
                 'Currently Installed Language' => 'en|US|iso8859-1'
            }
        ],
        3 => [
            {
                'Power Supply State' => 'Safe',
                'Serial Number' => '2K1012J',
                'Thermal State' => 'Safe',
                'Type' => 'Main Server Chassis',
                'Lock' => 'Present',
                'OEM Information' => '0x00000000',
                'Manufacturer' => 'Dell Computer Corporation',
                'Boot-up State' => 'Safe'
            }
        ],
        9 => [
            {
                ID             => '1',
                'Length' => 'Long',
                'Designation' => 'SLOT1',
                'Type' => '64-bit PCI',
                'Current Usage' => 'Available'
            },
            {
                'Length' => 'Long',
                'Designation' => 'SLOT2',
                'Current Usage' => 'Available'
            },
            {
                'Length' => 'Long',
                'Designation' => 'SLOT3',
                'Current Usage' => 'Available'
            },
            {
                ID             => '4',
                'Length' => 'Long',
                'Designation' => 'SLOT4',
                'Type' => '32-bit PCI',
                'Current Usage' => 'Available'
            },
            {
                ID             => '5',
                'Length' => 'Long',
                'Designation' => 'SLOT5',
                'Type' => '64-bit PCI-X',
                'Current Usage' => 'In Use'
            },
            {
                ID             => '6',
                'Length' => 'Long',
                'Designation' => 'SLOT6',
                'Type' => '64-bit PCI-X',
                'Current Usage' => 'Available'
            }
        ],
        12 => [
            {
                 'Option 2' => 'PASSWD: Close to enable password',
                 'Option 1' => 'NVRAM_CLR: Clear user settable NVRAM areas and set defaults'
            }
        ],
        20 => [
            {
                 'Memory Array Mapped Address Handle' => '0x1300',
                 'Range Size' => '1 GB',
                 'Physical Device Handle' => '0x1100',
                 'Partition Row Position' => '1',
                 'Starting Address' => '0x00000000000',
                 'Ending Address' => '0x0003FFFFFFF'
            },
            {
                 'Memory Array Mapped Address Handle' => '0x1300',
                 'Range Size' => '1 GB',
                 'Physical Device Handle' => '0x1101',
                 'Partition Row Position' => '2',
                 'Starting Address' => '0x00000000000',
                 'Ending Address' => '0x0003FFFFFFF'
            }
        ],
        38 => [
            {
                 'I2C Slave Address' => '0x10',
                 'Register Spacing' => '32-bit Boundaries',
                 'Specification Version' => '1.5',
                 'Base Address' => '0x0000000000000CA8 (I/O)',
                 'Interface Type' => 'KCS (Keyboard Control Style)'
            }
        ],
        8 => [
            {
                'Port Type' => 'SCSI Wide',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'SCSI',
                'Internal Connector Type' => '68 Pin Dual Inline'
            },
            {
                'Port Type' => 'Video Port',
                'External Connector Type' => 'DB-15 female',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Parallel Port PS/2',
                'External Connector Type' => 'DB-25 female',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Network Port',
                'External Connector Type' => 'RJ-45',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Serial Port 16550A Compatible',
                'External Connector Type' => 'DB-9 male',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Keyboard Port',
                'External Connector Type' => 'PS/2',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Mouse Port',
                'External Connector Type' => 'PS/2',
                'Internal Connector Type' => 'None'
            }
        ],
        4 => [
            {
                ID             => '43 0F 00 00 FF FB EB BF',
                'Socket Designation' => 'PROC_1',
                'Status' => 'Populated, Enabled',
                'Max Speed' => '3600 MHz',
                'External Clock' => '800 MHz',
                'Family' => 'Xeon',
                'Current Speed' => '3000 MHz',
                'L2 Cache Handle' => '0x0701',
                'Type' => 'Central Processor',
                'Signature' => 'Type 0, Family 15, Model 4, Stepping 3',
                'Upgrade' => 'ZIF Socket',
                'L1 Cache Handle' => '0x0700',
                'Voltage' => '1.4 V',
                'Manufacturer' => 'Intel',
                'L3 Cache Handle' => '0x0702'
            },
            {
                ID             => '00 00 00 00 00 00 00 00',
                'Socket Designation' => 'PROC_2',
                'Flags' => 'None',
                'Status' => 'Unpopulated',
                'Max Speed' => '3600 MHz',
                'Family' => 'Xeon',
                'L2 Cache Handle' => '0x0704',
                'Type' => 'Central Processor',
                'Signature' => 'Type 0, Family 0, Model 0, Stepping 0',
                'Upgrade' => 'ZIF Socket',
                'L1 Cache Handle' => '0x0703',
                'Voltage' => '1.4 V',
                'Manufacturer' => 'Intel',
                'L3 Cache Handle' => '0x0705'
            }
        ],
        10 => [
            {
                 'Type' => 'Ethernet',
                 'Status' => 'Enabled',
                 'Description' => 'Intel 82541GI Gigabit Ethernet'
            }
        ],
        19 => [
            {
                 'Range Size' => '1 GB',
                 'Partition Width' => '0',
                 'Starting Address' => '0x00000000000',
                 'Physical Array Handle' => '0x1000',
                 'Ending Address' => '0x0003FFFFFFF'
            }
        ]
    },
    'rhel-2.1' => {
        6 => [
            {
                'Installed Size' => '256Mbyte',
                'Type' => 'ECC DIMM SDRAM',
                'Enabled Size' => '256Mbyte',
                'Banks' => '0',
                'Socket' => 'DIMM1'
            },
            {
                'Installed Size' => 'Not Installed',
                'Type' => 'UNKNOWN',
                'Enabled Size' => 'Not Installed',
                'Socket' => 'DIMM2'
            }
        ],
        3 => [
            {
                'Chassis Type' => 'Mini Tower',
                'Vendor' => 'IBM'
            }
        ],
        7 => [
            {
                'L1 Cache Size' => '32K',
                'L1 socketed Internal Cache' => 'write-back',
                'L1 Cache Maximum' => '20K',
                'Socket' => 'CPU1'
            },
            {
                'L2 Cache Size' => '512K',
                'L2 socketed Internal Cache' => 'write-back',
                'L2 Cache Type' => 'Pipeline burst',
                'Socket' => 'CPU1',
                'L2 Cache Maximum' => '512K'
            }
        ],
        9 => [
            {
                'Slot' => 'AGP',
                'Slot Features' => '5v'
            },
            {
                'Type' => '32bit PCI',
                'Slot' => 'PCI1',
                'Status' => 'Available.',
                'Slot Features' => '5v'
            },
            {
                'Type' => '32bit PCI',
                'Slot' => 'PCI2',
                'Status' => 'In use.',
                'Slot Features' => '5v'
            },
            {
                'Type' => '32bit PCI',
                'Slot' => 'PCI3',
                'Status' => 'Available.',
                'Slot Features' => '5v'
            },
            {
                'Type' => '32bit PCI',
                'Slot' => 'PCI4',
                'Status' => 'Available.',
                'Slot Features' => '5v'
            },
            {
                'Type' => '32bit PCI',
                'Slot' => 'PCI5',
                'Status' => 'Available.',
                'Slot Features' => '5v'
            }
        ],
        2 => [
            {
                'Version' => '-1',
                'Serial Number' => 'NA60B7Y0S3Q',
                'Product' => '-[M51G]-',
                'Vendor' => 'IBM'
            }
        ],
        15 => [
            {
                 'Log Type' => '3.',
                 'Log Area' => '511 bytes.',
                 'Log Data At' => '16.',
                 'Log Header At' => '0.',
                 'Log Valid' => 'Yes.'
            }
        ],
        8 => [
            {
                'Port Type' => 'Serial Port 16650A Compatible',
                'External Connector Type' => 'DB-9 pin male',
                'Internal Connector Type' => 'None',
                'External Designator' => 'SERIAL1'
            },
            {
                'Port Type' => 'Serial Port 16650A Compatible',
                'External Connector Type' => 'DB-9 pin male',
                'Internal Connector Type' => 'None',
                'External Designator' => 'SERIAL2'
            },
            {
                'Port Type' => 'Parallel Port ECP/EPP',
                'External Connector Type' => 'DB-25 pin female',
                'Internal Connector Type' => 'None',
                'External Designator' => 'PRINTER'
            },
            {
                'Port Type' => 'Keyboard Port',
                'External Connector Type' => 'PS/2',
                'Internal Connector Type' => 'None',
                'External Designator' => 'KEYBOARD'
            },
            {
                'Port Type' => 'Mouse Port',
                'External Connector Type' => 'PS/2',
                'Internal Connector Type' => 'None',
                'External Designator' => 'MOUSE'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'Internal Connector Type' => 'None',
                'External Designator' => 'USB1'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'Internal Connector Type' => 'None',
                'External Designator' => 'USB2'
            },
            {
                'Port Type' => 'Other',
                'Internal Designator' => 'IDE1',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'On Board IDE'
            },
            {
                'Port Type' => 'Other',
                'Internal Designator' => 'IDE2',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'On Board IDE'
            },
            {
                'Port Type' => 'Other',
                'Internal Designator' => 'FDD',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'On Board Floppy'
            },
            {
                'Port Type' => 'SCSI II',
                'Internal Designator' => 'SCSI1',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'SSA SCSI'
            }
        ],
        1 => [
            {
                'Version' => 'IBM CORPORATION',
                'Serial Number' => 'KBKGW40',
                'Product' => '-[84803AX]-',
                'Vendor' => 'IBM'
            }
        ],
        4 => [
            {
                'Socket Designation' => 'CPU1',
                'Processor Manufacturer' => 'Intel',
                'Processor Version' => 'Pentium 4',
                'Processor Type' => 'Central Processor'
            }
        ],
        0 => [
            {
                'Release' => '12/11/2002',
                'Version' => '-[JPE130AUS-1.30]-',
                'Flags' => '0x000000007FFBDE90',
                'BIOS base' => '0xF0000',
                'Vendor' => 'IBM',
                'ROM size' => '448K'
            }
        ],
        10 => [
            {
                 'Description' => 'IBM Automatic Server Restart - Machine Type 8480 : Enabled'
            }
        ]
    },
    'rhel-3.4' => {
            11 => [
            {
                 'String 1' => 'IBM Remote Supervisor Adapter -[GRET15AUS]-'
            }
        ],
        3 => [
            {
                'Power Supply State' => 'Safe',
                'Thermal State' => 'Safe',
                'Asset Tag' => '12345678901234567890123456789012',
                'Type' => 'Tower',
                'Security Status' => 'None',
                'Manufacturer' => 'IBM',
                'Boot-up State' => 'Safe',
                'OEM Information' => '0x00001234'
            }
        ],
        7 => [
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Installed Size' => '16 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'L1 Cache for CPU#1',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'Installed SRAM Type' => 'Burst Pipeline Burst',
                'System Type' => 'Data',
                'Associativity' => '4-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '16 KB'
            },
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Installed Size' => '1024 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'L2 Cache for CPU#1',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'Installed SRAM Type' => 'Burst',
                'System Type' => 'Unified',
                'Associativity' => '4-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '2048 KB'
            },
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Installed Size' => '16 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'L1 Cache for CPU#2',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'Installed SRAM Type' => 'Burst Pipeline Burst',
                'System Type' => 'Data',
                'Associativity' => '4-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '16 KB'
            },
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Installed Size' => '1024 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'L2 Cache for CPU#2',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'Installed SRAM Type' => 'Burst',
                'System Type' => 'Unified',
                'Associativity' => '4-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '2048 KB'
            }
        ],
        9 => [
            {
                ID             => '1',
                'Length' => 'Other',
                'Designation' => 'PCIE Slot #1',
                'Type' => 'PCI',
                'Current Usage' => 'Available'
            },
            {
                ID             => '2',
                'Length' => 'Short',
                'Designation' => 'PCI/33 Slot #2',
                'Type' => '32-bit PCI',
                'Current Usage' => 'Available'
            },
            {
                ID             => '3',
                'Length' => 'Short',
                'Designation' => 'PCI/33 Slot #3',
                'Type' => '32-bit PCI',
                'Current Usage' => 'Available'
            },
            {
                ID             => '4',
                'Length' => 'Long',
                'Designation' => 'PCIX 133 Slot #4',
                'Type' => '64-bit PCI-X',
                'Current Usage' => 'Available'
            },
            {
                ID             => '5',
                'Length' => 'Long',
                'Designation' => 'PCIX100(ZCR) Slot #5',
                'Type' => '64-bit PCI-X',
                'Current Usage' => 'Available'
            },
            {
                ID             => '6',
                'Length' => 'Long',
                'Designation' => 'PCIX100 Slot #6',
                'Type' => '64-bit PCI-X',
                'Current Usage' => 'Available'
            }
        ],
        17 => [
            {
                 'Part Number' => 'M3 93T6553BZ3-CCC',
                 'Bank Locator' => 'BANK 1',
                 'Serial Number' => '460360BB',
                 'Data Width' => '64 bits',
                 'Array Handle' => '0x0022',
                 'Type Detail' => 'Synchronous',
                 'Set' => '1',
                 'Asset Tag' => '3342',
                 'Total Width' => '72 bits',
                 'Type' => 'DDR',
                 'Speed' => '400 MHz (2.5 ns)',
                 'Size' => '512 MB',
                 'Error Information Handle' => 'No Error',
                 'Locator' => 'DIMM 1',
                 'Form Factor' => 'DIMM'
            },
            {
                 'Part Number' => 'M3 93T6553BZ3-CCC',
                 'Bank Locator' => 'BANK 1',
                 'Serial Number' => '460360E8',
                 'Data Width' => '64 bits',
                 'Array Handle' => '0x0022',
                 'Type Detail' => 'Synchronous',
                 'Set' => '1',
                 'Asset Tag' => '3342',
                 'Total Width' => '72 bits',
                 'Type' => 'DDR',
                 'Speed' => '400 MHz (2.5 ns)',
                 'Size' => '512 MB',
                 'Error Information Handle' => 'No Error',
                 'Locator' => 'DIMM 2',
                 'Form Factor' => 'DIMM'
            }
        ],
        12 => [
            {
                 'Option 1' => 'JCMOS1: 1-2 Keep CMOS Data(Default), 2-3 Clear CMOS Data (make sure the AC power cord(s) is(are) removed from the system)'
            },
            {
                 'Option 1' => 'JCON1: 1-2 Normal(Default), 2-3 Configuration, No Jumper - BIOS Crisis Recovery'
            }
        ],
        2 => [
            {
                'Version' => 'Not Applicable',
                'Product Name' => 'MSI-9151 Boards',
                'Serial Number' => '#A123456789',
                'Manufacturer' => 'IBM'
            }
        ],
        15 => [
            {
                 'Access Method' => 'General-pupose non-volatile data functions',
                 'Data Start Offset' => '0x0010',
                 'Status' => 'Valid, Not Full',
                 'Supported Log Type Descriptors' => '3',
                 'Descriptor 1' => 'POST error',
                 'Area Length' => '320 bytes',
                 'Header Start Offset' => '0x0000',
                 'Header Format' => 'Type 1',
                 'Access Address' => '0x0000',
                 'Data Format 1' => 'POST results bitmap',
                 'Descriptor 3' => 'Multi-bit ECC memory error',
                 'Header Length' => '16 bytes',
                 'Change Token' => '0x00000013',
                 'Data Format 2' => 'Multiple-event',
                 'Descriptor 2' => 'Single-bit ECC memory error',
                 'Data Format 3' => 'Multiple-event'
            }
        ],
        8 => [
            {
                'External Reference Designator' => 'COM 1',
                'Port Type' => 'Serial Port 16550A Compatible',
                'External Connector Type' => 'DB-9 male',
                'Internal Reference Designator' => 'J2A1',
                'Internal Connector Type' => '9 Pin Dual Inline (pin 10 cut)'
            },
            {
                'External Reference Designator' => 'COM 2',
                'Port Type' => 'Serial Port 16550A Compatible',
                'External Connector Type' => 'DB-9 male',
                'Internal Reference Designator' => 'J2A2',
                'Internal Connector Type' => '9 Pin Dual Inline (pin 10 cut)'
            },
            {
                'External Reference Designator' => 'Parallel',
                'Port Type' => 'Parallel Port ECP/EPP',
                'External Connector Type' => 'DB-25 female',
                'Internal Reference Designator' => 'J3A1',
                'Internal Connector Type' => '25 Pin Dual Inline (pin 26 cut)'
            },
            {
                'External Reference Designator' => 'Keyboard',
                'Port Type' => 'Keyboard Port',
                'External Connector Type' => 'Circular DIN-8 male',
                'Internal Reference Designator' => 'J1A1',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'PS/2 Mouse',
                'Port Type' => 'Keyboard Port',
                'External Connector Type' => 'Circular DIN-8 male',
                'Internal Reference Designator' => 'J1A1',
                'Internal Connector Type' => 'None'
            }
        ],
        1 => [
            {
                'Version' => 'Not Applicable',
                'Wake-up Type' => 'Power Switch',
                'Product Name' => 'IBM eServer x226-[8488PCR]-',
                'Serial Number' => 'KDXPC16',
                'Manufacturer' => 'IBM',
                'UUID' => 'A8346631-8E88-3AE3-898C-F3AC9F61C316'
            }
        ],
        4 => [
            {
                ID             => '41 0F 00 00 FF FB EB BF',
                'Socket Designation' => 'CPU#1',
                'Status' => 'Populated, Enabled',
                'Max Speed' => '3600 MHz',
                'External Clock' => '200 MHz',
                'Family' => 'Xeon MP',
                'Current Speed' => '2800 MHz',
                'L2 Cache Handle' => '0x0007',
                'Type' => 'Central Processor',
                'Signature' => 'Type 0, Family F, Model 4, Stepping 1',
                'Version' => 'Intel(R) Xeon(TM) CPU 2.80GHz',
                'Upgrade' => 'ZIF Socket',
                'L1 Cache Handle' => '0x0006',
                'Voltage' => '1.3 V',
                'Manufacturer' => 'Intel Corporation',
                'L3 Cache Handle' => 'Not Provided'
            },
            {
                ID             => '41 0F 00 00 FF FB EB BF',
                'Socket Designation' => 'CPU#2',
                'Status' => 'Populated, Enabled',
                'Max Speed' => '3600 MHz',
                'External Clock' => '200 MHz',
                'Family' => 'Xeon MP',
                'Current Speed' => '2800 MHz',
                'L2 Cache Handle' => '0x000A',
                'Type' => 'Central Processor',
                'Signature' => 'Type 0, Family F, Model 4, Stepping 1',
                'Version' => 'Intel(R) Xeon(TM) CPU 2.80GHz',
                'Upgrade' => 'ZIF Socket',
                'L1 Cache Handle' => '0x0009',
                'Voltage' => '1.3 V',
                'Manufacturer' => 'Intel Corporation',
                'L3 Cache Handle' => 'Not Provided'
            }
        ],
        0 => [
            {
                'Runtime Size' => '130064 bytes',
                'Version' => 'IBM BIOS Version 1.57-[PME157AUS-1.57]-',
                'Address' => '0xE03F0',
                'ROM Size' => '1024 kB',
                'Release Date' => '08/25/2005',
                'Vendor' => 'IBM'
            }
        ],
        16 => [
            {
                 'Number Of Devices' => '6',
                 'Error Correction Type' => 'Single-bit ECC',
                 'Error Information Handle' => 'No Error',
                 'Location' => 'System Board Or Motherboard',
                 'Maximum Capacity' => '16 GB',
                 'Use' => 'System Memory'
            }
        ],
        13 => [
            {
                 'Installable Languages' => '1',
                 'Currently Installed Language' => 'en|US|iso8859-1'
            }
        ],
        10 => [
            {
                 'Type' => 'Other',
                 'Status' => 'Enabled',
                 'Description' => 'IBM Automatic Server Restart - Machine Type 8648'
            },
            {
                 'Type' => 'Video',
                 'Status' => 'Enabled',
                 'Description' => 'ATI Rage 7000'
            },
            {
                 'Type' => 'SCSI Controller',
                 'Status' => 'Enabled',
                 'Description' => 'Adaptec AIC 7902'
            },
            {
                 'Type' => 'Ethernet',
                 'Status' => 'Enabled',
                 'Description' => 'BoardCom BCM5721'
            }
        ]
    },
    'rhel-4.3' => {
        32 => [
            {
                 'Status' => 'No errors detected'
            }
        ],
        7 => [
            {
                'Installed Size' => '20 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'Level 1 Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'Installed SRAM Type' => 'Synchronous',
                'Location' => 'Internal',
                'Maximum Size' => '20 KB'
            },
            {
                'Installed Size' => '20 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'Level 1 Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'Installed SRAM Type' => 'Synchronous',
                'Location' => 'Internal',
                'Maximum Size' => '20 KB'
            },
            {
                'Installed Size' => '512 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'Level 2 Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'Installed SRAM Type' => 'Synchronous',
                'Location' => 'Internal',
                'Maximum Size' => '512 KB'
            },
            {
                'Installed Size' => '512 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'Level 2 Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'Installed SRAM Type' => 'Synchronous',
                'Location' => 'Internal',
                'Maximum Size' => '512 KB'
            },
            {
                'Installed Size' => '0 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'Tertiary (Level 3) Cache',
                'Configuration' => 'Disabled, Not Socketed, Level 3',
                'Installed SRAM Type' => 'Synchronous',
                'Location' => 'Internal',
                'Maximum Size' => '0 KB'
            },
            {
                'Installed Size' => '0 KB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'Tertiary (Level 3) Cache',
                'Configuration' => 'Disabled, Not Socketed, Level 3',
                'Installed SRAM Type' => 'Synchronous',
                'Location' => 'Internal',
                'Maximum Size' => '0 KB'
            }
        ],
        17 => [
            {
                 'Bank Locator' => 'Bank0',
                 'Data Width' => '256 bits',
                 'Array Handle' => '0x0028',
                 'Type Detail' => 'None',
                 'Set' => '1',
                 'Total Width' => '257 bits',
                 'Type' => 'DDR',
                 'Size' => '512 MB',
                 'Error Information Handle' => '0x002D',
                 'Locator' => 'DIMM1',
                 'Form Factor' => 'DIMM'
            },
            {
                 'Bank Locator' => 'Bank1',
                 'Data Width' => '256 bits',
                 'Array Handle' => '0x0028',
                 'Type Detail' => 'None',
                 'Set' => '1',
                 'Total Width' => '257 bits',
                 'Type' => 'DDR',
                 'Size' => '512 MB',
                 'Error Information Handle' => '0x002E',
                 'Locator' => 'DIMM2',
                 'Form Factor' => 'DIMM'
            },
            {
                 'Bank Locator' => 'Bank2',
                 'Data Width' => '256 bits',
                 'Array Handle' => '0x0028',
                 'Type Detail' => 'None',
                 'Set' => '2',
                 'Total Width' => '257 bits',
                 'Type' => 'DDR',
                 'Size' => '512 MB',
                 'Error Information Handle' => '0x002F',
                 'Locator' => 'DIMM3',
                 'Form Factor' => 'DIMM'
            },
            {
                 'Bank Locator' => 'Bank3',
                 'Data Width' => '256 bits',
                 'Array Handle' => '0x0028',
                 'Type Detail' => 'None',
                 'Set' => '2',
                 'Total Width' => '257 bits',
                 'Type' => 'DDR',
                 'Size' => '512 MB',
                 'Error Information Handle' => '0x0030',
                 'Locator' => 'DIMM4',
                 'Form Factor' => 'DIMM'
            }
        ],
        2 => [
            {
                'Version' => '2.0',
                'Product Name' => 'MS-9121',
                'Serial Number' => '48Z1LX',
                'Manufacturer' => 'IBM'
            }
        ],
        1 => [
            {
                'Version' => '2.0',
                'Wake-up Type' => 'Other',
                'Product Name' => '-[86494jg]-',
                'Serial Number' => 'KDMAH1Y',
                'Manufacturer' => 'IBM',
                'UUID' => '0339D4C3-44C0-9D11-A20E-85CDC42DE79C'
            }
        ],
        18 => [
            {
                 'Granularity' => 'Other',
                 'Type' => 'Other',
                 'Operation' => 'Other'
            },
            {
                 'Granularity' => 'Other',
                 'Type' => 'Other',
                 'Operation' => 'Other'
            },
            {
                 'Granularity' => 'Other',
                 'Type' => 'Other',
                 'Operation' => 'Other'
            },
            {
                 'Granularity' => 'Other',
                 'Type' => 'Other',
                 'Operation' => 'Other'
            }
        ],
        0 => [
            {
                'Runtime Size' => '128 kB',
                'Version' => '-[OQE115A]-',
                'Address' => '0xE0000',
                'ROM Size' => '1024 kB',
                'Release Date' => '03/14/2006',
                'Vendor' => 'IBM'
            }
        ],
        16 => [
            {
                 'Number Of Devices' => '4',
                 'Error Correction Type' => 'Multi-bit ECC',
                 'Error Information Handle' => 'No Error',
                 'Location' => 'System Board Or Motherboard',
                 'Maximum Capacity' => '8 GB',
                 'Use' => 'System Memory'
            }
        ],
        13 => [
            {
                 'Installable Languages' => '3',
                 'Currently Installed Language' => 'n|US|iso8859-1'
            }
        ],
        6 => [
            {
                'Installed Size' => '512 MB (Single-bank Connection)',
                'Socket Designation' => 'DIMM1',
                'Type' => 'Other DIMM',
                'Error Status' => 'OK',
                'Enabled Size' => '512 MB (Single-bank Connection)',
                'Bank Connections' => '0'
            },
            {
                'Installed Size' => '512 MB (Single-bank Connection)',
                'Socket Designation' => 'DIMM2',
                'Type' => 'Other DIMM',
                'Error Status' => 'OK',
                'Enabled Size' => '512 MB (Single-bank Connection)',
                'Bank Connections' => '2'
            },
            {
                'Installed Size' => '512 MB (Single-bank Connection)',
                'Socket Designation' => 'DIMM3',
                'Type' => 'Other DIMM',
                'Error Status' => 'OK',
                'Enabled Size' => '512 MB (Single-bank Connection)',
                'Bank Connections' => '4'
            },
            {
                'Installed Size' => '512 MB (Single-bank Connection)',
                'Socket Designation' => 'DIMM4',
                'Type' => 'Other DIMM',
                'Error Status' => 'OK',
                'Enabled Size' => '512 MB (Single-bank Connection)',
                'Bank Connections' => '6'
            }
        ],
        3 => [
            {
                'Type' => 'Tower',
                'Lock' => 'Present',
                'Manufacturer' => 'IBM'
            }
        ],
        9 => [
            {
                ID             => '1',
                'Length' => 'Other',
                'Designation' => 'PCI1',
                'Type' => '32-bit PCI',
                'Current Usage' => 'Available'
            },
            {
                ID             => '2',
                'Length' => 'Other',
                'Designation' => 'PCI6',
                'Type' => '32-bit PCI',
                'Current Usage' => 'In Use'
            },
            {
                ID             => '8',
                'Length' => 'Long',
                'Designation' => 'AGP',
                'Type' => '32-bit AGP',
                'Current Usage' => 'Available'
            },
            {
                ID             => '2',
                'Length' => 'Long',
                'Designation' => 'PCI2',
                'Type' => '64-bit PCI-X',
                'Current Usage' => 'Available'
            },
            {
                ID             => '3',
                'Length' => 'Long',
                'Designation' => 'PCI3',
                'Type' => '64-bit PCI-X',
                'Current Usage' => 'Available'
            },
            {
                ID             => '1',
                'Length' => 'Long',
                'Designation' => 'PCI4',
                'Type' => '64-bit PCI-X',
                'Current Usage' => 'In Use'
            },
            {
                ID             => '2',
                'Length' => 'Long',
                'Designation' => 'PCI5',
                'Type' => '64-bit PCI-X',
                'Current Usage' => 'Available'
            }
        ],
        20 => [
            {
                 'Memory Array Mapped Address Handle' => '0x0031',
                 'Range Size' => '512 MB',
                 'Physical Device Handle' => '0x0029',
                 'Partition Row Position' => '1',
                 'Starting Address' => '0x00000000000',
                 'Ending Address' => '0x0001FFFFFFF'
            },
            {
                 'Memory Array Mapped Address Handle' => '0x0031',
                 'Range Size' => '512 MB',
                 'Physical Device Handle' => '0x002A',
                 'Partition Row Position' => '1',
                 'Starting Address' => '0x00020000000',
                 'Ending Address' => '0x0003FFFFFFF'
            },
            {
                 'Memory Array Mapped Address Handle' => '0x0031',
                 'Range Size' => '512 MB',
                 'Physical Device Handle' => '0x002B',
                 'Partition Row Position' => '1',
                 'Starting Address' => '0x00040000000',
                 'Ending Address' => '0x0005FFFFFFF'
            },
            {
                 'Memory Array Mapped Address Handle' => '0x0031',
                 'Range Size' => '512 MB',
                 'Physical Device Handle' => '0x002C',
                 'Partition Row Position' => '1',
                 'Starting Address' => '0x00060000000',
                 'Ending Address' => '0x0007FFFFFFF'
            }
        ],
        8 => [
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'IDE1',
                'Internal Connector Type' => 'On Board IDE'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'IDE2',
                'Internal Connector Type' => 'On Board IDE'
            },
            {
                'Port Type' => '8251 FIFO Compatible',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'FDD',
                'Internal Connector Type' => 'On Board Floppy'
            },
            {
                'Port Type' => 'Serial Port 16450 Compatible',
                'External Connector Type' => 'DB-9 male',
                'Internal Reference Designator' => 'COM1',
                'Internal Connector Type' => '9 Pin Dual Inline (pin 10 cut)'
            },
            {
                'Port Type' => 'Serial Port 16450 Compatible',
                'External Connector Type' => 'DB-9 male',
                'Internal Reference Designator' => 'COM2',
                'Internal Connector Type' => '9 Pin Dual Inline (pin 10 cut)'
            },
            {
                'Port Type' => 'Parallel Port ECP/EPP',
                'External Connector Type' => 'DB-25 female',
                'Internal Reference Designator' => 'LPT1',
                'Internal Connector Type' => 'DB-25 female'
            },
            {
                'Port Type' => 'Keyboard Port',
                'External Connector Type' => 'PS/2',
                'Internal Reference Designator' => 'Keyboard',
                'Internal Connector Type' => 'PS/2'
            },
            {
                'Port Type' => 'Mouse Port',
                'External Connector Type' => 'PS/2',
                'Internal Reference Designator' => 'PS/2 Mouse',
                'Internal Connector Type' => 'PS/2'
            },
            {
                'External Reference Designator' => 'JUSB1',
                'Port Type' => 'USB',
                'External Connector Type' => 'Other',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'JUSB2',
                'Port Type' => 'USB',
                'External Connector Type' => 'Other',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'AUD1',
                'Port Type' => 'Audio Port',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'JLAN1',
                'Port Type' => 'Network Port',
                'External Connector Type' => 'RJ-45',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'SCSI1',
                'Port Type' => 'SCSI Wide',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'SCSI2',
                'Port Type' => 'SCSI Wide',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'None'
            }
        ],
        4 => [
            {
                ID             => '29 0F 00 00 FF FB EB BF',
                'Socket Designation' => 'CPU1',
                'Status' => 'Populated, Enabled',
                'Max Speed' => '3200 MHz',
                'External Clock' => '133 MHz',
                'Family' => 'Xeon',
                'Current Speed' => '2666 MHz',
                'L2 Cache Handle' => '0x000D',
                'Type' => 'Central Processor',
                'Signature' => 'Type 0, Family F, Model 2, Stepping 9',
                'Version' => 'Intel Xeon(tm)',
                'Upgrade' => 'ZIF Socket',
                'L1 Cache Handle' => '0x000B',
                'Voltage' => '1.4 V',
                'Manufacturer' => 'Intel',
                'L3 Cache Handle' => '0x000F'
            },
            {
                ID             => '29 0F 00 00 FF FB EB BF',
                'Socket Designation' => 'CPU2',
                'Status' => 'Populated, Enabled',
                'Max Speed' => '3200 MHz',
                'External Clock' => '133 MHz',
                'Family' => 'Xeon',
                'Current Speed' => '2666 MHz',
                'L2 Cache Handle' => '0x000E',
                'Type' => 'Central Processor',
                'Signature' => 'Type 0, Family F, Model 2, Stepping 9',
                'Version' => 'Intel Xeon(tm)',
                'Upgrade' => 'ZIF Socket',
                'L1 Cache Handle' => '0x000C',
                'Voltage' => '1.4 V',
                'Manufacturer' => 'Intel',
                'L3 Cache Handle' => '0x0010'
            }
        ],
        10 => [
            {
                 'Type' => 'Sound',
                 'Status' => 'Enabled',
                 'Description' => 'SoundMax Integrated Digital Audio - AUD1'
            }
        ],
        19 => [
            {
                 'Range Size' => '2 GB',
                 'Partition Width' => '0',
                 'Starting Address' => '0x00000000000',
                 'Physical Array Handle' => '0x0028',
                 'Ending Address' => '0x0007FFFFFFF'
            }
        ],
        5 => [
            {
                'Error Detecting Method' => '8-bit Parity',
                'Maximum Total Memory Size' => '8192 MB',
                'Supported Interleave' => 'One-way Interleave',
                'Maximum Memory Module Size' => '2048 MB',
                'Associated Memory Slots' => '4',
                'Current Interleave' => 'One-way Interleave',
                'Memory Module Voltage' => '3.3 V'
            }
        ]
    },
    'rhel-5.6' => {
        11 => [
            {
                'String 2' => '5[0000]',
                'String 1' => 'Dell System'
            }
        ],
        17 => [
            {
                'Type' => 'DDR3',
                'Error Information Handle' => 'Not Provided',
                'Size' => 'No Module Installed',
                'Data Width' => '64 bits',
                'Total Width' => '72 bits',
                'Set' => '1',
                'Array Handle' => '0x1000',
                'Type Detail' => 'Synchronous',
                'Form Factor' => 'DIMM',
                'Locator' => 'DIMM_A1'
            },
            {
                'Rank' => '1',
                'Error Information Handle' => 'Not Provided',
                'Data Width' => '64 bits',
                'Serial Number' => '2AA3F87D',
                'Type' => 'DDR3',
                'Form Factor' => 'DIMM',
                'Part Number' => 'HMT325R7BFR8C-H9',
                'Set' => '1',
                'Asset Tag' => '01110228',
                'Array Handle' => '0x1000',
                'Total Width' => '72 bits',
                'Size' => '2048 MB',
                'Speed' => '1333 MHz',
                'Locator' => 'DIMM_A2',
                'Type Detail' => 'Synchronous',
                'Manufacturer' => '00AD009780AD'
            },
            {
                'Locator' => 'DIMM_A3',
                'Type Detail' => 'Synchronous',
                'Manufacturer' => '00AD009780AD',
                'Total Width' => '72 bits',
                'Speed' => '1333 MHz',
                'Size' => '2048 MB',
                'Form Factor' => 'DIMM',
                'Part Number' => 'HMT325R7BFR8C-H9',
                'Set' => '2',
                'Array Handle' => '0x1000',
                'Asset Tag' => '01110228',
                'Rank' => '1',
                'Error Information Handle' => 'Not Provided',
                'Data Width' => '64 bits',
                'Serial Number' => '2A33F897',
                'Type' => 'DDR3'
            },
            {
                'Type' => 'DDR3',
                'Error Information Handle' => 'Not Provided',
                'Size' => 'No Module Installed',
                'Data Width' => '64 bits',
                'Total Width' => '72 bits',
                'Set' => '2',
                'Array Handle' => '0x1000',
                'Type Detail' => 'Synchronous',
                'Form Factor' => 'DIMM',
                'Locator' => 'DIMM_A4'
            },
            {
                'Error Information Handle' => 'Not Provided',
                'Data Width' => '64 bits',
                'Size' => 'No Module Installed',
                'Type' => 'DDR3',
                'Total Width' => '72 bits',
                'Set' => '3',
                'Array Handle' => '0x1000',
                'Locator' => 'DIMM_A5',
                'Type Detail' => 'Synchronous',
                'Form Factor' => 'DIMM'
            },
            {
                'Total Width' => '72 bits',
                'Error Information Handle' => 'Not Provided',
                'Size' => 'No Module Installed',
                'Data Width' => '64 bits',
                'Type' => 'DDR3',
                'Locator' => 'DIMM_A6',
                'Type Detail' => 'Synchronous',
                'Form Factor' => 'DIMM',
                'Set' => '3',
                'Array Handle' => '0x1000'
            },
            {
                'Locator' => 'DIMM_A7',
                'Type Detail' => 'Synchronous',
                'Form Factor' => 'DIMM',
                'Set' => '4',
                'Array Handle' => '0x1000',
                'Total Width' => '72 bits',
                'Error Information Handle' => 'Not Provided',
                'Data Width' => '64 bits',
                'Size' => 'No Module Installed',
                'Type' => 'DDR3'
            },
            {
                'Form Factor' => 'DIMM',
                'Type Detail' => 'Synchronous',
                'Locator' => 'DIMM_A8',
                'Array Handle' => '0x1000',
                'Set' => '4',
                'Total Width' => '72 bits',
                'Type' => 'DDR3',
                'Data Width' => '64 bits',
                'Size' => 'No Module Installed',
                'Error Information Handle' => 'Not Provided'
            },
            {
                'Type' => 'DDR3',
                'Error Information Handle' => 'Not Provided',
                'Size' => 'No Module Installed',
                'Data Width' => '64 bits',
                'Total Width' => '72 bits',
                'Set' => '5',
                'Array Handle' => '0x1000',
                'Type Detail' => 'Synchronous',
                'Form Factor' => 'DIMM',
                'Locator' => 'DIMM_A9'
            },
            {
                'Total Width' => '72 bits',
                'Type' => 'DDR3',
                'Data Width' => '64 bits',
                'Size' => 'No Module Installed',
                'Error Information Handle' => 'Not Provided',
                'Form Factor' => 'DIMM',
                'Type Detail' => 'Synchronous',
                'Locator' => 'DIMM_B1',
                'Array Handle' => '0x1000',
                'Set' => '5'
            },
            {
                'Type Detail' => 'Synchronous',
                'Locator' => 'DIMM_B2',
                'Manufacturer' => '00AD009780AD',
                'Total Width' => '72 bits',
                'Speed' => '1333 MHz',
                'Size' => '2048 MB',
                'Form Factor' => 'DIMM',
                'Part Number' => 'HMT325R7BFR8C-H9',
                'Array Handle' => '0x1000',
                'Asset Tag' => '01110228',
                'Set' => '6',
                'Rank' => '1',
                'Type' => 'DDR3',
                'Serial Number' => '2A43F870',
                'Data Width' => '64 bits',
                'Error Information Handle' => 'Not Provided'
            },
            {
                'Total Width' => '72 bits',
                'Speed' => '1333 MHz',
                'Size' => '2048 MB',
                'Type Detail' => 'Synchronous',
                'Locator' => 'DIMM_B3',
                'Manufacturer' => '00AD009780AD',
                'Rank' => '1',
                'Serial Number' => '2A93F87A',
                'Type' => 'DDR3',
                'Data Width' => '64 bits',
                'Error Information Handle' => 'Not Provided',
                'Form Factor' => 'DIMM',
                'Part Number' => 'HMT325R7BFR8C-H9',
                'Asset Tag' => '01110228',
                'Array Handle' => '0x1000',
                'Set' => '6'
            },
            {
                'Size' => 'No Module Installed',
                'Data Width' => '64 bits',
                'Error Information Handle' => 'Not Provided',
                'Type' => 'DDR3',
                'Total Width' => '72 bits',
                'Array Handle' => '0x1000',
                'Set' => '4',
                'Locator' => 'DIMM_B4',
                'Form Factor' => 'DIMM',
                'Type Detail' => 'Synchronous'
            },
            {
                'Type' => 'DDR3',
                'Data Width' => '64 bits',
                'Size' => 'No Module Installed',
                'Error Information Handle' => 'Not Provided',
                'Total Width' => '72 bits',
                'Array Handle' => '0x1000',
                'Set' => '5',
                'Form Factor' => 'DIMM',
                'Type Detail' => 'Synchronous',
                'Locator' => 'DIMM_B5'
            },
            {
                'Total Width' => '72 bits',
                'Error Information Handle' => 'Not Provided',
                'Size' => 'No Module Installed',
                'Data Width' => '64 bits',
                'Type' => 'DDR3',
                'Locator' => 'DIMM_B6',
                'Type Detail' => 'Synchronous',
                'Form Factor' => 'DIMM',
                'Set' => '6',
                'Array Handle' => '0x1000'
            },
            {
                'Locator' => 'DIMM_B7',
                'Type Detail' => 'Synchronous',
                'Form Factor' => 'DIMM',
                'Set' => '4',
                'Array Handle' => '0x1000',
                'Total Width' => '72 bits',
                'Error Information Handle' => 'Not Provided',
                'Data Width' => '64 bits',
                'Size' => 'No Module Installed',
                'Type' => 'DDR3'
            },
            {
                'Array Handle' => '0x1000',
                'Set' => '5',
                'Form Factor' => 'DIMM',
                'Type Detail' => 'Synchronous',
                'Locator' => 'DIMM_B8',
                'Type' => 'DDR3',
                'Data Width' => '64 bits',
                'Size' => 'No Module Installed',
                'Error Information Handle' => 'Not Provided',
                'Total Width' => '72 bits'
            },
            {
                'Total Width' => '72 bits',
                'Data Width' => '64 bits',
                'Size' => 'No Module Installed',
                'Error Information Handle' => 'Not Provided',
                'Type' => 'DDR3',
                'Locator' => 'DIMM_B9',
                'Form Factor' => 'DIMM',
                'Type Detail' => 'Synchronous',
                'Array Handle' => '0x1000',
                'Set' => '6'
            }
        ],
        0 => [
            {
                'ROM Size' => '4096 kB',
                'Vendor' => 'Dell Inc.',
                'Runtime Size' => '64 kB',
                'Version' => '2.2.10',
                'Release Date' => '11/09/2010',
                'BIOS Revision' => '2.2',
                'Address' => '0xF0000'
            }
        ],
        4 => [
            {
                'Core Enabled' => '4',
                'Family' => 'Xeon',
                'Current Speed' => '2400 MHz',
                'Socket Designation' => 'CPU1',
                'L2 Cache Handle' => '0x0701',
                'L3 Cache Handle' => '0x0702',
                'Manufacturer' => 'Intel',
                'Status' => 'Populated, Enabled',
                'ID' => 'C2 06 02 00 FF FB EB BF',
                'Thread Count' => '8',
                'Version' => 'Intel(R) Xeon(R) CPU E5620 @ 2.40GHz',
                'Voltage' => '1.2 V',
                'Upgrade' => 'Socket LGA1366',
                'Signature' => 'Type 0, Family 6, Model 44, Stepping 2',
                'External Clock' => '5860 MHz',
                'Type' => 'Central Processor',
                'Max Speed' => '3600 MHz',
                'Core Count' => '4',
                'L1 Cache Handle' => '0x0700'
            },
            {
                'Current Speed' => '2400 MHz',
                'Socket Designation' => 'CPU2',
                'Manufacturer' => 'Intel',
                'Status' => 'Populated, Idle',
                'L3 Cache Handle' => '0x0705',
                'L2 Cache Handle' => '0x0704',
                'Thread Count' => '8',
                'ID' => 'C2 06 02 00 FF FB EB BF',
                'Family' => 'Xeon',
                'Core Enabled' => '4',
                'Core Count' => '4',
                'L1 Cache Handle' => '0x0703',
                'Version' => 'Intel(R) Xeon(R) CPU E5620 @ 2.40GHz',
                'Upgrade' => 'Socket LGA1366',
                'Voltage' => '1.2 V',
                'External Clock' => '5860 MHz',
                'Signature' => 'Type 0, Family 6, Model 44, Stepping 2',
                'Max Speed' => '3600 MHz',
                'Type' => 'Central Processor'
            }
        ],
        7 => [
            {
                'Error Correction Type' => 'Single-bit ECC',
                'System Type' => 'Data',
                'Operational Mode' => 'Write Back',
                'Associativity' => '8-way Set-associative',
                'Location' => 'Internal',
                'Installed Size' => '128 kB',
                'Maximum Size' => '128 kB',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
            },
            {
                'Error Correction Type' => 'Single-bit ECC',
                'System Type' => 'Unified',
                'Associativity' => '8-way Set-associative',
                'Operational Mode' => 'Write Back',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'Installed Size' => '1024 kB',
                'Maximum Size' => '2048 kB',
                'Location' => 'Internal'
            },
            {
                'Error Correction Type' => 'Single-bit ECC',
                'System Type' => 'Unified',
                'Operational Mode' => 'Write Back',
                'Associativity' => '16-way Set-associative',
                'Location' => 'Internal',
                'Installed Size' => '12288 kB',
                'Maximum Size' => '12288 kB',
                'Configuration' => 'Enabled, Not Socketed, Level 3',
            },
            {
                'System Type' => 'Data',
                'Error Correction Type' => 'Single-bit ECC',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'Installed Size' => '128 kB',
                'Maximum Size' => '128 kB',
                'Location' => 'Internal',
                'Associativity' => '8-way Set-associative',
                'Operational Mode' => 'Write Back'
            },
            {
                'System Type' => 'Unified',
                'Error Correction Type' => 'Single-bit ECC',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'Location' => 'Internal',
                'Maximum Size' => '2048 kB',
                'Installed Size' => '1024 kB',
                'Associativity' => '8-way Set-associative',
                'Operational Mode' => 'Write Back'
            },
            {
                'Configuration' => 'Enabled, Not Socketed, Level 3',
                'Location' => 'Internal',
                'Installed Size' => '12288 kB',
                'Maximum Size' => '12288 kB',
                'Associativity' => '16-way Set-associative',
                'Operational Mode' => 'Write Back',
                'System Type' => 'Unified',
                'Error Correction Type' => 'Single-bit ECC'
            }
        ],
        10 => [
            {
                'Status' => 'Enabled',
                'Type' => 'SAS Controller',
                'Description' => 'Integrated RAID Controller'
            }
        ],
        2 => [
            {
                'Version' => 'A07',
                'Serial Number' => '..CN708210BL002B.',
                'Product Name' => '0MD99X',
                'Manufacturer' => 'Dell Inc.'
            }
        ],
        13 => [
            {
                'Installable Languages' => '1',
                'Currently Installed Language' => 'en|US|iso8859-1'
            }
        ],
        12 => [
            {
                'Option 1' => 'NVRAM_CLR: Clear user settable NVRAM areas and set defaults',
                'Option 2' => 'PWRD_EN: Close to enable password'
            }
        ],
        1 => [
            {
                'Manufacturer' => 'Dell Inc.',
                'Product Name' => 'PowerEdge R710',
                'Serial Number' => '861YZ4J',
                'UUID' => '4C4C4544-0036-3110-8059-B8C04F5A344A',
                'Wake-up Type' => 'Power Switch'
            }
        ],
        16 => [
            {
                'Number Of Devices' => '18',
                'Location' => 'System Board Or Motherboard',
                'Error Information Handle' => 'Not Provided',
                'Maximum Capacity' => '288 GB',
                'Use' => 'System Memory',
                'Error Correction Type' => 'Multi-bit ECC'
            }
        ],
        3 => [
            {
                'Number Of Power Cords' => 'Unspecified',
                'Thermal State' => 'Safe',
                'Height' => '2 U',
                'Manufacturer' => 'Dell Inc.',
                'Boot-up State' => 'Safe',
                'OEM Information' => '0x00000000',
                'Type' => 'Rack Mount Chassis',
                'Serial Number' => '861YZ4J',
                'Contained Elements' => '0',
                'Power Supply State' => 'Safe',
                'Lock' => 'Present'
            }
        ],
        8 => [
            {
                'Port Type' => 'Video Port',
                'External Connector Type' => 'DB-15 female',
                'Internal Connector Type' => 'None'
            },
            {
                'Internal Connector Type' => 'None',
                'Port Type' => 'Video Port',
                'External Connector Type' => 'DB-15 female'
            },
            {
                'External Connector Type' => 'Access Bus (USB)',
                'Port Type' => 'USB',
                'Internal Connector Type' => 'None'
            },
            {
                'Internal Connector Type' => 'None',
                'External Connector Type' => 'Access Bus (USB)',
                'Port Type' => 'USB'
            },
            {
                'External Connector Type' => 'Access Bus (USB)',
                'Port Type' => 'USB',
                'Internal Connector Type' => 'None'
            },
            {
                'Internal Connector Type' => 'None',
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)'
            },
            {
                'Port Type' => 'USB',
                'Internal Reference Designator' => 'INT_USB',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'Access Bus (USB)'
            },
            {
                'Internal Connector Type' => 'Other',
                'External Connector Type' => 'None',
                'Port Type' => 'USB',
                'Internal Reference Designator' => 'INT_SD'
            },
            {
                'External Connector Type' => 'RJ-45',
                'Port Type' => 'Network Port',
                'Internal Connector Type' => 'None'
            },
            {
                'External Connector Type' => 'RJ-45',
                'Port Type' => 'Network Port',
                'Internal Connector Type' => 'None'
            },
            {
                'External Connector Type' => 'RJ-45',
                'Port Type' => 'Network Port',
                'Internal Connector Type' => 'None'
            },
            {
                'External Connector Type' => 'RJ-45',
                'Port Type' => 'Network Port',
                'Internal Connector Type' => 'None'
            },
            {
                'External Connector Type' => 'DB-9 male',
                'Port Type' => 'Serial Port 16550A Compatible',
                'Internal Connector Type' => 'None'
            }
        ],
        19 => [
            {
                'Physical Array Handle' => '0x1000',
                'Partition Width' => '0',
                'Range Size' => '3328 MB',
                'Starting Address' => '0x00000000000',
                'Ending Address' => '0x000CFFFFFFF'
            },
            {
                'Starting Address' => '0x00100000000',
                'Partition Width' => '0',
                'Range Size' => '4864 MB',
                'Physical Array Handle' => '0x1000',
                'Ending Address' => '0x0022FFFFFFF'
            }
        ],
        9 => [
            {
                'Bus Address' => '0000:05:00.0',
                'Type' => 'x4 PCI Express Gen 2 x8',
                'Designation' => 'PCI1',
                'Length' => 'Long',
                'Current Usage' => 'In Use'
            },
            {
                'Designation' => 'PCI2',
                'Length' => 'Long',
                'Current Usage' => 'In Use',
                'Bus Address' => '0000:04:00.0',
                'Type' => 'x4 PCI Express Gen 2 x8'
            },
            {
                'Current Usage' => 'In Use',
                'Length' => 'Long',
                'Designation' => 'PCI3',
                'Bus Address' => '0000:07:00.0',
                'Type' => 'x8 PCI Express Gen 2'
            },
            {
                'Designation' => 'PCI4',
                'Length' => 'Long',
                'Current Usage' => 'In Use',
                'Bus Address' => '0000:06:00.0',
                'Type' => 'x8 PCI Express Gen 2'
            }
        ],
        41 => [
            {
                'Reference Designation' => 'Embedded NIC 1',
                'Status' => 'Enabled',
                'Type Instance' => '1',
                'Type' => 'Ethernet',
                'Bus Address' => '0000:01:00.0'
            },
            {
                'Bus Address' => '0000:01:00.1',
                'Type' => 'Ethernet',
                'Status' => 'Enabled',
                'Reference Designation' => 'Embedded NIC 2',
                'Type Instance' => '2'
            },
            {
                'Type' => 'Ethernet',
                'Bus Address' => '0000:02:00.0',
                'Type Instance' => '3',
                'Reference Designation' => 'Embedded NIC 3',
                'Status' => 'Enabled'
            },
            {
                'Bus Address' => '0000:02:00.1',
                'Type' => 'Ethernet',
                'Type Instance' => '4',
                'Reference Designation' => 'Embedded NIC 4',
                'Status' => 'Enabled'
            },
            {
                'Bus Address' => '0000:03:00.0',
                'Type' => 'SAS Controller',
                'Type Instance' => '4',
                'Reference Designation' => 'Integrated RAID',
                'Status' => 'Enabled'
            },
            {
                'Type Instance' => '4',
                'Reference Designation' => 'Embedded Video',
                'Status' => 'Enabled',
                'Type' => 'Video',
                'Bus Address' => '0000:08:03.0'
            }
        ],
        32 => [
            {
                'Status' => 'No errors detected'
            }
        ],
        38 => [
            {
                'Base Address' => '0x0000000000000CA8 (I/O)',
                'I2C Slave Address' => '0x10',
                'Specification Version' => '2.0',
                'Register Spacing' => '32-bit Boundaries',
                'Interface Type' => 'KCS (Keyboard Control Style)'
            }
        ]
    },
    'windows' => {
        32 => [
            {
                 'Status' => 'No errors detected'
            }
        ],
        11 => [
            {
                 'String 1' => 'PS241E-5J851-FR,SS241-5J851FR+0OL'
            }
        ],
        21 => [
            {
                 'Type' => 'Touch Pad',
                 'Buttons' => '2',
                 'Interface' => 'PS/2'
            }
        ],
        7 => [
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Installed Size' => '8 kB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'CPU Internal',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'Installed SRAM Type' => 'Other',
                'System Type' => 'Data',
                'Speed' => '1 ns',
                'Associativity' => '4-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '8 kB'
            },
            {
                'Installed Size' => '512 kB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'CPU Internal',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'Installed SRAM Type' => 'Other',
                'Speed' => '1 ns',
                'Location' => 'Internal',
                'Maximum Size' => '512 kB'
            }
        ],
        17 => [
            {
                 'Bank Locator' => 'CSA 0 & 1',
                 'Data Width' => '64 bits',
                 'Array Handle' => '0x0081',
                 'Type Detail' => 'Synchronous',
                 'Total Width' => '64 bits',
                 'Type' => 'SDRAM',
                 'Size' => '256 MB',
                 'Error Information Handle' => 'Not Provided',
                 'Locator' => 'DIMM 0',
                 'Form Factor' => 'SODIMM'
            },
            {
                 'Bank Locator' => 'CSA 2 & 3',
                 'Data Width' => '64 bits',
                 'Array Handle' => '0x0081',
                 'Type Detail' => 'Synchronous',
                 'Total Width' => '64 bits',
                 'Type' => 'SDRAM',
                 'Size' => '512 MB',
                 'Error Information Handle' => 'Not Provided',
                 'Locator' => 'DIMM 1',
                 'Form Factor' => 'SODIMM'
            }
        ],
        2 => [
            {
                'Version' => 'Version A0',
                'Product Name' => 'Portable PC',
                'Serial Number' => '$$T02XB1K9',
                'Manufacturer' => 'TOSHIBA'
            }
        ],
        22 => [
            {
                 'Design Capacity' => '0 mWh',
                 'Serial Number' => '2000417915',
                 'OEM-specific Information' => '0x00000000',
                 'Manufacture Date' => '09/19/02',
                 'Chemistry' => 'Lithium Ion',
                 'Design Voltage' => '10800 mV',
                 'Location' => '1st Battery',
                 'Manufacturer' => 'TOSHIBA',
                 'Name' => 'L9088A'
            }
        ],
        1 => [
            {
                'Version' => 'PS241E-5J851-FR',
                'Wake-up Type' => 'Power Switch',
                'Product Name' => 'Satellite 2410',
                'Serial Number' => 'X2735244G',
                'Manufacturer' => 'TOSHIBA',
                'UUID' => '7FB4EA00-07CB-18F3-8041-CAD582735244'
            }
        ],
        0 => [
            {
                'Runtime Size' => '128 kB',
                'Version' => 'Version 1.10',
                'Address' => '0xE0000',
                'ROM Size' => '512 kB',
                'Release Date' => '08/13/2002',
                'Vendor' => 'TOSHIBA'
            }
        ],
        16 => [
            {
                 'Number Of Devices' => '2',
                 'Error Correction Type' => 'None',
                 'Error Information Handle' => 'Not Provided',
                 'Location' => 'System Board Or Motherboard',
                 'Maximum Capacity' => '1 GB',
                 'Use' => 'System Memory'
            }
        ],
        6 => [
            {
                'Installed Size' => '256 MB (Single-bank Connection)',
                'Socket Designation' => 'SO-DIMM',
                'Type' => 'Other DIMM SDRAM',
                'Error Status' => 'OK',
                'Enabled Size' => '256 MB (Single-bank Connection)',
                'Current Speed' => '8 ns',
                'Bank Connections' => '0 1'
            },
            {
                'Installed Size' => '512 MB (Single-bank Connection)',
                'Socket Designation' => 'SO-DIMM',
                'Type' => 'Other DIMM SDRAM',
                'Error Status' => 'OK',
                'Enabled Size' => '512 MB (Single-bank Connection)',
                'Current Speed' => '8 ns',
                'Bank Connections' => '2'
            }
        ],
        3 => [
            {
                'Power Supply State' => 'Safe',
                'Serial Number' => '00000000',
                'Thermal State' => 'Safe',
                'Asset Tag' => '0000000000',
                'Type' => 'Notebook',
                'Version' => 'Version 1.0',
                'Security Status' => 'None',
                'OEM Information' => '0x00000000',
                'Manufacturer' => 'TOSHIBA',
                'Boot-up State' => 'Safe'
            }
        ],
        9 => [
            {
                ID             => 'Adapter 1, Socket 0',
                'Length' => 'Other',
                'Designation' => 'PCMCIA0',
                'Type' => '32-bit PC Card (PCMCIA)',
                'Current Usage' => 'In Use'
            },
            {
                ID             => 'Adapter 2, Socket 0',
                'Length' => 'Other',
                'Designation' => 'PCMCIA1',
                'Type' => '32-bit PC Card (PCMCIA)',
                'Current Usage' => 'In Use'
            },
            {
                'Length' => 'Other',
                'Designation' => 'SD CARD',
                'Type' => 'Other',
                'Current Usage' => 'In Use'
            }
        ],
        12 => [
            {
                 'Option 1' => 'TOSHIBA'
            }
        ],
        20 => [
            {
                 'Memory Array Mapped Address Handle' => '0x0090',
                 'Range Size' => '641 kB',
                 'Physical Device Handle' => '0x0082',
                 'Partition Row Position' => '1',
                 'Starting Address' => '0x00000000000',
                 'Ending Address' => '0x000000A03FF'
            },
            {
                 'Memory Array Mapped Address Handle' => '0x0091',
                 'Range Size' => '262145 kB',
                 'Physical Device Handle' => '0x0082',
                 'Partition Row Position' => '1',
                 'Starting Address' => '0x00000000000',
                 'Ending Address' => '0x000100003FF'
            },
            {
                 'Memory Array Mapped Address Handle' => '0x0091',
                 'Range Size' => '524289 kB',
                 'Physical Device Handle' => '0x0083',
                 'Partition Row Position' => '1',
                 'Starting Address' => '0x00010000000',
                 'Ending Address' => '0x000300003FF'
            }
        ],
        15 => [
            {
                 'Access Address' => '0x0003',
                 'Access Method' => 'General-purpose non-volatile data functions',
                 'Data Start Offset' => '0x0000',
                 'Status' => 'Valid, Not Full',
                 'Supported Log Type Descriptors' => '0',
                 'Area Length' => '124 bytes',
                 'Header Start Offset' => '0x0000',
                 'Header Format' => 'No Header',
                 'Change Token' => '0x00000000'
            }
        ],
        8 => [
            {
                'External Reference Designator' => 'PARALLEL PORT',
                'Port Type' => 'Parallel Port ECP',
                'External Connector Type' => 'DB-25 female',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'EXTERNAL MONITOR PORT',
                'Port Type' => 'Other',
                'External Connector Type' => 'DB-15 female',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'BUILT-IN MODEM PORT',
                'Port Type' => 'Modem Port',
                'External Connector Type' => 'RJ-11',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'BUILT-IN LAN PORT',
                'Port Type' => 'Network Port',
                'External Connector Type' => 'RJ-45',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'INFRARED PORT',
                'Port Type' => 'Other',
                'External Connector Type' => 'Infrared',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'USB PORT',
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'USB PORT',
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'USB PORT',
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'HEADPHONE JACK',
                'Port Type' => 'Other',
                'External Connector Type' => 'Mini Jack (headphones)',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => '1394 PORT',
                'Port Type' => 'Firewire (IEEE P1394)',
                'External Connector Type' => 'IEEE 1394',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'MICROPHONE JACK',
                'Port Type' => 'Other',
                'External Connector Type' => 'Other',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'VIDEO-OUT JACK',
                'Port Type' => 'Other',
                'External Connector Type' => 'Other',
                'Internal Connector Type' => 'None'
            }
        ],
        4 => [
            {
                ID             => '24 0F 00 00 00 00 00 00',
                'Socket Designation' => 'uFC-PGA Socket',
                'Flags' => 'None',
                'Status' => 'Populated, Enabled',
                'Max Speed' => '1700 MHz',
                'External Clock' => '100 MHz',
                'Family' => 'Pentium 4',
                'Current Speed' => '1700 MHz',
                'L2 Cache Handle' => '0x0013',
                'Type' => 'Central Processor',
                'Signature' => 'Type 0, Family 15, Model 2, Stepping 4',
                'Upgrade' => 'ZIF Socket',
                'L1 Cache Handle' => '0x0012',
                'Voltage' => '1.3 V',
                'Manufacturer' => 'Intel Corporation',
                'L3 Cache Handle' => 'Not Provided'
            }
        ],
        24 => [
            {
                 'Front Panel Reset Status' => 'Disabled',
                 'Keyboard Password Status' => 'Disabled',
                 'Administrator Password Status' => 'Disabled',
                 'Power-On Password Status' => 'Disabled'
            }
        ],
        19 => [
            {
                 'Range Size' => '641 kB',
                 'Partition Width' => '0',
                 'Starting Address' => '0x00000000000',
                 'Physical Array Handle' => '0x0081',
                 'Ending Address' => '0x000000A03FF'
            },
            {
                  'Range Size' => '785281 kB',
                  'Partition Width' => '0',
                  'Starting Address' => '0x00000100000',
                  'Physical Array Handle' => '0x0081',
                  'Ending Address' => '0x0002FFE03FF'
            }
        ],
        10 => [
            {
                  'Type' => 'Other',
                  'Status' => 'Enabled',
                  'Description' => '1394'
            }
        ],
        5 => [
            {
                'Error Detecting Method' => 'None',
                'Maximum Total Memory Size' => '1024 MB',
                'Supported Interleave' => 'Other',
                'Maximum Memory Module Size' => '512 MB',
                'Associated Memory Slots' => '2',
                'Current Interleave' => 'Other',
                'Memory Module Voltage' => '2.9 V'
            }
        ]
    },
    'windows-hyperV' => {
        '32' => [
            {
                'Status' => 'No errors detected'
            }
        ],
        '11' => [
            {
                'String 1' => '[MS_VM_CERT/SHA1/3480ca0d534061ec9344e424f434fd3496f32c22]',
                'String 3' => 'To be filed by MSFT',
                'String 2' => '00000000000000000000000000000000'
            }
        ],
        '17' => [
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => '1024 MB',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M0',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M1',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M2',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M3',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M4',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M5',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M6',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M7',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M8',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M9',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M10',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M11',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M12',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M13',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M14',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M15',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M16',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M17',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M18',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M19',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M20',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M21',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M22',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M23',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M24',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M25',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M26',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M27',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M28',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M29',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M30',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M31',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M32',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M33',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M34',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M35',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M36',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M37',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M38',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M39',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M40',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M41',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M42',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M43',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M44',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M45',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M46',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M47',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M48',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M49',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M50',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M51',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M52',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M53',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M54',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M55',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M56',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M57',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M58',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M59',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M60',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M61',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M62',
                'Error Information Handle' => '0x0018',
            },
            {
                'Part Number' => 'None',
                'Serial Number' => 'None',
                'Set' => 'None',
                'Type' => 'Other',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Microsoft',
                'Bank Locator' => 'None',
                'Array Handle' => '0x0019',
                'Asset Tag' => 'None',
                'Locator' => 'M63',
                'Error Information Handle' => '0x0018',
            }
        ],
        '2' => [
            {
                'Version' => '7.0',
                'Product Name' => 'Virtual Machine',
                'Serial Number' => '2349-2347-2234-2340-2341-3240-48',
                'Manufacturer' => 'Microsoft Corporation'
            }
        ],
        '1' => [
            {
                'Version' => '7.0',
                'Wake-up Type' => 'Power Switch',
                'Product Name' => 'Virtual Machine',
                'Serial Number' => '2349-2347-2234-2340-2341-3240-48',
                'Manufacturer' => 'Microsoft Corporation',
                'UUID' => '3445DEE7-45D0-1244-95DD-34FAA067C1BE33E'
            }
        ],
        '18' => [
            {
                'Type' => 'OK',
            }
        ],
        '0' => [
            {
                'Runtime Size' => '64 kB',
                'Version' => '090004',
                'Address' => '0xF0000',
                'ROM Size' => '256 kB',
                'Release Date' => '03/19/2009',
                'Vendor' => 'American Megatrends Inc.'
            }
        ],
        '23' => [
            {
            'Status' => 'Disabled'
            }
        ],
        '16' => [
            {
                'Number Of Devices' => '64',
                'Error Correction Type' => 'None',
                'Error Information Handle' => '0x0018',
                'Maximum Capacity' => '2048 GB',
                'Use' => 'System Memory'
            }
        ],
        '13' => [
            {
                'Installable Languages' => '1',
                'Currently Installed Language' => 'enUS'
            }
        ],
        '3' => [
            {
                'Power Supply State' => 'Safe',
                'Serial Number' => '2349-2347-2234-2340-2341-3240-48',
                'Thermal State' => 'Other',
                'Asset Tag' => '4568-2345-6432-9324-3433-2346-47',
                'Type' => 'Desktop',
                'Version' => '7.0',
                'Security Status' => 'Other',
                'OEM Information' => '0x00000000',
                'Manufacturer' => 'Microsoft Corporation',
                'Boot-up State' => 'Safe'
            }
        ],
        '12' => [
            {
                'Option 2' => 'To Be Filled By O.E.M.',
                'Option 3' => 'To Be Filled By O.E.M.',
                'Option 1' => 'To Be Filled By O.E.M.'
            }
        ],
        '20' => [
            {
                'Memory Array Mapped Address Handle' => '0x001A',
                'Range Size' => '1048577 kB',
                'Physical Device Handle' => '0x001C',
                'Starting Address' => '0x00000000000',
                'Ending Address' => '0x000400003FF'
            }
        ],
        '8' => [
            {
                'External Reference Designator' => 'USB1',
                'Port Type' => 'USB',
                'External Connector Type' => 'Centronics',
                'Internal Reference Designator' => 'USB',
                'Internal Connector Type' => 'Centronics'
            },
            {
                'External Reference Designator' => 'USB2',
                'Port Type' => 'USB',
                'External Connector Type' => 'Centronics',
                'Internal Reference Designator' => 'USB',
                'Internal Connector Type' => 'Centronics'
            },
            {
                'External Reference Designator' => 'COM1',
                'Port Type' => 'Serial Port 16550A Compatible',
                'External Connector Type' => 'DB-9 female',
                'Internal Reference Designator' => 'COM1',
                'Internal Connector Type' => 'DB-9 female'
            },
            {
                'External Reference Designator' => 'COM2',
                'Port Type' => 'Serial Port 16550A Compatible',
                'External Connector Type' => 'DB-9 female',
                'Internal Reference Designator' => 'COM2',
                'Internal Connector Type' => 'DB-9 female'
            },
            {
                'External Reference Designator' => 'Lpt1',
                'Port Type' => 'Parallel Port ECP/EPP',
                'External Connector Type' => 'DB-25 male',
                'Internal Reference Designator' => 'Printer',
                'Internal Connector Type' => 'DB-25 male'
            },
            {
                'External Reference Designator' => 'Video',
                'Port Type' => 'Video Port',
                'External Connector Type' => 'DB-15 female',
                'Internal Reference Designator' => 'Video',
                'Internal Connector Type' => 'DB-15 male'
            },
            {
                'External Reference Designator' => 'Keyboard',
                'Port Type' => 'Keyboard Port',
                'External Connector Type' => 'PS/2',
                'Internal Reference Designator' => 'Keyboard',
                'Internal Connector Type' => 'PS/2'
            },
            {
                'External Reference Designator' => 'Mouse',
                'Port Type' => 'Mouse Port',
                'External Connector Type' => 'PS/2',
                'Internal Reference Designator' => 'Mouse',
                'Internal Connector Type' => 'PS/2'
            }
        ],
        '4' => [
            {
                'ID' => '7A 06 01 00 FF FB 8B 1F',
                'Socket Designation' => 'None',
                'Part Number' => 'None',
                'Status' => 'Populated, Enabled',
                'Max Speed' => '3733 MHz',
                'Serial Number' => 'None',
                'Family' => 'Xeon',
                'Current Speed' => '2500 MHz',
                'L2 Cache Handle' => 'Not Provided',
                'Type' => 'Central Processor',
                'Signature' => 'Type 0, Family 6, Model 23, Stepping 10',
                'L1 Cache Handle' => 'Not Provided',
                'Manufacturer' => 'GenuineIntel',
                'External Clock' => '266 MHz',
                'Asset Tag' => 'None',
                'Version' => 'Intel Xeon',
                'Upgrade' => 'None',
                'Voltage' => '1.2 V',
                'L3 Cache Handle' => 'Not Provided'
            },
            {
                'ID' => '00 00 00 00 00 00 00 00',
                'Socket Designation' => 'None',
                'Part Number' => 'None',
                'Status' => 'Unpopulated',
                'Serial Number' => 'None',
                'L2 Cache Handle' => 'Not Provided',
                'Type' => 'Central Processor',
                'L1 Cache Handle' => 'Not Provided',
                'Manufacturer' => 'None',
                'Asset Tag' => 'None',
                'Version' => 'None',
                'Upgrade' => 'None',
                'Voltage' => '2.9 V',
                'L3 Cache Handle' => 'Not Provided'
            },
            {
                'ID' => '00 00 00 00 00 00 00 00',
                'Socket Designation' => 'None',
                'Part Number' => 'None',
                'Status' => 'Unpopulated',
                'Serial Number' => 'None',
                'L2 Cache Handle' => 'Not Provided',
                'Type' => 'Central Processor',
                'L1 Cache Handle' => 'Not Provided',
                'Manufacturer' => 'None',
                'Asset Tag' => 'None',
                'Version' => 'None',
                'Upgrade' => 'None',
                'Voltage' => '2.9 V',
                'L3 Cache Handle' => 'Not Provided'
                },
            {
                'ID' => '00 00 00 00 00 00 00 00',
                'Socket Designation' => 'None',
                'Part Number' => 'None',
                'Status' => 'Unpopulated',
                'Serial Number' => 'None',
                'L2 Cache Handle' => 'Not Provided',
                'Type' => 'Central Processor',
                'L1 Cache Handle' => 'Not Provided',
                'Manufacturer' => 'None',
                'Asset Tag' => 'None',
                'Version' => 'None',
                'Upgrade' => 'None',
                'Voltage' => '2.9 V',
                'L3 Cache Handle' => 'Not Provided'
            },
            {
                'ID' => '00 00 00 00 00 00 00 00',
                'Socket Designation' => 'None',
                'Part Number' => 'None',
                'Status' => 'Unpopulated',
                'Serial Number' => 'None',
                'L2 Cache Handle' => 'Not Provided',
                'Type' => 'Central Processor',
                'L1 Cache Handle' => 'Not Provided',
                'Manufacturer' => 'None',
                'Asset Tag' => 'None',
                'Version' => 'None',
                'Upgrade' => 'None',
                'Voltage' => '2.9 V',
                'L3 Cache Handle' => 'Not Provided'
            },
            {
                'ID' => '00 00 00 00 00 00 00 00',
                'Socket Designation' => 'None',
                'Part Number' => 'None',
                'Status' => 'Unpopulated',
                'Serial Number' => 'None',
                'L2 Cache Handle' => 'Not Provided',
                'Type' => 'Central Processor',
                'L1 Cache Handle' => 'Not Provided',
                'Manufacturer' => 'None',
                'Asset Tag' => 'None',
                'Version' => 'None',
                'Upgrade' => 'None',
                'Voltage' => '2.9 V',
                'L3 Cache Handle' => 'Not Provided'
            },
            {
                'ID' => '00 00 00 00 00 00 00 00',
                'Socket Designation' => 'None',
                'Part Number' => 'None',
                'Status' => 'Unpopulated',
                'Serial Number' => 'None',
                'L2 Cache Handle' => 'Not Provided',
                'Type' => 'Central Processor',
                'L1 Cache Handle' => 'Not Provided',
                'Manufacturer' => 'None',
                'Asset Tag' => 'None',
                'Version' => 'None',
                'Upgrade' => 'None',
                'Voltage' => '2.9 V',
                'L3 Cache Handle' => 'Not Provided'
            },
            {
                'ID' => '00 00 00 00 00 00 00 00',
                'Socket Designation' => 'None',
                'Part Number' => 'None',
                'Status' => 'Unpopulated',
                'Serial Number' => 'None',
                'L2 Cache Handle' => 'Not Provided',
                'Type' => 'Central Processor',
                'L1 Cache Handle' => 'Not Provided',
                'Manufacturer' => 'None',
                'Asset Tag' => 'None',
                'Version' => 'None',
                'Upgrade' => 'None',
                'Voltage' => '2.9 V',
                'L3 Cache Handle' => 'Not Provided'
            }
        ],
        '10' => [
            {
                'Type' => 'Video',
                'Status' => 'Enabled',
                'Description' => 'To Be filled by O.E.M.'
            }
        ],
        '19' => [
            {
                'Range Size' => '1048577 kB',
                'Partition Width' => '0',
                'Starting Address' => '0x00000000000',
                'Physical Array Handle' => '0x0019',
                'Ending Address' => '0x000400003FF'
            }
        ]
    },
    'windows-xp' => {
        '32' => [
            {
                'Status' => 'No errors detected'
            }
        ],
        '11' => [
            {
                'String 1' => 'Dell System',
                'String 3' => '13[PP04X]',
                'String 2' => '5[0003]'
            }
        ],
        '21' => [
            {
                'Type' => 'Touch Pad',
                'Buttons' => '2',
                'Interface' => 'Bus Mouse'
            }
        ],
        '7' => [
            {
                'Error Correction Type' => 'None',
                'Installed Size' => '128 kB',
                'Operational Mode' => 'Write Back',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'System Type' => 'Data',
                'Associativity' => '4-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '128 kB'
            },
            {
                'Error Correction Type' => 'None',
                'Installed Size' => '6144 kB',
                'Operational Mode' => 'Varies With Memory Address',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'Installed SRAM Type' => 'Pipeline Burst',
                'System Type' => 'Unified',
                'Speed' => '15 ns',
                'Associativity' => 'Other',
                'Location' => 'Internal',
                'Maximum Size' => '6144 kB'
            }
        ],
        '17' => [
            {
                'Part Number' => 'EBE21UE8ACUA-8G-E',
                'Serial Number' => '14FA6621',
                'Data Width' => '64 bits',
                'Array Handle' => '0x1000',
                'Type Detail' => 'Synchronous',
                'Set' => 'None',
                'Asset Tag' => '200840',
                'Total Width' => '64 bits',
                'Type' => 'DDR2',
                'Speed' => '800 MHz',
                'Size' => '2048 MB',
                'Error Information Handle' => 'Not Provided',
                'Locator' => 'DIMM_A',
                'Manufacturer' => '7F7FFE0000000000',
                'Form Factor' => 'DIMM'
            },
            {
                'Part Number' => 'EBE21UE8ACUA-8G-E',
                'Serial Number' => 'AEF96621',
                'Data Width' => '64 bits',
                'Array Handle' => '0x1000',
                'Type Detail' => 'Synchronous',
                'Set' => 'None',
                'Asset Tag' => '200840',
                'Total Width' => '64 bits',
                'Type' => 'DDR2',
                'Speed' => '800 MHz',
                'Size' => '2048 MB',
                'Error Information Handle' => 'Not Provided',
                'Locator' => 'DIMM_B',
                'Manufacturer' => '7F7FFE0000000000',
                'Form Factor' => 'DIMM'
            }
        ],
        '2' => [
            {
                'Product Name' => '0P019G',
                'Serial Number' => '.HLG964J.CN129618C52450.',
                'Manufacturer' => 'Dell Inc.'
            }
        ],
        '22' => [
            {
                'Design Capacity' => '84000 mWh',
                'Maximum Error' => '3%',
                'OEM-specific Information' => '0x00000001',
                'Design Voltage' => '11100 mV',
                'SBDS Manufacture Date' => '2010-08-31',
                'SBDS Chemistry' => 'LION',
                'Location' => 'Sys. Battery Bay',
                'Manufacturer' => 'SMP',
                'Name' => 'DELL HJ59008',
                'SBDS Version' => '1.0',
                'SBDS Serial Number' => '02C7'
            }
        ],
        '1' => [
            {
                'Wake-up Type' => 'Power Switch',
                'Product Name' => 'Precision M4400',
                'Serial Number' => 'HLG964J',
                'Manufacturer' => 'Dell Inc.',
                'UUID' => '44454C4C-4C00-1047-8039-C8C04F36344A'
            }
        ],
        '0' => [
            {
                'BIOS Revision' => '2.4',
                'Address' => '0xF0000',
                'Vendor' => 'Dell Inc.',
                'Version' => 'A24',
                'Runtime Size' => '64 kB',
                'Firmware Revision' => '2.4',
                'Release Date' => '08/19/2010',
                'ROM Size' => '1728 kB'
            }
        ],
        '16' => [
            {
                'Number Of Devices' => '2',
                'Error Correction Type' => 'None',
                'Error Information Handle' => 'Not Provided',
                'Location' => 'System Board Or Motherboard',
                'Maximum Capacity' => '8 GB',
                'Use' => 'System Memory'
            }
        ],
        '13' => [
            {
                'Language Description Format' => 'Long',
                'Installable Languages' => '1',
                'Currently Installed Language' => 'en|US|iso8859-1'
            }
        ],
        '27' => [
            {
                'Type' => 'Fan',
                'Status' => 'OK',
                'OEM-specific Information' => '0x0000DD00'
            }
        ],
        '28' => [
            {
                'Status' => 'OK',
                'Minimum Value' => '0.0 deg C',
                'OEM-specific Information' => '0x0000DC00',
                'Maximum Value' => '127.0 deg C',
                'Resolution' => '1.000 deg C',
                'Location' => 'Processor',
                'Tolerance' => '0.5 deg C',
                'Description' => 'CPU Internal Temperature'
            }
        ],
        '3' => [
            {
                'Type' => 'Portable',
                'Power Supply State' => 'Safe',
                'Security Status' => 'None',
                'Serial Number' => 'HLG964J',
                'Thermal State' => 'Safe',
                'Boot-up State' => 'Safe',
                'Manufacturer' => 'Dell Inc.'
            }
        ],
        '9' => [
            {
                'ID' => 'Adapter 0, Socket 0',
                'Length' => 'Other',
                'Designation' => 'PCMCIA 0',
                'Type' => '32-bit PC Card (PCMCIA)',
                'Current Usage' => 'Available'
            }
        ],
        '20' => [
            {
                'Range Size' => '4 GB',
                'Partition Row Position' => '1',
                'Starting Address' => '0x00000000000',
                'Memory Array Mapped Address Handle' => '0x1301',
                'Physical Device Handle' => '0x1100',
                'Interleaved Data Depth' => '8',
                'Interleave Position' => '1',
                'Ending Address' => '0x000FFFFFFFF'
            },
            {
                'Range Size' => '4 GB',
                'Partition Row Position' => '1',
                'Starting Address' => '0x00000000000',
                'Memory Array Mapped Address Handle' => '0x1301',
                'Physical Device Handle' => '0x1101',
                'Interleaved Data Depth' => '8',
                'Interleave Position' => '2',
                'Ending Address' => '0x000FFFFFFFF'
            }
        ],
        '8' => [
            {
                'Port Type' => 'Parallel Port PS/2',
                'External Connector Type' => 'DB-25 female',
                'Internal Reference Designator' => 'PARALLEL',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Serial Port 16550A Compatible',
                'External Connector Type' => 'DB-9 male',
                'Internal Reference Designator' => 'SERIAL1',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'Internal Reference Designator' => 'USB',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Video Port',
                'External Connector Type' => 'DB-15 female',
                'Internal Reference Designator' => 'MONITOR',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Firewire (IEEE P1394)',
                'External Connector Type' => 'IEEE 1394',
                'Internal Reference Designator' => 'FireWire',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Modem Port',
                'External Connector Type' => 'RJ-11',
                'Internal Reference Designator' => 'Modem',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Network Port',
                'External Connector Type' => 'RJ-45',
                'Internal Reference Designator' => 'Ethernet',
                'Internal Connector Type' => 'None'
            }
        ],
        '4' => [
            {
                'ID' => '76 06 01 00 FF FB EB BF',
                'Socket Designation' => 'Microprocessor',
                'Status' => 'Populated, Enabled',
                'Max Speed' => '2534 MHz',
                'Family' => 'Core 2 Duo',
                'Thread Count' => '2',
                'Current Speed' => '2534 MHz',
                'L2 Cache Handle' => '0x0701',
                'Type' => 'Central Processor',
                'Signature' => 'Type 0, Family 6, Model 23, Stepping 6',
                'L1 Cache Handle' => '0x0700',
                'Manufacturer' => 'Intel',
                'Core Enabled' => '2',
                'External Clock' => '266 MHz',
                'Upgrade' => 'None',
                'Core Count' => '2',
                'Voltage' => '3.3 V',
                'L3 Cache Handle' => 'Not Provided'
            }
        ],
        '10' => [
            {
                'Type' => 'Video',
                'Status' => 'Enabled',
                'Description' => 'NVIDIA Quadro FX 1700M'
            },
            {
                'Type' => 'Sound',
                'Status' => 'Enabled',
                'Description' => 'IDT 92HD71'
            }
        ],
        '19' => [
            {
                'Range Size' => '4 GB',
                'Partition Width' => '1',
                'Starting Address' => '0x00000000000',
                'Physical Array Handle' => '0x1000',
                'Ending Address' => '0x000FFFFFFFF'
            }
        ]
    },
    'windows-7' => {
        '35' => [
            {
                'Threshold Handle' => '0x0035',
                'Management Device Handle' => '0x0034',
                'Description' => 'To Be Filled By O.E.M.',
                'Component Handle' => '0x0034'
            },
            {
                'Threshold Handle' => '0x0038',
                'Management Device Handle' => '0x0034',
                'Description' => 'To Be Filled By O.E.M.',
                'Component Handle' => '0x0037'
            },
            {
                'Threshold Handle' => '0x003B',
                'Management Device Handle' => '0x0034',
                'Description' => 'To Be Filled By O.E.M.',
                'Component Handle' => '0x003A'
            },
            {
                'Threshold Handle' => '0x003E',
                'Management Device Handle' => '0x0034',
                'Description' => 'To Be Filled By O.E.M.',
                'Component Handle' => '0x003D'
            },
            {
                'Threshold Handle' => '0x003E',
                'Management Device Handle' => '0x0034',
                'Description' => 'To Be Filled By O.E.M.',
                'Component Handle' => '0x0040'
            },
            {
                'Threshold Handle' => '0x0046',
                'Management Device Handle' => '0x0045',
                'Description' => 'To Be Filled By O.E.M.',
                'Component Handle' => '0x0045'
            },
            {
                'Threshold Handle' => '0x0049',
                'Management Device Handle' => '0x0045',
                'Description' => 'To Be Filled By O.E.M.',
                'Component Handle' => '0x0048'
            },
            {
                'Threshold Handle' => '0x004C',
                'Management Device Handle' => '0x0045',
                'Description' => 'To Be Filled By O.E.M.',
                'Component Handle' => '0x004B'
            },
            {
                'Threshold Handle' => '0x004F',
                'Management Device Handle' => '0x0045',
                'Description' => 'To Be Filled By O.E.M.',
                'Component Handle' => '0x004E'
            },
            {
                'Threshold Handle' => '0x0052',
                'Management Device Handle' => '0x0045',
                'Description' => 'To Be Filled By O.E.M.',
                'Component Handle' => '0x0051'
            },
            {
                'Threshold Handle' => '0x0055',
                'Management Device Handle' => '0x0045',
                'Description' => 'To Be Filled By O.E.M.',
                'Component Handle' => '0x0054'
            },
            {
                'Threshold Handle' => '0x0055',
                'Management Device Handle' => '0x0045',
                'Description' => 'To Be Filled By O.E.M.',
                'Component Handle' => '0x0057'
            },
            {
                'Threshold Handle' => '0x0055',
                'Management Device Handle' => '0x0045',
                'Description' => 'To Be Filled By O.E.M.',
                'Component Handle' => '0x005A'
            }
        ],
        '32' => [
            {
            'Status' => 'No errors detected'
            }
        ],
        '11' => [
            {
            'String 1' => 'To Be Filled By O.E.M.'
            }
        ],
        '7' => [
            {
                'Error Correction Type' => 'None',
                'Installed Size' => '256 kB',
                'Operational Mode' => 'Write Back',
                'Socket Designation' => 'L1-Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'Installed SRAM Type' => 'Other',
                'System Type' => 'Unified',
                'Associativity' => '8-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '256 kB'
            },
            {
                'Error Correction Type' => 'None',
                'Installed Size' => '1024 kB',
                'Operational Mode' => 'Varies With Memory Address',
                'Socket Designation' => 'L2-Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 2',
                'Installed SRAM Type' => 'Other',
                'System Type' => 'Unified',
                'Associativity' => '8-way Set-associative',
                'Location' => 'Internal',
                'Maximum Size' => '1024 kB'
            },
            {
                'Error Correction Type' => 'None',
                'Installed Size' => '6144 kB',
                'Socket Designation' => 'L3-Cache',
                'Configuration' => 'Disabled, Not Socketed, Level 3',
                'Installed SRAM Type' => 'Other',
                'System Type' => 'Unified',
                'Associativity' => 'Other',
                'Location' => 'Internal',
                'Maximum Size' => '6144 kB'
            }
        ],
        '26' => [
            {
                'OEM-specific Information' => '0x00000000',
                'Description' => 'LM78A'
            },
            {
                'OEM-specific Information' => '0x00000000',
                'Description' => 'LM78B'
            },
            {
                'OEM-specific Information' => '0x00000000',
                'Description' => 'LM78B'
            }
        ],
        '17' => [
            {
                'Part Number' => 'Array1_PartNumber0',
                'Serial Number' => 'SerNum0',
                'Type Detail' => 'Synchronous',
                'Set' => 'None',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Manufacturer0',
                'Bank Locator' => 'BANK0',
                'Array Handle' => '0x0024',
                'Data Width' => '64 bits',
                'Total Width' => '64 bits',
                'Asset Tag' => 'AssetTagNum0',
                'Locator' => 'DIMM0',
                'Error Information Handle' => 'No Error',
                'Form Factor' => 'DIMM'
            },
            {
                'Part Number' => 'F3-12800CL9-2GBXL',
                'Serial Number' => '0000000',
                'Type Detail' => 'Synchronous',
                'Set' => 'None',
                'Speed' => '1600 MHz',
                'Size' => '2048 MB',
                'Manufacturer' => 'Undefined',
                'Bank Locator' => 'BANK1',
                'Array Handle' => '0x0024',
                'Data Width' => '64 bits',
                'Total Width' => '64 bits',
                'Asset Tag' => 'AssetTagNum1',
                'Rank' => '2',
                'Locator' => 'DIMM1',
                'Error Information Handle' => 'No Error',
                'Form Factor' => 'DIMM'
            },
            {
                'Part Number' => 'Array1_PartNumber2',
                'Serial Number' => 'SerNum2',
                'Type Detail' => 'Synchronous',
                'Set' => 'None',
                'Size' => 'No Module Installed',
                'Manufacturer' => 'Manufacturer2',
                'Bank Locator' => 'BANK2',
                'Array Handle' => '0x0024',
                'Data Width' => '64 bits',
                'Total Width' => '64 bits',
                'Asset Tag' => 'AssetTagNum2',
                'Locator' => 'DIMM2',
                'Error Information Handle' => 'No Error',
                'Form Factor' => 'DIMM'
            },
            {
                'Part Number' => 'F3-12800CL9-2GBXL',
                'Serial Number' => '0000000',
                'Type Detail' => 'Synchronous',
                'Set' => 'None',
                'Speed' => '1600 MHz',
                'Size' => '2048 MB',
                'Manufacturer' => 'Undefined',
                'Bank Locator' => 'BANK3',
                'Array Handle' => '0x0024',
                'Data Width' => '64 bits',
                'Total Width' => '64 bits',
                'Asset Tag' => 'AssetTagNum3',
                'Rank' => '2',
                'Locator' => 'DIMM3',
                'Error Information Handle' => 'No Error',
                'Form Factor' => 'DIMM'
            }
        ],
        '2' => [
            {
                'Product Name' => 'P8P67',
                'Chassis Handle' => '0x0003',
                'Serial Number' => 'MT7013K30709271',
                'Asset Tag' => 'To be filled by O.E.M.',
                'Version' => 'Rev 1.xx',
                'Type' => 'Motherboard',
                'Manufacturer' => 'ASUSTeK Computer INC.',
                'Location In Chassis' => 'To be filled by O.E.M.',
                'Contained Object Handles' => '0'
            }
        ],
        '1' => [
            {
                'Product Name' => 'System Product Name',
                'Family' => 'To be filled by O.E.M.',
                'Serial Number' => 'System Serial Number',
                'Version' => 'System Version',
                'Wake-up Type' => 'Power Switch',
                'SKU Number' => 'To be filled by O.E.M.',
                'Manufacturer' => 'System manufacturer',
                'UUID' => '1E00E6E0-008C-4400-9AAD-F46D04972D3E'
            }
        ],
        '18' => [
            {
                'Type' => 'OK',
            },
            {
                'Type' => 'OK',
            },
            {
                'Type' => 'OK',
            },
            {
                'Type' => 'OK',
            },
            {
                'Type' => 'OK',
            }
        ],
        '0' => [
            {
                'Runtime Size' => '64 kB',
                'Version' => '1503',
                'BIOS Revision' => '4.6',
                'Address' => '0xF0000',
                'ROM Size' => '4096 kB',
                'Release Date' => '03/10/2011',
                'Vendor' => 'American Megatrends Inc.'
            }
        ],
        '13' => [
            {
                'Installable Languages' => '6',
                'Currently Installed Language' => 'eng'
            }
        ],
        '16' => [
            {
                'Number Of Devices' => '4',
                'Error Correction Type' => 'None',
                'Error Information Handle' => 'No Error',
                'Location' => 'System Board Or Motherboard',
                'Maximum Capacity' => '32 GB',
                'Use' => 'System Memory'
            }
        ],
        '29' => [
            {
                'OEM-specific Information' => '0x00000000',
                'Description' => 'ABC'
            },
            {
                'OEM-specific Information' => '0x00000000',
                'Description' => 'DEF'
            },
            {
                'OEM-specific Information' => '0x00000000',
                'Description' => 'GHI'
            }
        ],
        '27' => [
            {
                'Temperature Probe Handle' => '0x0038',
                'OEM-specific Information' => '0x00000000',
                'Cooling Unit Group' => '1',
                'Nominal Speed' => 'Unknown Or Non-rotating'
            },
            {
                'Temperature Probe Handle' => '0x0038',
                'OEM-specific Information' => '0x00000000',
                'Cooling Unit Group' => '1',
                'Nominal Speed' => 'Unknown Or Non-rotating'
            },
            {
                'Temperature Probe Handle' => '0x004C',
                'OEM-specific Information' => '0x00000000',
                'Cooling Unit Group' => '1',
                'Nominal Speed' => 'Unknown Or Non-rotating'
            },
            {
                'Temperature Probe Handle' => '0x0052',
                'OEM-specific Information' => '0x00000000',
                'Cooling Unit Group' => '1',
                'Nominal Speed' => 'Unknown Or Non-rotating'
            }
        ],
        '39' => [
            {
                'Input Voltage Probe Handle' => '0x0035',
                'Revision' => 'To Be Filled By O.E.M.',
                'Serial Number' => 'To Be Filled By O.E.M.',
                'Hot Replaceable' => 'No',
                'Asset Tag' => 'To Be Filled By O.E.M.',
                'Input Current Probe Handle' => '0x0041',
                'Model Part Number' => 'To Be Filled By O.E.M.',
                'Cooling Device Handle' => '0x003B',
                'Plugged' => 'Yes',
                'Power Unit Group' => '1',
                'Location' => 'To Be Filled By O.E.M.',
                'Manufacturer' => 'To Be Filled By O.E.M.',
                'Name' => 'To Be Filled By O.E.M.',
            },
            {
                'Input Voltage Probe Handle' => '0x0035',
                'Revision' => 'To Be Filled By O.E.M.',
                'Serial Number' => 'To Be Filled By O.E.M.',
                'Hot Replaceable' => 'No',
                'Asset Tag' => 'To Be Filled By O.E.M.',
                'Input Current Probe Handle' => '0x0041',
                'Model Part Number' => 'To Be Filled By O.E.M.',
                'Cooling Device Handle' => '0x003B',
                'Plugged' => 'Yes',
                'Power Unit Group' => '1',
                'Location' => 'To Be Filled By O.E.M.',
                'Manufacturer' => 'To Be Filled By O.E.M.',
                'Name' => 'To Be Filled By O.E.M.',
            }
        ],
        '28' => [
            {
                'OEM-specific Information' => '0x00000000',
                'Description' => 'LM78A'
            },
            {
                'OEM-specific Information' => '0x00000000',
                'Description' => 'LM78B'
            },
            {
                'OEM-specific Information' => '0x00000000',
                'Description' => 'LM78B'
            }
        ],
        '36' => [
            {
                'Lower Non-critical Threshold' => '1',
                'Upper Critical Threshold' => '4',
                'Lower Critical Threshold' => '3',
                'Lower Non-recoverable Threshold' => '5',
                'Upper Non-recoverable Threshold' => '6',
                'Upper Non-critical Threshold' => '2'
            },
            {
                'Lower Non-critical Threshold' => '1',
                'Upper Critical Threshold' => '4',
                'Lower Critical Threshold' => '3',
                'Lower Non-recoverable Threshold' => '5',
                'Upper Non-recoverable Threshold' => '6',
                'Upper Non-critical Threshold' => '2'
            },
            {
                'Lower Non-critical Threshold' => '1',
                'Upper Critical Threshold' => '4',
                'Lower Critical Threshold' => '3',
                'Lower Non-recoverable Threshold' => '5',
                'Upper Non-recoverable Threshold' => '6',
                'Upper Non-critical Threshold' => '2'
            },
            {
                'Lower Non-critical Threshold' => '1',
                'Upper Critical Threshold' => '4',
                'Lower Critical Threshold' => '3',
                'Lower Non-recoverable Threshold' => '5',
                'Upper Non-recoverable Threshold' => '6',
                'Upper Non-critical Threshold' => '2'
            },
            {
                'Lower Non-critical Threshold' => '7',
                'Upper Critical Threshold' => '10',
                'Lower Critical Threshold' => '8',
                'Lower Non-recoverable Threshold' => '11',
                'Upper Non-recoverable Threshold' => '12',
                'Upper Non-critical Threshold' => '8'
            },
            {
                'Lower Non-critical Threshold' => '13',
                'Upper Critical Threshold' => '16',
                'Lower Critical Threshold' => '15',
                'Lower Non-recoverable Threshold' => '17',
                'Upper Non-recoverable Threshold' => '18',
                'Upper Non-critical Threshold' => '14'
            },
            {
                'Lower Non-critical Threshold' => '1',
                'Upper Critical Threshold' => '4',
                'Lower Critical Threshold' => '3',
                'Lower Non-recoverable Threshold' => '5',
                'Upper Non-recoverable Threshold' => '6',
                'Upper Non-critical Threshold' => '2'
            },
            {
                'Lower Non-critical Threshold' => '1',
                'Upper Critical Threshold' => '4',
                'Lower Critical Threshold' => '3',
                'Lower Non-recoverable Threshold' => '5',
                'Upper Non-recoverable Threshold' => '6',
                'Upper Non-critical Threshold' => '2'
            },
            {
                'Lower Non-critical Threshold' => '1',
                'Upper Critical Threshold' => '4',
                'Lower Critical Threshold' => '3',
                'Lower Non-recoverable Threshold' => '5',
                'Upper Non-recoverable Threshold' => '6',
                'Upper Non-critical Threshold' => '2'
            },
            {
                'Lower Non-critical Threshold' => '1',
                'Upper Critical Threshold' => '4',
                'Lower Critical Threshold' => '3',
                'Lower Non-recoverable Threshold' => '5',
                'Upper Non-recoverable Threshold' => '6',
                'Upper Non-critical Threshold' => '2'
            }
        ],
        '3' => [
            {
                'Height' => 'Unspecified',
                'Power Supply State' => 'Safe',
                'Serial Number' => 'Chassis Serial Number',
                'Thermal State' => 'Safe',
                'Contained Elements' => '0',
                'Asset Tag' => 'Asset-1234567890',
                'Type' => 'Desktop',
                'Version' => 'Chassis Version',
                'Number Of Power Cords' => '1',
                'Security Status' => 'None',
                'OEM Information' => '0x00000000',
                'Manufacturer' => 'Chassis Manufacture',
                'Boot-up State' => 'Safe'
            }
        ],
        '9' => [
            {
                'Bus Address' => '0000:00:01.0',
                'ID' => '1',
                'Length' => 'Short',
                'Designation' => 'PCIEX16_1',
                'Type' => '32-bit PCI Express',
                'Current Usage' => 'In Use'
            },
            {
                'Bus Address' => '0000:00:1c.3',
                'ID' => '2',
                'Length' => 'Short',
                'Designation' => 'PCIEX1_1',
                'Type' => '32-bit PCI Express',
                'Current Usage' => 'In Use'
            },
            {
                'Bus Address' => '0000:00:1c.4',
                'ID' => '3',
                'Length' => 'Short',
                'Designation' => 'PCIEX1_2',
                'Type' => '32-bit PCI Express',
                'Current Usage' => 'In Use'
            },
            {
                'Bus Address' => '0000:00:1c.6',
                'ID' => '4',
                'Length' => 'Short',
                'Designation' => 'PCI1',
                'Type' => '32-bit PCI',
                'Current Usage' => 'In Use'
            }
        ],
        '41' => [
            {
                'Bus Address' => '0000:00:02.0',
                'Type' => 'Video',
                'Reference Designation' => 'Onboard IGD',
                'Type Instance' => '1',
                'Status' => 'Enabled'
            },
            {
                'Bus Address' => '0000:00:19.0',
                'Type' => 'Ethernet',
                'Reference Designation' => 'Onboard LAN',
                'Type Instance' => '1',
                'Status' => 'Enabled'
            },
            {
                'Bus Address' => '0000:03:1c.2',
                'Type' => 'Other',
                'Reference Designation' => 'Onboard 1394',
                'Type Instance' => '1',
                'Status' => 'Enabled'
            }
        ],
        '12' => [
            {
                'Option 1' => 'To Be Filled By O.E.M.'
            }
        ],
        '20' => [
            {
                'Memory Array Mapped Address Handle' => '0x0026',
                'Range Size' => '2 GB',
                'Physical Device Handle' => '0x002A',
                'Partition Row Position' => '1',
                'Starting Address' => '0x00000000000',
                'Ending Address' => '0x0007FFFFFFF'
            },
            {
                'Memory Array Mapped Address Handle' => '0x0026',
                'Range Size' => '2 GB',
                'Physical Device Handle' => '0x0030',
                'Partition Row Position' => '1',
                'Starting Address' => '0x00080000000',
                'Ending Address' => '0x000FFFFFFFF'
            }
        ],
        '8' => [
            {
                'External Reference Designator' => 'PS/2 Keyboard',
                'Port Type' => 'Keyboard Port',
                'External Connector Type' => 'PS/2',
                'Internal Reference Designator' => 'PS/2 Keyboard',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'USB9_10',
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'Internal Reference Designator' => 'USB9_10',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'USB11_12',
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'Internal Reference Designator' => 'USB11_12',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'GbE LAN',
                'Port Type' => 'Network Port',
                'External Connector Type' => 'RJ-45',
                'Internal Reference Designator' => 'GbE LAN',
                'Internal Connector Type' => 'None'
            },
            {
                'External Reference Designator' => 'AUDIO',
                'Port Type' => 'Audio Port',
                'External Connector Type' => 'Other',
                'Internal Reference Designator' => 'AUDIO',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'SATA',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'SATA1',
                'Internal Connector Type' => 'SAS/SATA Plug Receptacle'
            },
            {
                'Port Type' => 'SATA',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'SATA2',
                'Internal Connector Type' => 'SAS/SATA Plug Receptacle'
            },
            {
                'Port Type' => 'SATA',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'SATA3',
                'Internal Connector Type' => 'SAS/SATA Plug Receptacle'
            },
            {
                'Port Type' => 'SATA',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'SATA4',
                'Internal Connector Type' => 'SAS/SATA Plug Receptacle'
            },
            {
                'Port Type' => 'SATA',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'SATA5',
                'Internal Connector Type' => 'SAS/SATA Plug Receptacle'
            },
            {
                'Port Type' => 'SATA',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'SATA6',
                'Internal Connector Type' => 'SAS/SATA Plug Receptacle'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'USB1_2',
                'Internal Connector Type' => 'Access Bus (USB)'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'USB3_4',
                'Internal Connector Type' => 'Access Bus (USB)'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'USB5_6',
                'Internal Connector Type' => 'Access Bus (USB)'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'USB7_8',
                'Internal Connector Type' => 'Access Bus (USB)'
            },
            {
                'Port Type' => 'Audio Port',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'AAFP',
                'Internal Connector Type' => 'Mini Jack (headphones)'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'CPU_FAN',
                'Internal Connector Type' => 'Other'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'CHA_FAN1',
                'Internal Connector Type' => 'Other'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'PWR_FAN',
                'Internal Connector Type' => 'Other'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'PATA_IDE',
                'Internal Connector Type' => 'On Board IDE'
            },
            {
                'Port Type' => 'SATA',
                'External Connector Type' => 'None',
                'Internal Reference Designator' => 'F_ESATA',
                'Internal Connector Type' => 'SAS/SATA Plug Receptacle'
            }
        ],
        '4' => [
            {
                'ID' => 'A7 06 02 00 FF FB EB BF',
                'Socket Designation' => 'LGA1155',
                'Part Number' => 'To Be Filled By O.E.M.',
                'Status' => 'Populated, Enabled',
                'Max Speed' => '3800 MHz',
                'Serial Number' => 'To Be Filled By O.E.M.',
                'Family' => 'Core 2 Duo',
                'Current Speed' => '2800 MHz',
                'L2 Cache Handle' => '0x0006',
                'Type' => 'Central Processor',
                'Signature' => 'Type 0, Family 6, Model 42, Stepping 7',
                'L1 Cache Handle' => '0x0005',
                'Manufacturer' => 'Intel',
                'Core Enabled' => '1',
                'External Clock' => '100 MHz',
                'Asset Tag' => 'To Be Filled By O.E.M.',
                'Version' => 'Intel(R) Core(TM) i5-2300 CPU @ 2.80GHz',
                'Core Count' => '4',
                'Upgrade' => 'Other',
                'Voltage' => '1.0 V',
                'L3 Cache Handle' => '0x0007'
            }
        ],
        '34' => [
            {
                'Type' => 'LM78',
                'Address Type' => 'I/O Port',
                'Address' => '0x00000000',
                'Description' => 'LM78-1'
            },
            {
                'Type' => 'LM78',
                'Address Type' => 'I/O Port',
                'Address' => '0x00000000',
                'Description' => '2'
            }
        ],
        '10' => [
            {
                'Type' => 'Ethernet',
                'Status' => 'Enabled',
                'Description' => 'Onboard Ethernet'
            }
        ],
        '19' => [
            {
                'Range Size' => '4 GB',
                'Partition Width' => '0',
                'Starting Address' => '0x00000000000',
                'Physical Array Handle' => '0x0024',
                'Ending Address' => '0x000FFFFFFFF'
            }
        ]
    },
    'windows-7.2' => {
        '20' => [
            {
                'Physical Device Handle' => '0x003D',
                'Partition Row Position' => '1',
                'Memory Array Mapped Address Handle' => '0x003C',
                'Ending Address' => '0x0007FFFFFFF',
                'Range Size' => '2 GB',
                'Starting Address' => '0x00000000000'
            },
            {
                'Physical Device Handle' => '0x003F',
                'Memory Array Mapped Address Handle' => '0x003C',
                'Partition Row Position' => '1',
                'Range Size' => '2 GB',
                'Starting Address' => '0x00080000000',
                'Ending Address' => '0x000FFFFFFFF'
            },
            {
                'Ending Address' => '0x0013FFFFFFF',
                'Range Size' => '1 GB',
                'Starting Address' => '0x00100000000',
                'Partition Row Position' => '1',
                'Memory Array Mapped Address Handle' => '0x003C',
                'Physical Device Handle' => '0x0041'
            },
            {
                'Starting Address' => '0x00140000000',
                'Range Size' => '1 GB',
                'Ending Address' => '0x0017FFFFFFF',
                'Memory Array Mapped Address Handle' => '0x003C',
                'Partition Row Position' => '1',
                'Physical Device Handle' => '0x0043'
            }
        ],
        '16' => [
            {
                'Error Correction Type' => 'None',
                'Maximum Capacity' => '8 GB',
                'Error Information Handle' => 'Not Provided',
                'Use' => 'System Memory',
                'Number Of Devices' => '4',
                'Location' => 'System Board Or Motherboard'
            }
        ],
        '19' => [
            {
                'Ending Address' => '0x0019FFFFFFF',
                'Range Size' => '6656 MB',
                'Physical Array Handle' => '0x003B',
                'Starting Address' => '0x00000000000',
                'Partition Width' => '1'
            }
        ],
        '32' => [
            {
                'Status' => 'No errors detected'
            }
        ],
        '1' => [
            {
                'Family' => 'To Be Filled By O.E.M.',
                'SKU Number' => 'To Be Filled By O.E.M.',
                'Version' => 'System Version',
                'Wake-up Type' => 'Power Switch',
                'Manufacturer' => 'System manufacturer',
                'Product Name' => 'System Product Name',
                'Serial Number' => 'System Serial Number',
                'UUID' => '0002869A-8EFE-D511-868C-002618C9DFD4'
            }
        ],
        '7' => [
            {
                'Error Correction Type' => 'Single-bit ECC',
                'Associativity' => '4-way Set-associative',
                'Maximum Size' => '256 kB',
                'Operational Mode' => 'Varies With Memory Address',
                'Socket Designation' => 'L1-Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 1',
                'Installed Size' => '256 kB',
                'System Type' => 'Data',
                'Installed SRAM Type' => 'Pipeline Burst',
                'Location' => 'Internal'
            },
            {
                'Operational Mode' => 'Varies With Memory Address',
                'Error Correction Type' => 'Single-bit ECC',
                'Associativity' => '4-way Set-associative',
                'Maximum Size' => '2048 kB',
                'Installed Size' => '2048 kB',
                'System Type' => 'Unified',
                'Location' => 'Internal',
                'Installed SRAM Type' => 'Pipeline Burst',
                'Socket Designation' => 'L2-Cache',
                'Configuration' => 'Enabled, Not Socketed, Level 2'
            },
            {
                'Socket Designation' => 'L3-Cache',
                'Maximum Size' => '0 kB',
                'Configuration' => 'Disabled, Not Socketed, Level 3',
                'Installed Size' => '0 kB',
                'Location' => 'Internal'
            }
        ],
        '4' => [
            {
                'Status' => 'Populated, Enabled',
                'Max Speed' => '3200 MHz',
                'Socket Designation' => 'AM2',
                'ID' => '62 0F 10 00 FF FB 8B 17',
                'Type' => 'Central Processor',
                'External Clock' => '200 MHz',
                'L2 Cache Handle' => '0x0006',
                'Asset Tag' => 'To Be Filled By O.E.M.',
                'Current Speed' => '2900 MHz',
                'L3 Cache Handle' => '0x0007',
                'L1 Cache Handle' => '0x0005',
                'Serial Number' => 'To Be Filled By O.E.M.',
                'Signature' => 'Family 16, Model 6, Stepping 2',
                'Part Number' => 'To Be Filled By O.E.M.',
                'Core Enabled' => '2',
                'Voltage' => '1.5 V',
                'Version' => 'AMD Athlon(tm) II X2 245 Processor',
                'Family' => 'Athlon II',
                'Core Count' => '2',
                'Manufacturer' => 'AMD',
                'Upgrade' => 'Other'
            }
        ],
        '9' => [
            {
                'Length' => 'Short',
                'Current Usage' => 'In Use',
                'Designation' => 'PCIE1X',
                'ID' => '4',
                'Type' => '32-bit PCI Express'
            },
            {
                'Current Usage' => 'Available',
                'Length' => 'Short',
                'Designation' => 'PCIE16X',
                'Type' => '32-bit PCI Express',
                'ID' => '2'
            },
            {
                'Current Usage' => 'Available',
                'Length' => 'Short',
                'Type' => '32-bit PCI',
                'ID' => '3',
                'Designation' => 'PCI1'
            },
            {
                'Current Usage' => 'Available',
                'Length' => 'Short',
                'ID' => '1',
                'Type' => '32-bit PCI',
                'Designation' => 'PCI2'
            }
        ],
        '17' => [
            {
                'Speed' => '667 MHz',
                'Serial Number' => 'SerNum0',
                'Set' => 'None',
                'Total Width' => '64 bits',
                'Part Number' => 'PartNum0',
                'Bank Locator' => 'BANK0',
                'Type Detail' => 'Synchronous',
                'Size' => '2048 MB',
                'Form Factor' => 'DIMM',
                'Manufacturer' => 'Manufacturer0',
                'Error Information Handle' => 'Not Provided',
                'Type' => 'DDR2',
                'Asset Tag' => 'AssetTagNum0',
                'Array Handle' => '0x003B',
                'Locator' => 'DIMM0',
                'Data Width' => '64 bits'
            },
            {
                'Data Width' => '64 bits',
                'Locator' => 'DIMM1',
                'Asset Tag' => 'AssetTagNum1',
                'Array Handle' => '0x003B',
                'Error Information Handle' => 'Not Provided',
                'Type' => 'DDR2',
                'Manufacturer' => 'Manufacturer1',
                'Size' => '2048 MB',
                'Form Factor' => 'DIMM',
                'Type Detail' => 'Synchronous',
                'Bank Locator' => 'BANK1',
                'Part Number' => 'PartNum1',
                'Set' => 'None',
                'Total Width' => '64 bits',
                'Speed' => '667 MHz',
                'Serial Number' => 'SerNum1'
            },
            {
                'Locator' => 'DIMM2',
                'Data Width' => '64 bits',
                'Error Information Handle' => 'Not Provided',
                'Type' => 'DDR2',
                'Asset Tag' => 'AssetTagNum2',
                'Array Handle' => '0x003B',
                'Bank Locator' => 'BANK2',
                'Type Detail' => 'Synchronous',
                'Size' => '1024 MB',
                'Form Factor' => 'DIMM',
                'Manufacturer' => 'Manufacturer2',
                'Speed' => '667 MHz',
                'Serial Number' => 'SerNum2',
                'Set' => 'None',
                'Total Width' => '64 bits',
                'Part Number' => 'PartNum2'
            },
            {
                'Type Detail' => 'Synchronous',
                'Bank Locator' => 'BANK3',
                'Form Factor' => 'DIMM',
                'Size' => '1024 MB',
                'Manufacturer' => 'Manufacturer3',
                'Speed' => '667 MHz',
                'Serial Number' => 'SerNum3',
                'Set' => 'None',
                'Total Width' => '64 bits',
                'Part Number' => 'PartNum3',
                'Locator' => 'DIMM3',
                'Data Width' => '64 bits',
                'Type' => 'DDR2',
                'Error Information Handle' => 'Not Provided',
                'Array Handle' => '0x003B',
                'Asset Tag' => 'AssetTagNum3'
            }
        ],
        '2' => [
            {
                'Product Name' => 'M3A78-CM',
                'Serial Number' => 'MF7097G05100710',
                'Type' => 'Motherboard',
                'Asset Tag' => 'To Be Filled By O.E.M.',
                'Version' => 'Rev X.0x',
                'Location In Chassis' => 'To Be Filled By O.E.M.',
                'Manufacturer' => 'ASUSTeK Computer INC.',
                'Chassis Handle' => '0x0003',
                'Contained Object Handles' => '0'
            }
        ],
        '8' => [
            {
                'Internal Reference Designator' => 'PS/2 KeyBoard',
                'Internal Connector Type' => 'None',
                'External Reference Designator' => 'Keyboard',
                'External Connector Type' => 'PS/2',
                'Port Type' => 'Keyboard Port'
            },
            {
                'Internal Connector Type' => 'None',
                'Internal Reference Designator' => 'USB1',
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'External Reference Designator' => 'USB1'
            },
            {
                'Internal Reference Designator' => 'USB2',
                'Internal Connector Type' => 'None',
                'External Connector Type' => 'Access Bus (USB)',
                'External Reference Designator' => 'USB2',
                'Port Type' => 'USB'
            },
            {
                'Internal Connector Type' => 'None',
                'Internal Reference Designator' => 'USB3',
                'Port Type' => 'USB',
                'External Reference Designator' => 'USB3',
                'External Connector Type' => 'Access Bus (USB)'
            },
            {
                'Internal Connector Type' => 'None',
                'Internal Reference Designator' => 'USB4',
                'Port Type' => 'USB',
                'External Reference Designator' => 'USB4',
                'External Connector Type' => 'Access Bus (USB)'
            },
            {
                'Internal Connector Type' => 'None',
                'Internal Reference Designator' => 'USB5',
                'Port Type' => 'USB',
                'External Reference Designator' => 'USB5',
                'External Connector Type' => 'Access Bus (USB)'
            },
            {
                'Port Type' => 'USB',
                'External Connector Type' => 'Access Bus (USB)',
                'External Reference Designator' => 'USB6',
                'Internal Connector Type' => 'None',
                'Internal Reference Designator' => 'USB6'
            },
            {
                'External Reference Designator' => 'LPT 1',
                'External Connector Type' => 'DB-25 male',
                'Port Type' => 'Parallel Port ECP/EPP',
                'Internal Reference Designator' => 'LPT 1',
                'Internal Connector Type' => 'None'
            },
            {
                'Port Type' => 'Serial Port 16550A Compatible',
                'External Reference Designator' => 'COM 1',
                'External Connector Type' => 'DB-9 male',
                'Internal Connector Type' => 'None',
                'Internal Reference Designator' => 'COM 1'
            },
            {
                'Port Type' => 'Network Port',
                'External Reference Designator' => 'LAN',
                'External Connector Type' => 'RJ-45',
                'Internal Connector Type' => 'None',
                'Internal Reference Designator' => 'LAN'
            },
            {
                'Internal Reference Designator' => 'Audio_Line_In',
                'Internal Connector Type' => 'None',
                'External Connector Type' => 'Mini Jack (headphones)',
                'External Reference Designator' => 'Audio_Line_In',
                'Port Type' => 'Audio Port'
            },
            {
                'Internal Reference Designator' => 'Audio_Line_Out',
                'Internal Connector Type' => 'None',
                'External Connector Type' => 'Mini Jack (headphones)',
                'External Reference Designator' => 'Audio_Line_Out',
                'Port Type' => 'Audio Port'
            },
            {
                'Internal Connector Type' => 'None',
                'Internal Reference Designator' => 'Audio_Mic_In',
                'Port Type' => 'Audio Port',
                'External Connector Type' => 'Mini Jack (headphones)',
                'External Reference Designator' => 'Audio_Mic_In'
            },
            {
                'Internal Connector Type' => 'None',
                'Internal Reference Designator' => 'Audio_Center/Sub',
                'Port Type' => 'Audio Port',
                'External Connector Type' => 'Mini Jack (headphones)',
                'External Reference Designator' => 'Audio_Center/Sub'
            },
            {
                'Internal Connector Type' => 'None',
                'Internal Reference Designator' => 'Audio_Rear',
                'Port Type' => 'Audio Port',
                'External Reference Designator' => 'Audio_Rear',
                'External Connector Type' => 'Mini Jack (headphones)'
            },
            {
                'Internal Reference Designator' => 'Audio_Side',
                'Internal Connector Type' => 'None',
                'External Connector Type' => 'Mini Jack (headphones)',
                'External Reference Designator' => 'Audio_Side',
                'Port Type' => 'Audio Port'
            },
            {
                'Internal Connector Type' => 'None',
                'Internal Reference Designator' => 'Display_Port',
                'Port Type' => 'Other',
                'External Connector Type' => 'Other',
                'External Reference Designator' => 'Display_Port port'
            },
            {
                'Internal Reference Designator' => 'DVI',
                'Internal Connector Type' => 'None',
                'External Connector Type' => 'Other',
                'External Reference Designator' => 'DVI port',
                'Port Type' => 'Other'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'On Board IDE',
                'Internal Reference Designator' => 'PRI IDE'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'Other',
                'Internal Reference Designator' => 'SB_SATA1'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'Other',
                'Internal Reference Designator' => 'SB_SATA2'
            },
            {
                'External Connector Type' => 'None',
                'Port Type' => 'Other',
                'Internal Reference Designator' => 'SB_SATA3',
                'Internal Connector Type' => 'Other'
            },
            {
                'Internal Connector Type' => 'Other',
                'Internal Reference Designator' => 'SB_SATA4',
                'Port Type' => 'Other',
                'External Connector Type' => 'None'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'Other',
                'Internal Reference Designator' => 'SB_SATA5'
            },
            {
                'Internal Reference Designator' => 'SB_SATA6',
                'Internal Connector Type' => 'Other',
                'External Connector Type' => 'None',
                'Port Type' => 'Other'
            },
            {
                'Internal Reference Designator' => 'CPU FAN',
                'Internal Connector Type' => 'Other',
                'External Connector Type' => 'None',
                'Port Type' => 'Other'
            },
            {
                'Internal Connector Type' => 'Other',
                'Internal Reference Designator' => 'PWR FAN',
                'Port Type' => 'Other',
                'External Connector Type' => 'None'
            },
            {
                'Internal Connector Type' => 'Other',
                'Internal Reference Designator' => 'CHA FAN',
                'Port Type' => 'Other',
                'External Connector Type' => 'None'
            },
            {
                'External Connector Type' => 'None',
                'Port Type' => 'USB',
                'Internal Reference Designator' => 'USB7',
                'Internal Connector Type' => 'Access Bus (USB)'
            },
            {
                'Internal Connector Type' => 'Access Bus (USB)',
                'Internal Reference Designator' => 'USB8',
                'Port Type' => 'USB',
                'External Connector Type' => 'None'
            },
            {
                'Internal Connector Type' => 'Access Bus (USB)',
                'Internal Reference Designator' => 'USB9',
                'Port Type' => 'USB',
                'External Connector Type' => 'None'
            },
            {
                'Internal Reference Designator' => 'USB10',
                'Internal Connector Type' => 'Access Bus (USB)',
                'External Connector Type' => 'None',
                'Port Type' => 'USB'
            },
            {
                'External Connector Type' => 'None',
                'Port Type' => 'USB',
                'Internal Reference Designator' => 'USB11',
                'Internal Connector Type' => 'Access Bus (USB)'
            },
            {
                'External Connector Type' => 'None',
                'Port Type' => 'USB',
                'Internal Reference Designator' => 'USB12',
                'Internal Connector Type' => 'Access Bus (USB)'
            },
            {
                'Internal Reference Designator' => 'PANEL',
                'Internal Connector Type' => '9 Pin Dual Inline (pin 10 cut)',
                'External Connector Type' => 'None',
                'Port Type' => 'Other'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'Other',
                'Internal Reference Designator' => 'SPDIF OUT'
            },
            {
                'Internal Connector Type' => 'Other',
                'Internal Reference Designator' => 'AAFP',
                'Port Type' => 'Other',
                'External Connector Type' => 'None'
            },
            {
                'Internal Reference Designator' => 'CD',
                'Internal Connector Type' => 'On Board Sound Input From CD-ROM',
                'External Connector Type' => 'None',
                'Port Type' => 'Audio Port'
            },
            {
                'Port Type' => 'Other',
                'External Connector Type' => 'None',
                'Internal Connector Type' => 'Other',
                'Internal Reference Designator' => 'TPM'
            },
            {
                'Internal Connector Type' => 'Other',
                'Internal Reference Designator' => 'Speaker',
                'Port Type' => 'Other',
                'External Connector Type' => 'None'
            }
        ],
        '0' => [
            {
                'BIOS Revision' => '8.14',
                'Runtime Size' => '64 kB',
                'Version' => '2003',
                'Release Date' => '06/26/2009',
                'ROM Size' => '1024 kB',
                'Address' => '0xF0000',
                'Vendor' => 'American Megatrends Inc.'
            }
        ],
        '10' => [
            {
                'Type' => 'Other',
                'Description' => 'To Be Filled By O.E.M.',
                'Status' => 'Enabled'
            },
            {
                'Status' => 'Enabled',
                'Type' => 'Ethernet',
                'Description' => 'To Be Filled By O.E.M.'
            },
            {
                'Status' => 'Enabled',
                'Type' => 'Sound',
                'Description' => 'To Be Filled By O.E.M.'
            },
            {
                'Type' => 'Other',
                'Description' => 'To Be Filled By O.E.M.',
                'Status' => 'Enabled'
            }
        ],
        '15' => [
            {
                'Header Start Offset' => '0x0000',
                'Data Format 4' => 'OEM-specific',
                'Data Format 6' => 'OEM-specific',
                'Access Address' => 'Index 0x046A, Data 0x046C',
                'Descriptor 6' => 'End of log',
                'Change Token' => '0x00000000',
                'Descriptor 5' => 'End of log',
                'Descriptor 1' => 'End of log',
                'Descriptor 2' => 'End of log',
                'Data Format 3' => 'OEM-specific',
                'Supported Log Type Descriptors' => '6',
                'Header Format' => 'No Header',
                'Descriptor 3' => 'End of log',
                'Data Format 1' => 'OEM-specific',
                'Status' => 'Invalid, Not Full',
                'Descriptor 4' => 'End of log',
                'Data Format 2' => 'OEM-specific',
                'Area Length' => '4 bytes',
                'Data Format 5' => 'OEM-specific',
                'Data Start Offset' => '0x0002',
                'Header Length' => '2 bytes',
                'Access Method' => 'Indexed I/O, one 16-bit index port, one 8-bit data port'
            }
        ],
        '13' => [
            {
                'Currently Installed Language' => 'en|US|iso8859-1',
                'Language Description Format' => 'Abbreviated',
                'Installable Languages' => '1'
            }
        ],
        '11' => [
            {
                'String 3' => 'To Be Filled By O.E.M.',
                'String 1' => 'To Be Filled By O.E.M.',
                'String 4' => 'To Be Filled By O.E.M.',
                'String 2' => 'To Be Filled By O.E.M.'
            }
        ],
        '3' => [
            {
                'Type' => 'Desktop',
                'Serial Number' => 'Chassis Serial Number',
                'Thermal State' => 'Safe',
                'Asset Tag' => 'Asset-1234567890',
                'Number Of Power Cords' => '1',
                'Security Status' => 'None',
                'Version' => 'Chassis Version',
                'OEM Information' => '0x00000001',
                'Contained Elements' => '0',
                'Power Supply State' => 'Safe',
                'Manufacturer' => 'Chassis Manufacture',
                'Boot-up State' => 'Safe',
                'Height' => 'Unspecified'
            }
        ]
    }
);

my %cpu_tests = (
    'freebsd-6.2' => [
        {
            ID             => 'A9 06 00 00 FF BB C9 A7',
            NAME           => 'VIA C7',
            EXTERNAL_CLOCK => '100',
            SPEED          => '2000',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'VIA',
            STEPPING       => '9',
            FAMILYNUMBER   => '6',
            MODEL          => '10',
            FAMILYNAME     => 'Other',
            CORE           => undef
        }
    ],
    'freebsd-8.1' => [
        {
            ID             => '52 06 02 00 FF FB EB BF',
            NAME           => 'Core 2 Duo',
            EXTERNAL_CLOCK => '1066',
            SPEED          => '2270',
            THREAD         => '4',
            SERIAL         => undef,
            MANUFACTURER   => 'Intel(R) Corporation',
            STEPPING       => '2',
            FAMILYNUMBER   => '6',
            MODEL          => '37',
            FAMILYNAME     => 'Core 2 Duo',
            CORE           => '2'
        }
    ],
    'hp-dl180' => [
        {
            ID             => 'A5 06 01 00 FF FB EB BF',
            NAME           => 'Xeon',
            EXTERNAL_CLOCK => '532',
            SPEED          => '2000',
            THREAD         => '4',
            SERIAL         => undef,
            MANUFACTURER   => 'Intel',
            STEPPING       => '5',
            FAMILYNUMBER   => '6',
            MODEL          => '26',
            CORE           => '4',
            FAMILYNAME     => 'Xeon'
        }
    ],
    'rhel-2.1' => [
        {
            ID             => undef,
            NAME           => 'Pentium 4',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'Intel',
            FAMILYNAME     => undef,
            CORE           => undef
        }
    ],
    'rhel-3.4' => [
        {
            ID             => '41 0F 00 00 FF FB EB BF',
            NAME           => 'Xeon MP',
            EXTERNAL_CLOCK => '200',
            SPEED          => '2800',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'Intel Corporation',
            STEPPING       => '1',
            FAMILYNUMBER   => '15',
            MODEL          => '4',,
            FAMILYNAME     => 'Xeon MP',
            CORE           => undef
        },
        {
            ID             => '41 0F 00 00 FF FB EB BF',
            NAME           => 'Xeon MP',
            EXTERNAL_CLOCK => '200',
            SPEED          => '2800',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'Intel Corporation',
            STEPPING       => '1',
            FAMILYNUMBER   => '15',
            MODEL          => '4',
            FAMILYNAME     => 'Xeon MP',
            CORE           => undef
        }
    ],
    'rhel-3.9' => [
    ],
    'rhel-4.3' => [
        {
            ID             => '29 0F 00 00 FF FB EB BF',
            NAME           => 'Xeon',
            EXTERNAL_CLOCK => '133',
            SPEED          => '2666',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'Intel',
            STEPPING       => '9',
            FAMILYNUMBER   => '15',
            MODEL          => '2',
            FAMILYNAME     => 'Xeon',
            CORE           => undef
        },
        {
            ID             => '29 0F 00 00 FF FB EB BF',
            NAME           => 'Xeon',
            EXTERNAL_CLOCK => '133',
            SPEED          => '2666',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'Intel',
            STEPPING       => '9',
            FAMILYNUMBER   => '15',
            MODEL          => '2',
            FAMILYNAME     => 'Xeon',
            CORE           => undef
        }
    ],
    'rhel-4.6' => [
        {
            ID             => '76 06 01 00 FF FB EB BF',
            NAME           => 'Xeon',
            EXTERNAL_CLOCK => '1333',
            SPEED          => '2333',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'Intel',
            STEPPING       => '6',
            FAMILYNUMBER   => '6',
            MODEL          => '23',
            FAMILYNAME     => 'Xeon',
            CORE           => undef
        }
    ],
    'rhel-5.6' => [
        {
            ID             => 'C2 06 02 00 FF FB EB BF',
            NAME           => 'Xeon',
            EXTERNAL_CLOCK => '5860',
            SPEED          => '2400',
            THREAD         => '8',
            SERIAL         => undef,
            MANUFACTURER   => 'Intel',
            STEPPING       => '2',
            FAMILYNUMBER   => '6',
            MODEL          => '44',
            FAMILYNAME     => 'Xeon',
            CORE           => '4',
        },
        {
            ID             => 'C2 06 02 00 FF FB EB BF',
            NAME           => 'Xeon',
            EXTERNAL_CLOCK => '5860',
            SPEED          => '2400',
            THREAD         => '8',
            SERIAL         => undef,
            MANUFACTURER   => 'Intel',
            STEPPING       => '2',
            FAMILYNUMBER   => '6',
            MODEL          => '44',
            FAMILYNAME     => 'Xeon',
            CORE           => '4',
        }
    ],
    'rhel-6.3-esx-1vcpu' => [
        {
            ID             => 'A7 06 02 00 FF FB AB 0F',
            NAME           => 'Intel(R) Core(TM) i5-2500S CPU @ 2.70GHz',
            SPEED          => '2700',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'GenuineIntel',
            STEPPING       => '7',
            FAMILYNUMBER   => '6',
            MODEL          => '42',
            FAMILYNAME     => undef,
            CORE           => undef,
        }
    ],
    'openbsd-3.7' => [
        {
            ID             => '52 06 00 00 FF F9 83 01',
            NAME           => 'Pentium II',
            EXTERNAL_CLOCK => '100',
            SPEED          => '400',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'Intel',
            STEPPING       => '2',
            FAMILYNUMBER   => '6',
            MODEL          => '5',
            FAMILYNAME     => 'Pentium II',
            CORE           => undef
        }
    ],
    'openbsd-3.8' => [
        {
            ID             => '43 0F 00 00 FF FB EB BF',
            NAME           => 'Xeon',
            EXTERNAL_CLOCK => '800',
            SPEED          => '3000',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'Intel',
            STEPPING       => '3',
            FAMILYNUMBER   => '15',
            MODEL          => '4',
            FAMILYNAME     => 'Xeon',
            CORE           => undef
        }
    ],
    'openbsd-4.5' => [
        {
            ID             => '29 0F 00 00 FF FB EB BF',
            NAME           => 'Pentium 4',
            EXTERNAL_CLOCK => '533',
            SPEED          => '2400',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'Intel',
            STEPPING       => '9',
            FAMILYNUMBER   => '15',
            MODEL          => '2',,
            FAMILYNAME     => 'Pentium 4',
            CORE           => undef
        }
    ],
    'S3000AHLX' => [
        {
            ID             => 'F6 06 00 00 FF FB EB BF',
            NAME           => 'Intel(R) Core(TM)2 CPU 6600 @ 2.40GHz',
            EXTERNAL_CLOCK => '266',
            SPEED          => '2400',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'Intel(R) Corporation',
            STEPPING       => '6',
            FAMILYNUMBER   => '6',
            MODEL          => '15',
            FAMILYNAME     => undef,
            CORE           => undef
        }
    ],
    'S5000VSA' => [
        {
            ID             => 'F6 06 00 00 FF FB EB BF',
            NAME           => 'Xeon',
            EXTERNAL_CLOCK => '1066',
            SPEED          => '1860',
            THREAD         => '2',
            SERIAL         => undef,
            MANUFACTURER   => 'Intel(R) Corporation',
            STEPPING       => '6',
            FAMILYNUMBER   => '6',
            MODEL          => '15',
            FAMILYNAME     => 'Xeon',
            CORE           => '2'
        },
        {
            ID             => 'F6 06 00 00 FF FB EB BF',
            NAME           => 'Xeon',
            EXTERNAL_CLOCK => '1066',
            SPEED          => '1860',
            THREAD         => '2',
            SERIAL         => undef,
            MANUFACTURER   => 'Intel(R) Corporation',
            STEPPING       => '6',
            FAMILYNUMBER   => '6',
            MODEL          => '15',
            FAMILYNAME     => 'Xeon',
            CORE           => '2'
        }
    ],
    'linux-1' => [
        {
            ID             => '7A 06 01 00 FF FB EB BF',
            NAME           => 'Core 2 Duo',
            EXTERNAL_CLOCK => '333',
            SPEED          => '3000',
            THREAD         => '2',
            SERIAL         => 'To Be Filled By O.E.M.',
            MANUFACTURER   => 'Intel',
            STEPPING       => '10',
            FAMILYNUMBER   => '6',
            MODEL          => '23',
            FAMILYNAME     => 'Core 2 Duo',
            CORE           => '2'
        }
    ],
    'linux-2.6' => [
        {
            ID             => 'D8 06 00 00 FF FB E9 AF',
            NAME           => 'Pentium M',
            EXTERNAL_CLOCK => '133',
            SPEED          => '1733',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'Intel',
            STEPPING       => '8',
            FAMILYNUMBER   => '6',
            MODEL          => '13',
            FAMILYNAME     => 'Pentium M',
            CORE           => undef
        }
    ],
    'vmware' => [
        {
            ID             => '12 0F 04 00 FF FB 8B 07',
            NAME           => undef,
            SPEED          => '2133',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'AuthenticAMD',
            STEPPING       => '2',
            FAMILYNUMBER   => '15',
            MODEL          => '65',
            FAMILYNAME     => undef,
            CORE           => undef
        },
        {
            ID             => '12 0F 00 00 FF FB 8B 07',
            NAME           => undef,
            FAMILYNAME     => undef,
            SPEED          => '2133',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'GenuineIntel',
            STEPPING       => '2',
            FAMILYNUMBER   => '15',
            MODEL          => '1',
            FAMILYNAME     => undef,
            CORE           => undef
        }
    ],
    'vmware-esx' => [
        {
            ID             => '42 0F 10 00 FF FB 8B 07',
            NAME           => undef,
            SPEED          => '2300',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'AuthenticAMD',
            STEPPING       => '2',
            FAMILYNUMBER   => '15',
            MODEL          => '4',
            FAMILYNAME     => undef,
            CORE           => undef
        }
    ],
    'vmware-esx-2.5' => [
        {
            ID             => undef,
            NAME           => 'Pentium III processor',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'GenuineIntel',
            FAMILYNAME     => undef,
            CORE           => undef
        }
    ],
    'windows' => [
        {
            ID             => '24 0F 00 00 00 00 00 00',
            NAME           => 'Pentium 4',
            EXTERNAL_CLOCK => '100',
            SPEED          => '1700',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'Intel Corporation',
            STEPPING       => '4',
            FAMILYNUMBER   => '15',
            MODEL          => '2',
            FAMILYNAME     => 'Pentium 4',
            CORE           => undef
        }
    ],
    'windows-hyperV' => [
        {
            ID             => '7A 06 01 00 FF FB 8B 1F',
            NAME           => 'Xeon',
            EXTERNAL_CLOCK => '266',
            SPEED          => '2500',
            THREAD         => undef,
            SERIAL         => 'None',
            MANUFACTURER   => 'GenuineIntel',
            STEPPING       => '10',
            FAMILYNUMBER   => '6',
            MODEL          => '23',
            FAMILYNAME     => 'Xeon',
            CORE           => undef
        }
    ],
    'windows-xp' => [
        {
            ID             => '76 06 01 00 FF FB EB BF',
            NAME           => 'Core 2 Duo',
            EXTERNAL_CLOCK => '266',
            SPEED          => '2534',
            THREAD         => '2',
            SERIAL         => undef,
            MANUFACTURER   => 'Intel',
            STEPPING       => '6',
            FAMILYNUMBER   => '6',
            MODEL          => '23',
            FAMILYNAME     => 'Core 2 Duo',
            CORE           => '2'
        }
    ],
    'windows-7' => [
        {
            ID             => 'A7 06 02 00 FF FB EB BF',
            NAME           => 'Core 2 Duo',
            EXTERNAL_CLOCK => '100',
            SPEED          => '2800',
            THREAD         => undef,
            SERIAL         => 'To Be Filled By O.E.M.',
            STEPPING       => '7',
            FAMILYNUMBER   => '6',
            MODEL          => '42',
            MANUFACTURER   => 'Intel',
            FAMILYNAME     => 'Core 2 Duo',
            CORE           => '4'
        }
    ],
    'windows-7.2' => [
        {
            ID             => '62 0F 10 00 FF FB 8B 17',
            NAME           => 'AMD Athlon(tm) II X2 245 Processor',
            EXTERNAL_CLOCK => '200',
            SPEED          => '2900',
            THREAD         => undef,
            SERIAL         => 'To Be Filled By O.E.M.',
            STEPPING       => '2',
            FAMILYNUMBER   => '15',
            MODEL          => '6',
            MANUFACTURER   => 'AMD',
            FAMILYNAME     => 'Athlon II',
            CORE           => '2'
        }
    ]
);

my %lspci_tests = (
    'dell-xt2' => [
        {
            PCICLASS     => '0600',
            NAME         => 'Host bridge',
            MANUFACTURER => 'Intel Corporation Mobile 4 Series Chipset Memory Controller Hub',
            REV          => '07',
            PCIID        => '8086:2a40',
            DRIVER       => 'agpgart',
            PCISLOT      => '00:00.0'
        },
        {
            PCICLASS     => '0300',
            NAME         => 'VGA compatible controller',
            MANUFACTURER => 'Intel Corporation Mobile 4 Series Chipset Integrated Graphics Controller',
            REV          => '07',
            PCIID        => '8086:2a42',
            DRIVER       => 'i915',
            PCISLOT      => '00:02.0'
        },
        {
            PCICLASS     => '0380',
            NAME         => 'Display controller',
            MANUFACTURER => 'Intel Corporation Mobile 4 Series Chipset Integrated Graphics Controller',
            REV          => '07',
            PCIID        => '8086:2a43',
            PCISLOT      => '00:02.1'
        },
        {
            PCICLASS     => '0200',
            NAME         => 'Ethernet controller',
            MANUFACTURER => 'Intel Corporation 82567LM Gigabit Network Connection',
            REV          => '03',
            PCIID        => '8086:10f5',
            DRIVER       => 'e1000e',
            PCISLOT      => '00:19.0'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #4',
            REV          => '03',
            PCIID        => '8086:2937',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1a.0'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #5',
            REV          => '03',
            PCIID        => '8086:2938',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1a.1'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #6',
            REV          => '03',
            PCIID        => '8086:2939',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1a.2'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #2',
            REV          => '03',
            PCIID        => '8086:293c',
            DRIVER       => 'ehci_hcd',
            PCISLOT      => '00:1a.7'
        },
        {
            PCICLASS     => '0403',
            NAME         => 'Audio device',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) HD Audio Controller',
            REV          => '03',
            PCIID        => '8086:293e',
            DRIVER       => 'snd_hda_intel',
            PCISLOT      => '00:1b.0'
        },
        {
            PCICLASS     => '0604',
            NAME         => 'PCI bridge',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) PCI Express Port 1',
            REV          => '03',
            PCIID        => '8086:2940',
            DRIVER       => 'pcieport',
            PCISLOT      => '00:1c.0'
        },
        {
            PCICLASS     => '0604',
            NAME         => 'PCI bridge',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) PCI Express Port 2',
            REV          => '03',
            PCIID        => '8086:2942',
            DRIVER       => 'pcieport',
            PCISLOT      => '00:1c.1'
        },
        {
            PCICLASS     => '0604',
            NAME         => 'PCI bridge',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) PCI Express Port 4',
            REV          => '03',
            PCIID        => '8086:2946',
            DRIVER       => 'pcieport',
            PCISLOT      => '00:1c.3'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #1',
            REV          => '03',
            PCIID        => '8086:2934',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1d.0'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #2',
            REV          => '03',
            PCIID        => '8086:2935',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1d.1'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #3',
            REV          => '03',
            PCIID        => '8086:2936',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1d.2'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #1',
            REV          => '03',
            PCIID        => '8086:293a',
            DRIVER       => 'ehci_hcd',
            PCISLOT      => '00:1d.7'
        },
        {
            PCICLASS     => '0604',
            NAME         => 'PCI bridge',
            MANUFACTURER => 'Intel Corporation 82801 Mobile PCI Bridge',
            REV          => '93',
            PCIID        => '8086:2448',
            PCISLOT      => '00:1e.0'
        },
        {
            PCICLASS     => '0601',
            NAME         => 'ISA bridge',
            MANUFACTURER => 'Intel Corporation ICH9M-E LPC Interface Controller',
            REV          => '03',
            PCIID        => '8086:2917',
            PCISLOT      => '00:1f.0'
        },
        {
            PCIID        => '8086:282a',
            PCICLASS     => '0104',
            REV          => '03',
            MANUFACTURER => 'Intel Corporation 82801 Mobile SATA Controller [RAID mode]',
            DRIVER       => 'ahci',
            NAME         => 'RAID bus controller',
            PCISLOT      => '00:1f.2'
        },
        {
            PCICLASS     => '0c05',
            NAME         => 'SMBus',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) SMBus Controller',
            REV          => '03',
            PCIID        => '8086:2930',
            DRIVER       => 'i801_smbus',
            PCISLOT      => '00:1f.3'
        },
        {
            PCICLASS     => '0607',
            NAME         => 'CardBus bridge',
            MANUFACTURER => 'Texas Instruments PCIxx12 Cardbus Controller',
            REV          => undef,
            PCIID        => '104c:8039',
            DRIVER       => 'yenta_cardbus',
            PCISLOT      => '02:01.0'
        },
        {
            PCICLASS     => '0c00',
            NAME         => 'FireWire (IEEE 1394)',
            MANUFACTURER => 'Texas Instruments PCIxx12 OHCI Compliant IEEE 1394 Host Controller',
            REV          => undef,
            PCIID        => '104c:803a',
            DRIVER       => 'firewire_ohci',
            PCISLOT      => '02:01.1'
        },
        {
            PCICLASS     => '0805',
            NAME         => 'SD Host controller',
            MANUFACTURER => 'Texas Instruments PCIxx12 SDA Standard Compliant SD Host Controller',
            REV         => undef,
            PCIID       => '104c:803c',
            DRIVER      => 'sdhci',
            PCISLOT     => '02:01.3'
        },
        {
            PCICLASS     => '0280',
            NAME         => 'Network controller',
            MANUFACTURER => 'Intel Corporation WiFi Link 5100',
            REV          => undef,
            PCIID        => '8086:4232',
            DRIVER       => 'iwlwifi',
            PCISLOT      => '0c:00.0'
        }
    ],
    'linux-2' => [
        {
            REV          => undef,
            NAME         => 'Host bridge',
            DRIVER       => 'i82975x_edac',
            PCICLASS     => '0600',
            PCISLOT      => '00:00.0',
            MANUFACTURER => 'Intel Corporation 82975X Memory Controller Hub',
            PCIID        => '8086:277c'
        },
        {
            REV          => undef,
            NAME         => 'PCI bridge',
            DRIVER       => 'pcieport',
            PCICLASS     => '0604',
            PCISLOT      => '00:01.0',
            MANUFACTURER => 'Intel Corporation 82975X PCI Express Root Port',
            PCIID        => '8086:277d'
        },
        {
            NAME         => 'Audio device',
            REV          => '01',
            PCICLASS     => '0403',
            DRIVER       => 'snd_hda_intel',
            MANUFACTURER => 'Intel Corporation NM10/ICH7 Family High Definition Audio Controller',
            PCISLOT      => '00:1b.0',
            PCIID        => '8086:27d8'
        },
        {
            REV          => '01',
            NAME         => 'PCI bridge',
            DRIVER       => 'pcieport',
            PCICLASS     => '0604',
            PCISLOT      => '00:1c.0',
            MANUFACTURER => 'Intel Corporation NM10/ICH7 Family PCI Express Port 1',
            PCIID        => '8086:27d0'
        },
        {
            NAME         => 'PCI bridge',
            REV          => '01',
            PCICLASS     => '0604',
            DRIVER       => 'pcieport',
            MANUFACTURER => 'Intel Corporation 82801GR/GH/GHM (ICH7 Family) PCI Express Port 5',
            PCISLOT      => '00:1c.4',
            PCIID        => '8086:27e0'
        },
        {
            MANUFACTURER => 'Intel Corporation 82801GR/GH/GHM (ICH7 Family) PCI Express Port 6',
            PCISLOT      => '00:1c.5',
            PCIID        => '8086:27e2',
            NAME         => 'PCI bridge',
            REV          => '01',
            PCICLASS     => '0604',
            DRIVER       => 'pcieport'
        },
        {
            DRIVER       => 'uhci_hcd',
            PCICLASS     => '0c03',
            REV          => '01',
            NAME         => 'USB controller',
            PCIID        => '8086:27c8',
            PCISLOT      => '00:1d.0',
            MANUFACTURER => 'Intel Corporation NM10/ICH7 Family USB UHCI Controller #1'
        },
        {
            NAME         => 'USB controller',
            REV          => '01',
            PCICLASS     => '0c03',
            DRIVER       => 'uhci_hcd',
            MANUFACTURER => 'Intel Corporation NM10/ICH7 Family USB UHCI Controller #2',
            PCISLOT      => '00:1d.1',
            PCIID        => '8086:27c9'
        },
        {
            DRIVER       => 'uhci_hcd',
            PCICLASS     => '0c03',
            REV          => '01',
            NAME         => 'USB controller',
            PCIID        => '8086:27ca',
            PCISLOT      => '00:1d.2',
            MANUFACTURER => 'Intel Corporation NM10/ICH7 Family USB UHCI Controller #3'
        },
        {
            PCIID        => '8086:27cb',
            PCISLOT      => '00:1d.3',
            MANUFACTURER => 'Intel Corporation NM10/ICH7 Family USB UHCI Controller #4',
            DRIVER       => 'uhci_hcd',
            PCICLASS     => '0c03',
            REV          => '01',
            NAME         => 'USB controller'
        },
        {
            PCICLASS     => '0c03',
            DRIVER       => 'ehci',
            NAME         => 'USB controller',
            REV          => '01',
            PCIID        => '8086:27cc',
            MANUFACTURER => 'Intel Corporation NM10/ICH7 Family USB2 EHCI Controller',
            PCISLOT      => '00:1d.7'
        },
        {
            PCISLOT      => '00:1e.0',
            MANUFACTURER => 'Intel Corporation 82801 PCI Bridge',
            PCIID        => '8086:244e',
            REV          => undef,
            NAME         => 'PCI bridge',
            PCICLASS     => '0604'
        },
        {
            REV          => '01',
            NAME         => 'ISA bridge',
            DRIVER       => 'lpc_ich',
            PCICLASS     => '0601',
            PCISLOT      => '00:1f.0',
            MANUFACTURER => 'Intel Corporation 82801GB/GR (ICH7 Family) LPC Interface Bridge',
            PCIID        => '8086:27b8'
        },
        {
            MANUFACTURER => 'Intel Corporation 82801G (ICH7 Family) IDE Controller',
            PCISLOT      => '00:1f.1',
            PCIID        => '8086:27df',
            NAME         => 'IDE interface',
            REV          => '01',
            PCICLASS     => '0101',
            DRIVER       => 'ata_piix'
        },
        {
            MANUFACTURER => 'Intel Corporation NM10/ICH7 Family SATA Controller [AHCI mode]',
            DRIVER       => 'ahci',
            REV          => '01',
            PCISLOT      => '00:1f.2',
            PCICLASS     => '0106',
            PCIID        => '8086:27c1',
            NAME         => 'SATA controller'
        },
        {
            PCICLASS     => '0c05',
            DRIVER       => 'i801_smbus',
            NAME         => 'SMBus',
            REV          => '01',
            PCIID        => '8086:27da',
            MANUFACTURER => 'Intel Corporation NM10/ICH7 Family SMBus Controller',
            PCISLOT      => '00:1f.3'
        },
        {
            DRIVER       => 'nvidia',
            PCISLOT      => '01:00.0',
            PCICLASS     => '0300',
            REV          => undef,
            PCIID        => '10de:014d',
            NAME         => 'VGA compatible controller',
            MANUFACTURER => 'NVIDIA Corporation NV43GL [Quadro FX 550]'
        },
        {
            NAME         => 'Ethernet controller',
            REV          => '02',
            PCICLASS     => '0200',
            DRIVER       => 'tg3',
            MANUFACTURER => 'Broadcom Corporation NetXtreme BCM5754 Gigabit Ethernet PCI Express',
            PCISLOT      => '04:00.0',
            PCIID        => '14e4:167a'
        },
        {
            PCISLOT      => '05:02.0',
            DRIVER       => 'firewire_ohci',
            REV          => '61',
            PCIID        => '11c1:5811',
            MANUFACTURER => 'LSI Corporation FW322/323 [TrueFire] 1394a Controller',
            NAME         => 'FireWire (IEEE 1394)',
            PCICLASS     => '0c00'
        }
    ],
);

my %hdparm_tests = (
    linux1 => {
        firmware  => 'CXM13D1Q',
        model     => 'SAMSUNG SSD PM830 mSATA 256GB',
        serial    => 'S0XPNYAD412339',
        size      => '256060',
        transport => 'SATA',
        wwn       => '5002538043584d30'
    }
);

my %edid_vendor_tests = (
    NVD => 'Nvidia',
    XQU => 'SHANGHAI SVA-DAV ELECTRONICS CO., LTD',
);

plan tests =>
    (scalar keys %dmidecode_tests) +
    (scalar keys %cpu_tests)       +
    (scalar keys %lspci_tests)     +
    (scalar keys %hdparm_tests)    +
    (scalar keys %edid_vendor_tests);

foreach my $test (keys %dmidecode_tests) {
    my $file = "resources/generic/dmidecode/$test";
    my $infos = getDmidecodeInfos(file => $file);
    cmp_deeply($infos, $dmidecode_tests{$test}, "$test dmidecode parsing");
}

foreach my $test (keys %cpu_tests) {
    my $file = "resources/generic/dmidecode/$test";
    my @cpus = getCpusFromDmidecode(file => $file);
    cmp_deeply(\@cpus, $cpu_tests{$test}, "$test dmidecode cpu extraction");
}

foreach my $test (keys %lspci_tests) {
    my $file = "resources/generic/lspci/$test";
    my @devices = getPCIDevices(file => $file);
    cmp_deeply(\@devices, $lspci_tests{$test}, "$test lspci parsing");
}

foreach my $test (keys %hdparm_tests) {
    my $file = "resources/generic/hdparm/$test";
    my $info = getHdparmInfo(file => $file);
    cmp_deeply($info, $hdparm_tests{$test}, "$test hdparm parsing");
}

foreach my $test (keys %edid_vendor_tests) {
    is(
        getEDIDVendor(id => $test, datadir => './share'),
        $edid_vendor_tests{$test},
        "edid vendor identification: $test"
    );
}
