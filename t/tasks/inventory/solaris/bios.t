#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Task::Inventory::Solaris::Bios;

my %showrev_tests = (
    'SPARC-1' => {
        'Release' => '5.10',
        'Hostname' => '157501s021plc',
        'Kernel version' => 'SunOS',
        'Kernel architecture' => 'sun4u',
        'Hardware provider' => 'Sun_Microsystem',
        'Domain' => 'be.cnamts.fr',
        'Application architecture' => 'sparc',
        'Hostid' => '83249bbf',
    },
    'SPARC-2' => {
        'Kernel version' => 'SunOS',
        'Release' => '5.10',
        'Hostname' => 'mysunserver',
        'Hardware provider' => 'Sun_Microsystems',
        'Kernel architecture' => 'sun4v',
        'Application architecture' => 'sparc',
        'Hostid' => 'mabox'
    },
    'x86-1' => {
        'Kernel version' => 'SunOS',
        'Hostname' => 'stlaurent',
        'Kernel architecture' => 'i86pc',
        'Application architecture' => 'i386',
        'Hostid' => '403100b',
        'Release' => '5.10',
    },
    'x86-2' => {
        'Kernel version' => 'SunOS',
        'Release' => '5.10',
        'Hostname' => 'mamachine',
        'Kernel architecture' => 'i86pc',
        'Application architecture' => 'i386',
        'Hostid' => '7c31a88'
    },
    'x86-3' => {
        'Kernel version' => 'SunOS',
        'Release' => '5.10',
        'Hostname' => 'plop',
        'Kernel architecture' => 'i86pc',
        'Application architecture' => 'i386',
        'Hostid' => '7c31a36'
    }
);

my %smbios_tests = (
    'x86-1' => {
        'SMB_TYPE_SYSTEM' => {
            'Version' => '00',
            'SKU Number' => ' ',
            'Serial Number' => 'R00T34E0009',
            'Product' => 'Sun Fire V40z',
            'Manufacturer' => 'Sun Microsystems, Inc.',
            'UUID' => 'be1630df-d130-41a4-be32-fd28bb4bd1ac',
            'Wake-Up Event' => '0x6 (power switch)'
        }
    },
    'x86-3' => {
        SMB_TYPE_CHASSIS => {
            'Chassis Height' => '1u',
            'Power Supply State' => '0x3 (safe)',
            'Element Records' => '0',
            'Serial Number' => 'QSDH1234567',
            'Thermal State' => '0x3 (safe)',
            'Lock Present' => 'N',
            'Asset Tag' => '6I012345TF',
            'Chassis Type' => '0x17 (rack mount chassis)',
            'Power Cords' => '1',
            'Version' => 'E10476-011',
            'OEM Data' => '0x81581cf8',
            'Boot-Up State' => '0x3 (safe)',
            'Manufacturer' => 'TRANSTEC'
        },
        SMB_TYPE_BIOS => {
            'Characteristics' => '0x15c099a80',
            'Version Number' => '0.0',
            'Vendor' => 'Intel Corporation',
            'Image Size' => '98304 bytes',
            'Characteristics Extension Byte 2' => '0x7',
            'Characteristics Extension Byte 1' => '0x33',
            'Address Segment' => '0xe800',
            'Version String' => 'SFC4UR.86B.01.00.0029.071220092126',
            'Embedded Ctlr Firmware Version Number' => '0.0',
            'Release Date' => '07/12/2009',
            'ROM Size' => '8388608 bytes'
        },
        SMB_TYPE_IPMIDEV => {
            'Flags' => '0x9',
            'NV Storage Device Bus ID' => '0xffffffff',
            'BMC IPMI Version' => '2.0',
            'Register Spacing' => '1',
            'Interrupt Number' => '0',
            'Type' => '1 (KCS: Keyboard Controller Style)',
            'i2c Bus Slave Address' => '0x20',
            'BMC Base Address' => '0xca2'
        },
        SMB_TYPE_BASEBOARD => {
            'Board Type' => '0xa (motherboard)',
            'Flags' => '0x9',
            'Serial Number' => 'QSFX12345678',
            'Product' => 'S7000FC4UR',
            'Manufacturer' => 'Intel',
            'Chassis' => '0',
            'Asset Tag' => '6I012345TF'
        },
        SMB_TYPE_SYSTEM => {
            'Family' => ' ',
            'SKU Number' => '6I012345TF',
            'Product' => 'MP Server',
            'Manufacturer' => 'Intel',
            'UUID' => '4b713db6-6d40-11dd-b32c-000123456789',
            'Wake-Up Event' => '0x6 (power switch)'
        }
    }
);

