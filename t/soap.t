#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;
use Test::Exception;
use FusionInventory::VMware::SOAP;
use File::Basename;

use Data::Dumper;

my %test = (
    'esx-4.1.0-1' => {
        'login()' => {
          'lastActiveTime' => '1970-01-25T03:53:04.326969+01:00',
          'loginTime' => '1970-01-25T03:53:04.326969+01:00',
          'fullName' => 'root',
          'messageLocale' => 'en',
          'locale' => 'en',
          'userName' => 'root',
          'key' => '52eec005-5d13-dfae-afd8-7e1b4561a154'
        },
        'getHostname()' => 'esx-test.teclib.local',
        'getBiosInfo()' => {
          'SMANUFACTURER' => 'Sun Microsystems',
          'SMODEL' => 'Sun Fire X2200 M2 with Dual Core Processor',
          'BDATE' => '2009-02-04T00:00:00Z',
          'ASSETTAG' => ' To Be Filled By O.E.M.',
          'BVERSION' => 'S39_3B27'
        },
        'getHardwareInfo()' => {
          'OSCOMMENTS' => 'VMware ESX 4.1.0 build-260247',
          'NAME' => 'esx-test',
          'OSVERSION' => '4.1.0',
          'WORKGROUP' => 'teclib.local',
          'MEMORY' => 8190,
          'OSNAME' => 'VMware ESX',
          'UUID' => 'b5bfd78a-fa79-0010-adfe-001b24f07258',
          'DNS' => '10.0.5.105'
        },
        'getCPUs()' => [
          {
            'NAME' => 'Dual-Core AMD Opteron(tm) Processor 2218',
            'MANUFACTURER' => 'AMD',
            'SPEED' => 2613,
            'THREAD' => '1',
            'CORE' => 4
          },
          {
            'NAME' => 'Dual-Core AMD Opteron(tm) Processor 2218',
            'MANUFACTURER' => 'AMD',
            'SPEED' => 2613,
            'THREAD' => '1',
            'CORE' => 4
          }
        ],
        'getControllers()' => [
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '500',
            'NAME' => 'MCP55 Memory Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:369',
            'PCISLOT' => '00:00.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '601',
            'NAME' => 'MCP55 LPC Bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:364',
            'PCISLOT' => '00:01.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => 'c05',
            'NAME' => 'MCP55 SMBus',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:368',
            'PCISLOT' => '00:01.1'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => 'c03',
            'NAME' => 'MCP55 USB Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:36c',
            'PCISLOT' => '00:02.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => 'c03',
            'NAME' => 'MCP55 USB Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:36d',
            'PCISLOT' => '00:02.1'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '101',
            'NAME' => 'NVidia NForce MCP55 IDE/PATA Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:36e',
            'PCISLOT' => '00:04.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '101',
            'NAME' => 'MCP55 SATA Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:37f',
            'PCISLOT' => '00:05.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => 'MCP55 PCI bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:370',
            'PCISLOT' => '00:06.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '680',
            'NAME' => 'nVidia NForce Network Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:373',
            'PCISLOT' => '00:08.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '680',
            'NAME' => 'nVidia NForce Network Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:373',
            'PCISLOT' => '00:09.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => 'MCP55 PCI Express bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:376',
            'PCISLOT' => '00:0a.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => 'MCP55 PCI Express bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:374',
            'PCISLOT' => '00:0b.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => 'MCP55 PCI Express bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:374',
            'PCISLOT' => '00:0c.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => 'MCP55 PCI Express bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:378',
            'PCISLOT' => '00:0d.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => 'MCP55 PCI Express bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:377',
            'PCISLOT' => '00:0f.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] HyperTransport Technology Configuration',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1100',
            'PCISLOT' => '00:18.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] Address Map',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1101',
            'PCISLOT' => '00:18.1'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] DRAM Controller',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1102',
            'PCISLOT' => '00:18.2'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] Miscellaneous Control',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1103',
            'PCISLOT' => '00:18.3'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] HyperTransport Technology Configuration',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1100',
            'PCISLOT' => '00:19.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] Address Map',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1101',
            'PCISLOT' => '00:19.1'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] DRAM Controller',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1102',
            'PCISLOT' => '00:19.2'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] Miscellaneous Control',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1103',
            'PCISLOT' => '00:19.3'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '300',
            'NAME' => 'ASPEED Graphics Family',
            'MANUFACTURER' => 'ASPEED Technology, Inc.',
            'PCIID' => '1a03:2000',
            'PCISLOT' => '01:05.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => 'EPB PCI-Express to PCI-X Bridge',
            'MANUFACTURER' => 'Broadcom',
            'PCIID' => '1166:103',
            'PCISLOT' => '05:00.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '200',
            'NAME' => 'Broadcom BCM5715 Gigabit Ethernet',
            'MANUFACTURER' => 'Broadcom Corporation',
            'PCIID' => '14e4:1678',
            'PCISLOT' => '06:04.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '200',
            'NAME' => 'Broadcom BCM5715 Gigabit Ethernet',
            'MANUFACTURER' => 'Broadcom Corporation',
            'PCIID' => '14e4:1678',
            'PCISLOT' => '06:04.1'
          }
        ],
        'getNetworks()' => [
          {
            'IPMASK' => undef,
            'STATUS' => 'Down',
            'MACADDR' => '00:1b:24:f0:6a:45',
            'DESCRIPTION' => 'vmnic0',
            'SPEED' => '0',
            'PCISLOT' => '00:08.0',
            'IPADDRESS' => undef,
            'DRIVER' => 'forcedeth'
          },
          {
            'IPMASK' => undef,
            'STATUS' => 'Down',
            'MACADDR' => '00:1b:24:f0:6a:46',
            'DESCRIPTION' => 'vmnic1',
            'SPEED' => '0',
            'PCISLOT' => '00:09.0',
            'IPADDRESS' => undef,
            'DRIVER' => 'forcedeth'
          },
          {
            'IPMASK' => undef,
            'STATUS' => 'Down',
            'MACADDR' => '00:1b:24:f0:6a:43',
            'DESCRIPTION' => 'vmnic2',
            'SPEED' => '100',
            'PCISLOT' => '06:04.0',
            'IPADDRESS' => undef,
            'DRIVER' => 'tg3'
          },
          {
            'IPMASK' => undef,
            'STATUS' => 'Down',
            'MACADDR' => '00:1b:24:f0:6a:44',
            'DESCRIPTION' => 'vmnic3',
            'SPEED' => '0',
            'PCISLOT' => '06:04.1',
            'IPADDRESS' => undef,
            'DRIVER' => 'tg3'
          },
          {
            'IPMASK' => undef,
            'VIRTUALDEV' => '1',
            'STATUS' => 'Down',
            'MACADDR' => undef,
            'SPEED' => undef,
            'PCISLOT' => undef,
            'DRIVER' => undef,
            'DESCRIPTION' => 'vmk0',
            'IPADDRESS' => undef
          },
          {
            'MTU' => undef,
            'IPMASK' => '255.255.0.0',
            'VIRTUALDEV' => '1',
            'STATUS' => 'Up',
            'MACADDR' => '00:50:56:4e:eb:6f',
            'DESCRIPTION' => 'vswif0',
            'IPADDRESS' => '10.0.2.190'
          },
          {
            'MTU' => undef,
            'IPMASK' => '255.255.0.0',
            'VIRTUALDEV' => '1',
            'STATUS' => 'Up',
            'MACADDR' => '00:50:56:75:f7:2e',
            'DESCRIPTION' => 'vmk0',
            'IPADDRESS' => '10.0.2.189'
          }
        ],
        'getStorages()' => [
          {
            'NAME' => '/vmfs/devices/cdrom/mpx.vmhba0:C0:T0:L0',
            'FIRMWARE' => '1.AC',
            'TYPE' => 'cdrom',
            'DISKSIZE' => undef,
            'SERIAL' => undef,
            'DESCRIPTION' => 'Local TEAC CD-ROM (mpx.vmhba0:C0:T0:L0)',
            'MANUFACTURER' => 'TEAC    ',
            'MODEL' => 'DV-28E-V        '
          },
          {
            'NAME' => '/vmfs/devices/disks/t10.ATA_____ST3250310NS_________________________________________9SF1F0TH',
            'FIRMWARE' => 'SN06',
            'TYPE' => 'disk',
            'DISKSIZE' => '250059350.016',
            'SERIAL' => '3232323232323232323232325783704970488472',
            'DESCRIPTION' => 'Local ATA Disk (t10.ATA_____ST3250310NS_________________________________________9SF1F0TH)',
            'MANUFACTURER' => 'Seagate',
            'MODEL' => 'ST3250310NS     '
          }
        ],
        'getDrives()' => [
          {
            'VOLUMN' => undef,
            'NAME' => 'datastore1',
            'TOTAL' => 248571,
            'SERIAL' => '4d3ea5ac-45d89fb1-847e-001b24f06a45',
            'TYPE' => '/vmfs/volumes/4d3ea5ac-45d89fb1-847e-001b24f06a45',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => 'stockage1.teclib.local:/mnt/datastore/VmwareISO',
            'NAME' => 'ISO-datastore',
            'TOTAL' => 53687,
            'SERIAL' => undef,
            'TYPE' => '/vmfs/volumes/6954b300-01710358',
            'FILESYSTEM' => 'nfs'
          }
        ],
        'getVirtualMachines()' => [
          {
            'VMTYPE' => 'VMware',
            'NAME' => 'ubuntu',
            'STATUS' => 'running',
            'MEMORY' => '512',
            'UUID' => '564d9904-a176-a762-1b95-f75ddd0642d8',
            'VMID' => '16',
            'VCPU' => '1'
          }
        ]
    },
    'esx-4.1.0-2' => {
        'login()' => {
          'lastActiveTime' => '1970-01-14T23:35:51.597943Z',
          'loginTime' => '1970-01-14T23:35:51.597943Z',
          'fullName' => 'Administrator',
          'messageLocale' => 'en',
          'locale' => 'en',
          'userName' => 'root',
          'key' => '52df8e0e-ef0a-546e-ec81-a5da86d19aed'
        },
        'getHostname()' => 'vmware01.localdomain',
        'getBiosInfo()' => {
          'SMANUFACTURER' => 'IBM',
          'SMODEL' => 'BladeCenter HS22 -[7870C4G]-',
          'BDATE' => '2010-12-15T00:00:00Z',
          'ASSETTAG' => ' none',
          'BVERSION' => '-[P9E150BUS-1.11]-'
        },
        'getHardwareInfo()' => {
          'OSCOMMENTS' => 'VMware ESXi 4.1.0 build-320137',
          'NAME' => 'vmware01',
          'OSVERSION' => '4.1.0',
          'WORKGROUP' => 'localdomain',
          'MEMORY' => 49140,
          'OSNAME' => 'VMware ESXi',
          'UUID' => '1bb550da-f758-11df-8ecb-e41f131cbab4',
          'DNS' => '192.10.1.55/192.10.1.101',
        },
        'getCPUs()' => [
          {
            'NAME' => 'Intel(R) Xeon(R) CPU           X5570  @ 2.93GHz',
            'MANUFACTURER' => 'Intel',
            'SPEED' => 2933,
            'THREAD' => '2',
            'CORE' => 8
          },
          {
            'NAME' => 'Intel(R) Xeon(R) CPU           X5570  @ 2.93GHz',
            'MANUFACTURER' => 'Intel',
            'SPEED' => 2933,
            'THREAD' => '2',
            'CORE' => 8
          }
        ],
        'getControllers()' => [
          {
            'PCISUBSYSTEMID' => '1014:7270',
            'PCICLASS' => '600',
            'NAME' => '5520 I/O Hub to ESI Port',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3406',
            'PCISLOT' => '00:00.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => '5520/5500/X58 I/O Hub PCI Express Root Port 1',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3408',
            'PCISLOT' => '00:01.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => '5520/5500/X58 I/O Hub PCI Express Root Port 3',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:340a',
            'PCISLOT' => '00:03.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => '5520/X58 I/O Hub PCI Express Root Port 5',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:340c',
            'PCISLOT' => '00:05.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => '5520/5500/X58 I/O Hub PCI Express Root Port 7',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:340e',
            'PCISLOT' => '00:07.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => '5520/5500/X58 I/O Hub PCI Express Root Port 8',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:340f',
            'PCISLOT' => '00:08.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => '5520/5500/X58 I/O Hub PCI Express Root Port 9',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3410',
            'PCISLOT' => '00:09.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '800',
            'NAME' => '5520/5500/X58 Physical and Link Layer Registers Port 0',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3425',
            'PCISLOT' => '00:10.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '800',
            'NAME' => '5520/5500/X58 Routing and Protocol Layer Registers Port 0',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3426',
            'PCISLOT' => '00:10.1'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '800',
            'NAME' => '5520/5500 Physical and Link Layer Registers Port 1',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3427',
            'PCISLOT' => '00:11.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '800',
            'NAME' => '5520/5500 Routing & Protocol Layer Register Port 1',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3428',
            'PCISLOT' => '00:11.1'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '800',
            'NAME' => '5520/5500/X58 I/O Hub System Management Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:342e',
            'PCISLOT' => '00:14.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '800',
            'NAME' => '5520/5500/X58 I/O Hub GPIO and Scratch Pad Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3422',
            'PCISLOT' => '00:14.1'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '800',
            'NAME' => '5520/5500/X58 I/O Hub Control Status and RAS Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3423',
            'PCISLOT' => '00:14.2'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '800',
            'NAME' => '5520/5500/X58 I/O Hub Throttle Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3438',
            'PCISLOT' => '00:14.3'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '800',
            'NAME' => '5520/5500/X58 Trusted Execution Technology Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:342f',
            'PCISLOT' => '00:15.0'
          },
          {
            'PCISUBSYSTEMID' => '1014:3430',
            'PCICLASS' => '880',
            'NAME' => '5520/5500/X58 Chipset QuickData Technology Device',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3430',
            'PCISLOT' => '00:16.0'
          },
          {
            'PCISUBSYSTEMID' => '1014:3431',
            'PCICLASS' => '880',
            'NAME' => '5520/5500/X58 Chipset QuickData Technology Device',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3431',
            'PCISLOT' => '00:16.1'
          },
          {
            'PCISUBSYSTEMID' => '1014:3432',
            'PCICLASS' => '880',
            'NAME' => '5520/5500/X58 Chipset QuickData Technology Device',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3432',
            'PCISLOT' => '00:16.2'
          },
          {
            'PCISUBSYSTEMID' => '1014:3433',
            'PCICLASS' => '880',
            'NAME' => '5520/5500/X58 Chipset QuickData Technology Device',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3433',
            'PCISLOT' => '00:16.3'
          },
          {
            'PCISUBSYSTEMID' => '1014:3429',
            'PCICLASS' => '880',
            'NAME' => '5520/5500/X58 Chipset QuickData Technology Device',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3429',
            'PCISLOT' => '00:16.4'
          },
          {
            'PCISUBSYSTEMID' => '1014:342a',
            'PCICLASS' => '880',
            'NAME' => '5520/5500/X58 Chipset QuickData Technology Device',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:342a',
            'PCISLOT' => '00:16.5'
          },
          {
            'PCISUBSYSTEMID' => '1014:342b',
            'PCICLASS' => '880',
            'NAME' => '5520/5500/X58 Chipset QuickData Technology Device',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:342b',
            'PCISLOT' => '00:16.6'
          },
          {
            'PCISUBSYSTEMID' => '1014:342c',
            'PCICLASS' => '880',
            'NAME' => '5520/5500/X58 Chipset QuickData Technology Device',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:342c',
            'PCISLOT' => '00:16.7'
          },
          {
            'PCISUBSYSTEMID' => '1014:3a37',
            'PCICLASS' => 'c03',
            'NAME' => '82801JI (ICH10 Family) USB UHCI Controller #4',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3a37',
            'PCISLOT' => '00:1a.0'
          },
          {
            'PCISUBSYSTEMID' => '1014:3a3c',
            'PCICLASS' => 'c03',
            'NAME' => '82801JI (ICH10 Family) USB2 EHCI Controller #2',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3a3c',
            'PCISLOT' => '00:1a.7'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => '82801JI (ICH10 Family) PCI Express Port 1',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3a40',
            'PCISLOT' => '00:1c.0'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => '82801JI (ICH10 Family) PCI Express Port 5',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3a48',
            'PCISLOT' => '00:1c.4'
          },
          {
            'PCISUBSYSTEMID' => '1014:3a34',
            'PCICLASS' => 'c03',
            'NAME' => '82801JI (ICH10 Family) USB UHCI Controller #1',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3a34',
            'PCISLOT' => '00:1d.0'
          },
          {
            'PCISUBSYSTEMID' => '1014:3a35',
            'PCICLASS' => 'c03',
            'NAME' => '82801JI (ICH10 Family) USB UHCI Controller #2',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3a35',
            'PCISLOT' => '00:1d.1'
          },
          {
            'PCISUBSYSTEMID' => '1014:3a36',
            'PCICLASS' => 'c03',
            'NAME' => '82801JI (ICH10 Family) USB UHCI Controller #3',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3a36',
            'PCISLOT' => '00:1d.2'
          },
          {
            'PCISUBSYSTEMID' => '1014:3a3a',
            'PCICLASS' => 'c03',
            'NAME' => '82801JI (ICH10 Family) USB2 EHCI Controller #1',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3a3a',
            'PCISLOT' => '00:1d.7'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => '82801 PCI Bridge',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:244e',
            'PCISLOT' => '00:1e.0'
          },
          {
            'PCISUBSYSTEMID' => '1014:3a18',
            'PCICLASS' => '601',
            'NAME' => '82801JIB (ICH10) LPC Interface Controller',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3a18',
            'PCISLOT' => '00:1f.0'
          },
          {
            'PCISUBSYSTEMID' => '1014:3a30',
            'PCICLASS' => 'c05',
            'NAME' => '82801JI (ICH10 Family) SMBus Controller',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:3a30',
            'PCISLOT' => '00:1f.3'
          },
          {
            'PCISUBSYSTEMID' => '0:0',
            'PCICLASS' => '604',
            'NAME' => 'VSC452 [SuperBMC]',
            'MANUFACTURER' => 'Vitesse Semiconductor',
            'PCIID' => '101b:452',
            'PCISLOT' => '06:00.0'
          },
          {
            'PCISUBSYSTEMID' => '1014:369',
            'PCICLASS' => '300',
            'NAME' => 'MGA G200EV',
            'MANUFACTURER' => 'Matrox Graphics, Inc.',
            'PCIID' => '102b:530',
            'PCISLOT' => '07:00.0'
          },
          {
            'PCISUBSYSTEMID' => '1014:3a7',
            'PCICLASS' => '100',
            'NAME' => 'LSI1064E',
            'MANUFACTURER' => 'LSI Logic / Symbios Logic',
            'PCIID' => '1000:56',
            'PCISLOT' => '0b:00.0'
          },
          {
            'PCISUBSYSTEMID' => '1014:370',
            'PCICLASS' => '200',
            'NAME' => 'Broadcom NetXtreme II BCM5709 1000Base-SX',
            'MANUFACTURER' => 'Broadcom Corporation',
            'PCIID' => '14e4:163a',
            'PCISLOT' => '10:00.0'
          },
          {
            'PCISUBSYSTEMID' => '1014:370',
            'PCICLASS' => '200',
            'NAME' => 'Broadcom NetXtreme II BCM5709 1000Base-SX',
            'MANUFACTURER' => 'Broadcom Corporation',
            'PCIID' => '14e4:163a',
            'PCISLOT' => '10:00.1'
          },
          {
            'PCISUBSYSTEMID' => '1077:165',
            'PCICLASS' => 'c04',
            'NAME' => 'ISP2532-based 8Gb Fibre Channel to PCI Express HBA',
            'MANUFACTURER' => 'QLogic Corp',
            'PCIID' => '1077:2532',
            'PCISLOT' => '24:00.0'
          },
          {
            'PCISUBSYSTEMID' => '1077:165',
            'PCICLASS' => 'c04',
            'NAME' => 'ISP2532-based 8Gb Fibre Channel to PCI Express HBA',
            'MANUFACTURER' => 'QLogic Corp',
            'PCIID' => '1077:2532',
            'PCISLOT' => '24:00.1'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 QuickPath Architecture Generic Non-Core Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c40',
            'PCISLOT' => 'fe:00.0'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 QuickPath Architecture System Address Decoder',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c01',
            'PCISLOT' => 'fe:00.1'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 QPI Link 0',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c10',
            'PCISLOT' => 'fe:02.0'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 QPI Physical 0',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c11',
            'PCISLOT' => 'fe:02.1'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 QPI Link 1',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c14',
            'PCISLOT' => 'fe:02.4'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 QPI Physical 1',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c15',
            'PCISLOT' => 'fe:02.5'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c18',
            'PCISLOT' => 'fe:03.0'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Target Address Decoder',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c19',
            'PCISLOT' => 'fe:03.1'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller RAS Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c1a',
            'PCISLOT' => 'fe:03.2'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Test Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c1c',
            'PCISLOT' => 'fe:03.4'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 0 Control Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c20',
            'PCISLOT' => 'fe:04.0'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 0 Address Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c21',
            'PCISLOT' => 'fe:04.1'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 0 Rank Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c22',
            'PCISLOT' => 'fe:04.2'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 0 Thermal Control Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c23',
            'PCISLOT' => 'fe:04.3'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 1 Control Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c28',
            'PCISLOT' => 'fe:05.0'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 1 Address Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c29',
            'PCISLOT' => 'fe:05.1'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 1 Rank Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c2a',
            'PCISLOT' => 'fe:05.2'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 1 Thermal Control Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c2b',
            'PCISLOT' => 'fe:05.3'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 2 Control Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c30',
            'PCISLOT' => 'fe:06.0'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 2 Address Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c31',
            'PCISLOT' => 'fe:06.1'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 2 Rank Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c32',
            'PCISLOT' => 'fe:06.2'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 2 Thermal Control Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c33',
            'PCISLOT' => 'fe:06.3'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 QuickPath Architecture Generic Non-Core Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c40',
            'PCISLOT' => 'ff:00.0'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 QuickPath Architecture System Address Decoder',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c01',
            'PCISLOT' => 'ff:00.1'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 QPI Link 0',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c10',
            'PCISLOT' => 'ff:02.0'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 QPI Physical 0',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c11',
            'PCISLOT' => 'ff:02.1'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 QPI Link 1',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c14',
            'PCISLOT' => 'ff:02.4'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 QPI Physical 1',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c15',
            'PCISLOT' => 'ff:02.5'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c18',
            'PCISLOT' => 'ff:03.0'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Target Address Decoder',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c19',
            'PCISLOT' => 'ff:03.1'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller RAS Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c1a',
            'PCISLOT' => 'ff:03.2'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Test Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c1c',
            'PCISLOT' => 'ff:03.4'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 0 Control Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c20',
            'PCISLOT' => 'ff:04.0'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 0 Address Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c21',
            'PCISLOT' => 'ff:04.1'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 0 Rank Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c22',
            'PCISLOT' => 'ff:04.2'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 0 Thermal Control Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c23',
            'PCISLOT' => 'ff:04.3'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 1 Control Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c28',
            'PCISLOT' => 'ff:05.0'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 1 Address Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c29',
            'PCISLOT' => 'ff:05.1'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 1 Rank Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c2a',
            'PCISLOT' => 'ff:05.2'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 1 Thermal Control Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c2b',
            'PCISLOT' => 'ff:05.3'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 2 Control Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c30',
            'PCISLOT' => 'ff:06.0'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 2 Address Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c31',
            'PCISLOT' => 'ff:06.1'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 2 Rank Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c32',
            'PCISLOT' => 'ff:06.2'
          },
          {
            'PCISUBSYSTEMID' => '8086:8086',
            'PCICLASS' => '600',
            'NAME' => 'Xeon 5500/Core i7 Integrated Memory Controller Channel 2 Thermal Control Registers',
            'MANUFACTURER' => 'Intel Corporation',
            'PCIID' => '8086:2c33',
            'PCISLOT' => 'ff:06.3'
          }
        ],
        'getNetworks()' => [
          {
            'IPMASK' => undef,
            'STATUS' => 'Down',
            'MACADDR' => 'e4:1f:13:1c:ba:b4',
            'DESCRIPTION' => 'vmnic0',
            'SPEED' => '1000',
            'PCISLOT' => '10:00.0',
            'IPADDRESS' => undef,
            'DRIVER' => 'bnx2'
          },
          {
            'IPMASK' => undef,
            'STATUS' => 'Down',
            'MACADDR' => 'e4:1f:13:1c:ba:b6',
            'DESCRIPTION' => 'vmnic1',
            'SPEED' => '1000',
            'PCISLOT' => '10:00.1',
            'IPADDRESS' => undef,
            'DRIVER' => 'bnx2'
          },
          {
            'IPMASK' => undef,
            'STATUS' => 'Down',
            'MACADDR' => 'e6:1f:13:1d:ba:b7',
            'DESCRIPTION' => 'vusb0',
            'SPEED' => '0',
            'PCISLOT' => '',
            'IPADDRESS' => undef,
            'DRIVER' => 'cdc_ether'
          },
          {
            'IPMASK' => undef,
            'VIRTUALDEV' => '1',
            'STATUS' => 'Down',
            'MACADDR' => undef,
            'SPEED' => undef,
            'PCISLOT' => undef,
            'DRIVER' => undef,
            'DESCRIPTION' => 'vmk0',
            'IPADDRESS' => undef
          },
          {
            'IPMASK' => undef,
            'VIRTUALDEV' => '1',
            'STATUS' => 'Down',
            'MACADDR' => undef,
            'SPEED' => undef,
            'PCISLOT' => undef,
            'DRIVER' => undef,
            'DESCRIPTION' => 'vmk1',
            'IPADDRESS' => undef
          }
        ],
        'getStorages()' => [
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e58416c5a6176412d5471',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '302795194.368',
            'SERIAL' => '7211088651089097118654584113',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e58416c5a6176412d5471)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e57664c34564d446c6973',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '555176951.808',
            'SERIAL' => '72110871027652867768108105115',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e57664c34564d446c6973)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e58416c5a494933384344',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '555176951.808',
            'SERIAL' => '72110886510890737351566768',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e58416c5a494933384344)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e57664c344852752f4544',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '242262999.04',
            'SERIAL' => '721108710276527282117476968',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e57664c344852752f4544)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e58416c5a2f594670426e',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '333104283.648',
            'SERIAL' => '7211088651089047897011266110',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e58416c5a2f594670426e)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e58416c5a564c32486271',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '555176951.808',
            'SERIAL' => '721108865108908676507298113',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e58416c5a564c32486271)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e57664c344f4e78475646',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '353271545.856',
            'SERIAL' => '721108710276527978120718670',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e57664c344f4e78475646)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e57664c342f5946526874',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '333104283.648',
            'SERIAL' => '7211087102765247897082104116',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e57664c342f5946526874)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e57664c3451796d4e2d30',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '508978790.4',
            'SERIAL' => '7211087102765281121109784548',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e57664c3451796d4e2d30)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.600508e000000000c17b9ea0cb164e0f',
            'FIRMWARE' => '3000',
            'TYPE' => 'disk',
            'DISKSIZE' => '71999422.464',
            'SERIAL' => undef,
            'DESCRIPTION' => 'LSILOGIC Serial Attached SCSI Disk (naa.600508e000000000c17b9ea0cb164e0f)',
            'MANUFACTURER' => 'Logical Volume  ',
            'MODEL' => 'Logical Volume  '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e58416c5a2f55514f316f',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '333104283.648',
            'SERIAL' => '721108865108904785817949111',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e58416c5a2f55514f316f)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e57664c342f554c757247',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '333104283.648',
            'SERIAL' => '7211087102765247857611711471',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e57664c342f554c757247)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e57664c344851754e6631',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '353261060.096',
            'SERIAL' => '7211087102765272811177810249',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e57664c344851754e6631)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e57664c3448516f545a4b',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '353261060.096',
            'SERIAL' => '721108710276527281111849075',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e57664c3448516f545a4b)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e57664c342f59464a7035',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '333104283.648',
            'SERIAL' => '721108710276524789707411253',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e57664c342f59464a7035)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e57664c344852756c3068',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '242262999.04',
            'SERIAL' => '72110871027652728211710848104',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e57664c344852756c3068)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e58416c5a495058526c6d',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '353269448.704',
            'SERIAL' => '7211088651089073808882108109',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e58416c5a495058526c6d)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e58416c5a485339614268',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '242262999.04',
            'SERIAL' => '721108865108907283579766104',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e58416c5a485339614268)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e58416c5a2f554e2f4444',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '333104283.648',
            'SERIAL' => '72110886510890478578476868',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e58416c5a2f554e2f4444)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e58416c5a2f594677734c',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '333104283.648',
            'SERIAL' => '7211088651089047897011911576',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e58416c5a2f594677734c)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e58416c5a485339586664',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '353261060.096',
            'SERIAL' => '7211088651089072835788102100',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e58416c5a485339586664)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e58416c5a485339597867',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '353261060.096',
            'SERIAL' => '7211088651089072835789120103',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e58416c5a485339597867)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e57664c342f6335575541',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '333104283.648',
            'SERIAL' => '72110871027652479953878565',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e57664c342f6335575541)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e57664c342f5550717765',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '333153566.72',
            'SERIAL' => '72110871027652478580113119101',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e57664c342f5550717765)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e58416c5a485339654a33',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '242262999.04',
            'SERIAL' => '721108865108907283571017451',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e58416c5a485339654a33)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e58416c5a4f4e764b5842',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '302813020.16',
            'SERIAL' => '721108865108907978118758866',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e58416c5a4f4e764b5842)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          },
          {
            'NAME' => '/vmfs/devices/disks/naa.60a98000486e57664c34494932547478',
            'FIRMWARE' => '7340',
            'TYPE' => 'disk',
            'DISKSIZE' => '403759431.68',
            'SERIAL' => '7211087102765273735084116120',
            'DESCRIPTION' => 'NETAPP Fibre Channel Disk (naa.60a98000486e57664c34494932547478)',
            'MANUFACTURER' => 'LUN             ',
            'MODEL' => 'LUN             '
          }
        ],
        'getDrives()' => [
          {
            'VOLUMN' => undef,
            'NAME' => 'FSANV6C2',
            'TOTAL' => 332859,
            'SERIAL' => '4cefcf15-69f0826f-c575-00215e23f3f4',
            'TYPE' => '/vmfs/volumes/4cefcf15-69f0826f-c575-00215e23f3f4',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV3C2',
            'TOTAL' => 352992,
            'SERIAL' => '4832c48d-2c95d2c1-61bc-00145ed5c860',
            'TYPE' => '/vmfs/volumes/4832c48d-2c95d2c1-61bc-00145ed5c860',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV4C2',
            'TOTAL' => 332859,
            'SERIAL' => '4cf3f512-8a2403f7-2975-e61f131993c3',
            'TYPE' => '/vmfs/volumes/4cf3f512-8a2403f7-2975-e61f131993c3',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV2C2',
            'TOTAL' => 242128,
            'SERIAL' => '47fb48a5-2f1e5a98-b123-001a64325868',
            'TYPE' => '/vmfs/volumes/47fb48a5-2f1e5a98-b123-001a64325868',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV5C2',
            'TOTAL' => 555124,
            'SERIAL' => '4b9676a3-846d33a1-ca53-e41f13189970',
            'TYPE' => '/vmfs/volumes/4b9676a3-846d33a1-ca53-e41f13189970',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'FSANV2C2M',
            'TOTAL' => 352992,
            'SERIAL' => '47fb48db-77de61a8-447d-001a64325868',
            'TYPE' => '/vmfs/volumes/47fb48db-77de61a8-447d-001a64325868',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV1C2M',
            'TOTAL' => 352992,
            'SERIAL' => '47fb4802-de311368-4631-001a64325868',
            'TYPE' => '/vmfs/volumes/47fb4802-de311368-4631-001a64325868',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV1C2',
            'TOTAL' => 242128,
            'SERIAL' => '47fb47be-48aac1c8-fec6-001a64325868',
            'TYPE' => '/vmfs/volumes/47fb47be-48aac1c8-fec6-001a64325868',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV4C2M',
            'TOTAL' => 302526,
            'SERIAL' => '49c3bc4e-643444ef-fd19-00145ed5c6fe',
            'TYPE' => '/vmfs/volumes/49c3bc4e-643444ef-fd19-00145ed5c6fe',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV1C1M',
            'TOTAL' => 352992,
            'SERIAL' => '47fb4517-2ae4bef0-1608-001a64325868',
            'TYPE' => '/vmfs/volumes/47fb4517-2ae4bef0-1608-001a64325868',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'FSANV2C1M',
            'TOTAL' => 352992,
            'SERIAL' => '47fb4633-571a0ce0-0b58-001a64325868',
            'TYPE' => '/vmfs/volumes/47fb4633-571a0ce0-0b58-001a64325868',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV1C1',
            'TOTAL' => 242128,
            'SERIAL' => '47fb46e5-d991b5b8-c309-001a64325868',
            'TYPE' => '/vmfs/volumes/47fb46e5-d991b5b8-c309-001a64325868',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV5C1M',
            'TOTAL' => 332859,
            'SERIAL' => '4cf3f427-c42790a0-f5f9-e61f13198f67',
            'TYPE' => '/vmfs/volumes/4cf3f427-c42790a0-f5f9-e61f13198f67',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV2C1',
            'TOTAL' => 242128,
            'SERIAL' => '47fb4716-27781518-1ea9-001a64325868',
            'TYPE' => '/vmfs/volumes/47fb4716-27781518-1ea9-001a64325868',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV5C1',
            'TOTAL' => 555124,
            'SERIAL' => '4b97b74d-a4865955-2979-e41f13189970',
            'TYPE' => '/vmfs/volumes/4b97b74d-a4865955-2979-e41f13189970',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV5C2M',
            'TOTAL' => 332859,
            'SERIAL' => '4cf3f587-4098dec4-69c9-e61f13198f67',
            'TYPE' => '/vmfs/volumes/4cf3f587-4098dec4-69c9-e61f13198f67',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'FSANV3C2M',
            'TOTAL' => 555124,
            'SERIAL' => '482b0286-1d230958-2a72-001a64325868',
            'TYPE' => '/vmfs/volumes/482b0286-1d230958-2a72-001a64325868',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'FSANV3C1M',
            'TOTAL' => 403726,
            'SERIAL' => '482b0215-cc5483a0-1129-001a64325868',
            'TYPE' => '/vmfs/volumes/482b0215-cc5483a0-1129-001a64325868',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'FSANV4C1M',
            'TOTAL' => 508953,
            'SERIAL' => '4a71a710-f22c4fc0-2ebd-00145ed5c6fe',
            'TYPE' => '/vmfs/volumes/4a71a710-f22c4fc0-2ebd-00145ed5c6fe',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV3C1',
            'TOTAL' => 352992,
            'SERIAL' => '49c3c41f-942e7610-dec0-00145ed5c6fe',
            'TYPE' => '/vmfs/volumes/49c3c41f-942e7610-dec0-00145ed5c6fe',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'FSANV4C1',
            'TOTAL' => 332859,
            'SERIAL' => '4cf3ef1d-09920346-572f-e61f13199973',
            'TYPE' => '/vmfs/volumes/4cf3ef1d-09920346-572f-e61f13199973',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV7C2',
            'TOTAL' => 302526,
            'SERIAL' => '4d500eda-3445e766-d1e1-e61f131dbab7',
            'TYPE' => '/vmfs/volumes/4d500eda-3445e766-d1e1-e61f131dbab7',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'FSANV7C1',
            'TOTAL' => 332859,
            'SERIAL' => '4cf8efcc-296722cc-216c-00215e23f640',
            'TYPE' => '/vmfs/volumes/4cf8efcc-296722cc-216c-00215e23f640',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'FSANV6C2M',
            'TOTAL' => 332859,
            'SERIAL' => '4cf37ce8-b64e5e4c-a3e2-e61f131993c3',
            'TYPE' => '/vmfs/volumes/4cf37ce8-b64e5e4c-a3e2-e61f131993c3',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV6C1M',
            'TOTAL' => 333128,
            'SERIAL' => '4cf37ba4-246ace0f-db3c-e61f13198f67',
            'TYPE' => '/vmfs/volumes/4cf37ba4-246ace0f-db3c-e61f13198f67',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'SANV6C1',
            'TOTAL' => 332859,
            'SERIAL' => '4cefc89b-a1edc941-0023-e61f13199237',
            'TYPE' => '/vmfs/volumes/4cefc89b-a1edc941-0023-e61f13199237',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => undef,
            'NAME' => 'HDLocal1',
            'TOTAL' => 66571,
            'SERIAL' => '4d235b33-8259eeca-354d-e41f131cbab6',
            'TYPE' => '/vmfs/volumes/4d235b33-8259eeca-354d-e41f131cbab6',
            'FILESYSTEM' => 'vmfs'
          }
        ]

    }
);
plan tests => 4;

foreach my $dir (glob('resources/*')) {
    my $testName = basename($dir);
    my $vpbs = FusionInventory::VMware::SOAP->new({
    debugDir => $dir,
    user => 'foo',
    });

    my $ret;
    lives_ok{$ret = $vpbs->login('foo', 'bar')} $testName.' login()';
    is_deeply($ret, $test{$testName}{'login()'}, 'login()') or print  Dumper($ret);

    lives_ok{$ret = $vpbs->getHostFullInfo()} $testName.' getHostFullInfo()';

    foreach my $func (qw(getHostname getBiosInfo getHardwareInfo getCPUs getControllers getNetworks getStorages getDrives getVirtualMachines)) {
        is_deeply($ret->$func, $test{$testName}{"$func()"}, "$func()") or print "####\n". Dumper($ret->$func)."####\n";

    }

}