my %prtconf_tests = (
    'sparc1' => {
        'compatible'  => 'SUNW,Serengeti',
        'device_type' => 'gptwo',
        'banner-name' => 'Sun Fire E6900',
        'name'        => 'SUNW,Sun-Fire'
    },
    'sparc2' => {
        'aty,card#'            => '102-85514-00',
        'load-base'            => '16384',
        'oem-banner?'          => 'false',
        'disk9'                => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@b,0',
        'aty,rom#'             => '113-85514-101',
        'diag-out-console'     => 'true',
        'diag-level'           => 'off',
        'archive-fstype'       => 'hsfs',
        'boot-device'          => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@w21000014c34173c0,0:a',
        'diag-passes'          => '1',
        'cdrom'                => '/pci@8,700000/ide@1/cdrom@0,0:f',
        'disk7'                => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@9,0',
        'rsc-console'          => '/pci@9,700000/ebus@1/rsc-console@1,3083f8',
        'bbc0'                 => '/pci@9,700000/ebus@1/bbc@1,0',
        'input-device'         => 'rsc-console',
        'pci9a'                => '/pci@9,600000',
        'disk8'                => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@a,0',
        'service-mode?'        => 'false',
        'nvram'                => '/pci@9,700000/ebus@1/i2c@1,500030/nvram@0,a0',
        'ttyb-mode'            => '9600,8,n,1,-',
        'compatible'           => 'SUNW,UltraSPARC-IV',
        'diag-switch?'         => 'false',
        'has-fcode'            => ' ',
        'ansi-terminal?'       => 'true',
        'bbc1'                 => '/pci@9,700000/ebus@1/bbc@1,500000',
        'diag-script'          => 'none',
        'scsi-initiator-id'    => '7',
        'aty,fcode'            => '1.86',
        'pci8a'                => '/pci@8,600000',
        'i2c3'                 => '/pci@9,700000/ebus@1/i2c@1,500030',
        'flash'                => '/pci@9,700000/ebus@1/flashprom@0,0',
        'i2c2'                 => '/pci@9,700000/ebus@1/i2c@1,50002e',
        'pci8b'                => '/pci@8,700000',
        'screen'               => '/pci@9,700000/SUNW,XVR-100@3',
        'pci9b'                => '/pci@9,700000',
        'screen-#columns'      => '80',
        'version'              => 'OBP 4.15.6 2005/01/06 04:25',
        'local-mac-address?'   => 'false',
        'diag-trigger'         => 'none',
        'error-reset-recovery' => 'sync',
        'bootargs'             => '-v',
        'i2c0'                 => '/pci@9,700000/ebus@1/i2c@1,2e',
        'disk1'                => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@1,0',
        'bootarchive'          => '/ramdisk-root',
        'verbosity'            => 'normal',
        'diag-device'          => 'net',
        'auto-boot-on-error?'  => 'true',
        'fstype'               => 'ufs',
        'ttyb-ignore-cd'       => 'true',
        'disk5'                => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@5,0',
        'impl-arch-name'       => 'SUNW,Sun-Fire-V890',
        'banner-name'          => 'Sun Fire V890',
        'disk6'                => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@8,0',
        'disk11'               => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@d,0',
        'whoami'               => '/platform/sun4u/kernel/sparcv9/unix',
        'disk10'               => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@c,0',
        'name'                 => 'SUNW,Sun-Fire-V890',
        'source'               => '/flashprom:',
        'fs-package'           => 'hsfs-file-system',
        'shared-pins'          => 'serdes',
        'disk3'                => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@3,0',
        'gem'                  => '/pci@8,600000/network@1',
        'ide'                  => '/pci@8,700000/ide@1',
        'manufacturer'         => 'QLGC',
        'ebus'                 => '/pci@9,700000/ebus@1',
        'security-#badlogins'  => '0',
        'ttyb-rts-dtr-off'     => 'false',
        'reset-reason'         => 'SPOR Software/User',
        'ttyb'                 => '/pci@9,700000/ebus@1/serial@1,400000:b',
        'screen-#rows'         => '34',
        'disk4'                => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@4,0',
        'model'                => 'SUNW,501-7199',
        'no-probe-list'        => '0',
        'i2c1'                 => '/pci@9,700000/ebus@1/i2c@1,30',
        'use-nvramrc?'         => 'false',
        'net'                  => '/pci@9,700000/network@1,1',
        'device_type'          => 'gptwo',
        'scsi'                 => '/pci@8,600000/SUNW,qlc@2',
        'security-mode'        => 'none',
        'ttya'                 => '/pci@9,700000/ebus@1/serial@1,400000:a',
        'fcode-debug?'         => 'false',
        'oem-logo?'            => 'false',
        'display-type'         => 'NONE',
        'output-device'        => 'rsc-console',
        'boot-command'         => 'boot',
        'ttya-mode'            => '9600,8,n,1,-',
        'ttya-rts-dtr-off'     => 'false',
        'bootpath'             => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@w21000014c34173c0,0:a',
        'disk0'                => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@0,0',
        'rsc-control'          => '/pci@9,700000/ebus@1/rsc-control@1,3062f8',
        'character-set'        => 'ISO8859-1',
        'idprom'               => '/pci@9,700000/ebus@1/i2c@1,500030/idprom@0,a0',
        'disk'                 => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@0,0',
        'disk2'                => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@2,0',
        'ttya-ignore-cd'       => 'true',
        'auto-boot?'           => 'true'
    },
    'sparc3' => {
        'diag-trigger'           => 'error-reset power-on-reset ',
        'disk3'                  => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@3,0',
        'ttyb-ignore-cd'         => 'true',
        'boot-command'           => 'boot',
        'use-nvramrc?'           => 'false',
        'ttyb-mode'              => '9600,8,n,1,-',
        'screen-#columns'        => '80',
        'oem-logo?'              => 'false',
        'fstype'                 => 'zfs',
        'ttya-mode'              => '9600,8,n,1,-',
        'source'                 => '/flashprom:',
        'service-mode?'          => 'false',
        'disk'                   => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@0,0',
        'disk0'                  => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@0,0',
        'banner-name'            => 'Sun Fire V215',
        'diag-script'            => 'normal',
        'ttyb'                   => '/ebus@1f,464000/serial@2,40',
        'bootpath'               => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@1,0:a',
        'local-mac-address?'     => 'true',
        'net1'                   => '/pci@1e,600000/pci@0/pci@9/pci@0/network@4,1',
        'network-interface-type' => 'ethernet',
        'auto-boot?'             => 'true',
        'ttya-rts-dtr-off'       => 'false',
        'diag-device'            => 'disk0 disk1',
        'diag-switch?'           => 'false',
        'security-#badlogins'    => '0',
        'load-base'              => '16384',
        'verbosity'              => 'normal',
        'screen-#rows'           => '34',
        'zfs-bootfs'             => 'rpool/59',
        'whoami'                 => '/platform/sun4u/kernel/sparcv9/unix',
        'model'                  => 'SUNW,375-3463',
        'disk1'                  => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@1,0',
        'ttya'                   => '/ebus@1f,464000/serial@2,80',
        'ide'                    => '/pci@1e,600000/pci@0/pci@1/pci@0/ide@1f',
        'compatible'             => 'SUNW,UltraSPARC-IIIi,mc\' + \'SUNW,mc',
        'net2'                   => '/pci@1e,600000/pci@0/pci@a/pci@0/network@4',
        'disk2'                  => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@2,0',
        'fs-package'             => 'hsfs-file-system',
        'oem-banner?'            => 'false',
        'net0'                   => '/pci@1e,600000/pci@0/pci@9/pci@0/network@4',
        'net'                    => '/pci@1e,600000/pci@0/pci@9/pci@0/network@4',
        'boot-device'            => 'disk1:a disk',
        'gpio-device-type'       => 'SUNW,cpld',
        'name'                   => 'SUNW,Sun-Fire-V215',
        'version'                => 'OBP 4.25.10 2007/09/18 09:56',
        'input-device'           => 'keyboard',
        'sc-control'             => '/ebus@1f,464000/rmc-comm@2,0',
        'ansi-terminal?'         => 'true',
        'security-mode'          => 'none',
        'error-reset-recovery'   => 'sync',
        'ttyb-rts-dtr-off'       => 'false',
        'auto-boot-on-error?'    => 'true',
        'nvramrc'                => 'devalias rootmirror /pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@1,0',
        'scsi-initiator-id'      => '7',
        'diag-passes'            => '1',
        'net3'                   => '/pci@1e,600000/pci@0/pci@a/pci@0/network@4,1',
        'bootarchive'            => '/ramdisk-root',
        'mpt-version'            => '1.05',
        'power-device-type'      => 'SUNW,pic18lf65j10',
        'fcode-debug?'           => 'false',
        'ttya-ignore-cd'         => 'true',
        'diag-level'             => 'max',
        'output-device'          => 'screen',
        'archive-fstype'         => 'hsfs',
        'device_type'            => 'jbus',
        'scsi'                   => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1',
        'cdrom'                  => '/pci@1e,600000/pci@0/pci@1/pci@0/ide@1f/cdrom@0,0:f',
        'impl-arch-name'         => 'SUNW,Sun-Fire-V215',
        'asr-policy'             => 'normal',
        'firmware-version'       => '1.08.04.00'
    },
);

plan tests =>
    (scalar keys %showrev_tests) +
    (scalar keys %smbios_tests)  +
    (scalar keys %prtconf_tests) +
    1;

foreach my $test (keys %showrev_tests) {
    my $file   = "resources/solaris/showrev/$test";
    my $result = FusionInventory::Agent::Task::Inventory::Solaris::Bios::_parseShowRev(file => $file);
    cmp_deeply($result, $showrev_tests{$test}, "showrev parsing: $test");
}

foreach my $test (keys %smbios_tests) {
    my $file   = "resources/solaris/smbios/$test";
    my $result = FusionInventory::Agent::Task::Inventory::Solaris::Bios::_parseSmbios(file => $file);
    cmp_deeply($result, $smbios_tests{$test}, "smbios parsing: $test");
}

foreach my $test (keys %prtconf_tests) {
    my $file   = "resources/solaris/prtconf/$test";
    my $result = FusionInventory::Agent::Task::Inventory::Solaris::Bios::_parsePrtconf(file => $file);
    cmp_deeply($result, $prtconf_tests{$test}, "prtconf parsing: $test");
}
