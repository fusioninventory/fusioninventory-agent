#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Tools::Solaris;

my %prtconf_tests = (
    sparc1 => {
        'System Configuration' => 'Sun Microsystems  sun4u',
        'Memory size' => '16384 Megabyte',
        '0xf0819f00' => {
            'compatible' => 'SUNW,Serengeti',
            '#size-cells' => '00000002',
            'banner-name' => 'Sun Fire E6900',
            'name' => 'SUNW,Sun-Fire',
            'newio-addr' => '00000001',
            'node#' => '00000000',
            'idprom' => '01840014.4f4162cb.45255cf4.4162cb16.55555555.55555555.55555555.55555555',
            'stick-frequency' => '00bebc20',
            'clock-frequency' => '08f0d180',
            'breakpoint-trap' => '0000007f',
            'device_type' => 'gptwo',
            'scsi-initiator-id' => '00000007'
        }
    },
    sparc2 => {
        'System Configuration' => 'Sun Microsystems  sun4u',
        'Memory size' => '32768 Megabytes',
        '0xf00298fc' => {
            'banner-name' => 'Sun Fire V890',
            'model' => 'SUNW,501-7199',
            '0xf007c538' => {
                'compatible' => [
                    'SUNW,UltraSPARC-III,mc',
                    'SUNW,mc'
                ],
                'device_type' => 'memory-controller',
                'reg' => '00000400.02400000.00000000.00000048',
                'name' => 'memory-controller',
                'portid' => '00000004',
                'memory-layout' => '4a323930.30000000.4a323930.31000000.4a333030.31000000.4a333030.30000000.4a333130.30000000.4a333130.31000000.4a333230.31000000.4a333230.30000000.01aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.5556ca6f.e3207607.997bbb25.7bca2a6a.564cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.854cc051.c560d465.d96ade5b.cf2a9e47.02760720.94168a1b.8f0c8011.854cc051.c560d465.d95bcfde.6fe39e47.bb029425.99168a1b.8f0c8011.854cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.8557cb70.e4217708.9a7cbc26.7ccb2b6b.574dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.864dc152.c661d566.da6bdf5c.d02b9f48.03770821.95178b1c.900d8112.864dc152.c661d566.da5cd0df.70e49f48.bc039526.9a178b1c.900d8112.864dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.8658cc71.e5227809.9b7dbd27.7dcc2c6c.584ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.874ec253.c762d667.db6ce05d.d12ca049.04780922.96188c1d.910e8213.874ec253.c762d667.db5dd1e0.71e5a049.bd049627.9b188c1d.910e8213.874ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.8759cd72.e623790a.9c7ebe28.7ecd2d6d.594fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.884fc354.c863d768.dc6de15e.d22da14a.05790a23.97198d1e.920f8314.884fc354.c863d768.dc5ed2e1.72e6a14a.be059728.9c198d1e.920f8314.884fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.88'
            },
            'stick-frequency' => '00989680',
            'idprom' => '01830003.bace77fb.07232005.ce77fb3a.00000000.00000000.00000000.00000000',
            '0xf007b2d4' => {
                'reg' => '00000400.01800000.00000000.00010000',
                '#address-cells' => '00000001',
                '#size-cells' => '00000000',
                '0xf007b7d8' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000002',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000001',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000013',
                    'mask#' => '00000031'
                },
                '0xf007b480' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000001',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000000',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000003',
                    'mask#' => '00000031'
                },
                'name' => 'cmp',
                'portid' => '00000003'
            },
            '0xf007bb68' => {
                'compatible' => [
                    'SUNW,UltraSPARC-III,mc',
                    'SUNW,mc'
                ],
                'device_type' => 'memory-controller',
                'reg' => '00000400.01c00000.00000000.00000048',
                'name' => 'memory-controller',
                'portid' => '00000003',
                'memory-layout' => '4a373930.30000000.4a373930.31000000.4a383030.31000000.4a383030.30000000.4a383130.30000000.4a383130.31000000.4a383230.31000000.4a383230.30000000.01aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.5556ca6f.e3207607.997bbb25.7bca2a6a.564cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.854cc051.c560d465.d96ade5b.cf2a9e47.02760720.94168a1b.8f0c8011.854cc051.c560d465.d95bcfde.6fe39e47.bb029425.99168a1b.8f0c8011.854cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.8557cb70.e4217708.9a7cbc26.7ccb2b6b.574dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.864dc152.c661d566.da6bdf5c.d02b9f48.03770821.95178b1c.900d8112.864dc152.c661d566.da5cd0df.70e49f48.bc039526.9a178b1c.900d8112.864dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.8658cc71.e5227809.9b7dbd27.7dcc2c6c.584ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.874ec253.c762d667.db6ce05d.d12ca049.04780922.96188c1d.910e8213.874ec253.c762d667.db5dd1e0.71e5a049.bd049627.9b188c1d.910e8213.874ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.8759cd72.e623790a.9c7ebe28.7ecd2d6d.594fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.884fc354.c863d768.dc6de15e.d22da14a.05790a23.97198d1e.920f8314.884fc354.c863d768.dc5ed2e1.72e6a14a.be059728.9c198d1e.920f8314.884fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.88'
            },
            'device_type' => 'gptwo',
            'breakpoint-trap' => '0000007f',
            'scsi-initiator-id' => '00000007',
            'reset-reason' => 'SPOR Software/User',
            '0xf0086fe4' => {
                'compatible' => 'pci108e,8001',
                'implementation#' => '0000002b',
                '#interrupt-cells' => '00000001',
                'version#' => '00000007',
                '0xf00cba14' => {
                    'vendor-id' => '0000108e',
                    'min-grant' => '00000040',
                    'local-mac-address' => '0003bace.77fc',
                    'compatible' => [
                        'pci108e,2bad.1',
                        'pci108e,2bad',
                        'pciclass,020000',
                        'pciclass,0200'
                    ],
                    'cache-line-size' => '00000010',
                    'max-frame-size' => '00004000',
                    'address-bits' => '00000030',
                    'revision-id' => '00000001',
                    'model' => 'SUNW,pci-gem',
                    'assigned-addresses' => '82000810.00000000.00200000.00000000.00200000.82000830.00000000.00100000.00000000.00100000',
                    'device-id' => '00002bad',
                    'max-latency' => '00000040',
                    'device_type' => 'network',
                    'interrupts' => '00000001',
                    'shared-pins' => 'serdes',
                    'board-rev' => '00000006',
                    'version' => '1.12 ',
                    'name' => 'network',
                    'class-code' => '00020000',
                    'latency-timer' => '00000040',
                    'reg' => '00000800.00000000.00000000.00000000.00000000.02000810.00000000.00000000.00000000.00009060',
                    'devsel-speed' => '00000002',
                    'has-fcode' => ' ',
                    'gem-rev' => '00000001'
                },
                'ranges' => '00000000.00000000.00000000.000007ff.ec000000.00000000.01000000.01000000.00000000.00000000.000007ff.ed000000.00000000.01000000.02000000.00000000.00000000.000007fd.00000000.00000001.00000000.03000000.00000000.00000000.000007fd.00000000.00000001.00000000',
                'interrupt-map' => '00000800.00000000.00000000.00000001.f0086fe4.00000000.00001000.00000000.00000000.00000001.f0086fe4.00000004',
                '#address-cells' => '00000003',
                'device_type' => 'pci',
                'interrupts' => '00000032.00000030.00000031.00000034',
                '0xf00d2364' => {
                    'vendor-id' => '00001077',
                    'min-grant' => '00000040',
                    'compatible' => [
                        'pci1077,2200.5',
                        'pci1077,2200',
                        'pciclass,010000',
                        'pciclass,0100'
                    ],
                    'cache-line-size' => '00000010',
                    'port-wwn' => '21000003.bace77fb',
                    'revision-id' => '00000005',
                    'assigned-addresses' => '81001010.00000000.00000300.00000000.00000100.82001014.00000000.00400000.00000000.00002000.82001030.00000000.00420000.00000000.00020000',
                    'device-id' => '00002200',
                    'max-latency' => '00000000',
                    'device_type' => 'scsi-fcp',
                    '#address-cells' => '00000002',
                    'interrupts' => '00000001',
                    '#size-cells' => '00000000',
                    'version' => 'ISP2200 FC-AL Host Adapter Driver: 1.14 01/11/20',
                    'name' => 'SUNW,qlc',
                    'class-code' => '00010000',
                    'latency-timer' => '00000040',
                    'reg' => '00001000.00000000.00000000.00000000.00000000.01001010.00000000.00000000.00000000.00000100.02001014.00000000.00000000.00000000.00001000',
                    'devsel-speed' => '00000001',
                    'manufacturer' => 'QLGC',
                    '0xf00d6f34' => {
                        '0xf00d7630' => {
                            'compatible' => 'ssd',
                            'device_type' => 'block',
                            'name' => 'disk'
                        },
                        'device_type' => 'fp',
                        'reg' => '00000000.00000000',
                        '#address-cells' => '00000004',
                        '#size-cells' => '00000000',
                        'name' => 'fp'
                    },
                    'node-wwn' => '20000003.bace77fb'
                },
                'bus-range' => '00000000.00000000',
                'no-probe-list' => '0',
                'available' => '81000000.00000000.00000400.00000000.0000fc00.82000000.00000000.00402000.00000000.0001e000.82000000.00000000.00440000.00000000.7ebc0000',
                '#size-cells' => '00000002',
                'name' => 'pci',
                'clock-frequency' => '03ef1480',
                'reg' => '00000400.04600000.00000000.00018000.00000400.04410000.00000000.00000050.000007ff.ec000000.00000000.00000100',
                'ino-bitmap' => '0000001f.00170081',
                'portid' => '00000008',
                'interrupt-map-mask' => '00fff800.00000000.00000000.00000007'
            },
            '0xf002ccc4' => {
                'boot-command' => 'boot',
                'use-nvramrc?' => 'false',
                'load-base' => '16384',
                'ttya-ignore-cd' => 'true',
                'screen-#rows' => '34',
                'oem-logo?' => 'false',
                'service-mode?' => 'false',
                'security-#badlogins' => '0',
                'auto-boot?' => 'true',
                'auto-boot-on-error?' => 'true',
                'scsi-initiator-id' => '7',
                'error-reset-recovery' => 'sync',
                'name' => 'options',
                'local-mac-address?' => 'false',
                'diag-passes' => '1',
                'screen-#columns' => '80',
                'ansi-terminal?' => 'true',
                'ttyb-ignore-cd' => 'true',
                'ttya-rts-dtr-off' => 'false',
                'input-device' => 'rsc-console',
                'oem-banner?' => 'false',
                'diag-script' => 'none',
                'diag-switch?' => 'false',
                'diag-trigger' => 'none',
                'fcode-debug?' => 'false',
                'diag-level' => 'off',
                'boot-device' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@w21000014c34173c0,0:a',
                'verbosity' => 'normal',
                'diag-device' => 'net',
                'ttya-mode' => '9600,8,n,1,-',
                'ttyb-mode' => '9600,8,n,1,-',
                'ttyb-rts-dtr-off' => 'false',
                'security-mode' => 'none',
                'output-device' => 'rsc-console',
                'diag-out-console' => 'true'
            },
            '0xf007bca4' => {
                'reg' => '00000400.02000000.00000000.00010000',
                '#address-cells' => '00000001',
                '#size-cells' => '00000000',
                '0xf007be50' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000001',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000000',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000004',
                    'mask#' => '00000031'
                },
                '0xf007c1a8' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000002',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000001',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000014',
                    'mask#' => '00000031'
                },
                'name' => 'cmp',
                'portid' => '00000004'
            },
            '#size-cells' => '00000002',
            '0xf007da14' => {
                '0xf007dbc0' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000001',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000000',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000007',
                    'mask#' => '00000031'
                },
                'reg' => '00000400.03800000.00000000.00010000',
                '#address-cells' => '00000001',
                '#size-cells' => '00000000',
                '0xf007df18' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000002',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000001',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000017',
                    'mask#' => '00000031'
                },
                'name' => 'cmp',
                'portid' => '00000007'
            },
            'name' => 'SUNW,Sun-Fire-V890',
            '0xf002cb7c' => {
                'version' => 'OBP 4.15.6 2005/01/06 04:25',
                'name' => 'openprom',
                'model' => 'SUNW,4.15.6',
                '0xf002cc0c' => {
                    'name' => 'client-services'
                }
            },
            '0xf007e2a8' => {
                'compatible' => [
                    'SUNW,UltraSPARC-III,mc',
                    'SUNW,mc'
                ],
                'device_type' => 'memory-controller',
                'reg' => '00000400.03c00000.00000000.00000048',
                'name' => 'memory-controller',
                'portid' => '00000007',
                'memory-layout' => '4a373930.30000000.4a373930.31000000.4a383030.31000000.4a383030.30000000.4a383130.30000000.4a383130.31000000.4a383230.31000000.4a383230.30000000.01aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.5556ca6f.e3207607.997bbb25.7bca2a6a.564cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.854cc051.c560d465.d96ade5b.cf2a9e47.02760720.94168a1b.8f0c8011.854cc051.c560d465.d95bcfde.6fe39e47.bb029425.99168a1b.8f0c8011.854cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.8557cb70.e4217708.9a7cbc26.7ccb2b6b.574dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.864dc152.c661d566.da6bdf5c.d02b9f48.03770821.95178b1c.900d8112.864dc152.c661d566.da5cd0df.70e49f48.bc039526.9a178b1c.900d8112.864dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.8658cc71.e5227809.9b7dbd27.7dcc2c6c.584ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.874ec253.c762d667.db6ce05d.d12ca049.04780922.96188c1d.910e8213.874ec253.c762d667.db5dd1e0.71e5a049.bd049627.9b188c1d.910e8213.874ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.8759cd72.e623790a.9c7ebe28.7ecd2d6d.594fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.884fc354.c863d768.dc6de15e.d22da14a.05790a23.97198d1e.920f8314.884fc354.c863d768.dc5ed2e1.72e6a14a.be059728.9c198d1e.920f8314.884fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.88'
            },
            '0xf007d044' => {
                '0xf007d1f0' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000001',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000000',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000006',
                    'mask#' => '00000031'
                },
                'reg' => '00000400.03000000.00000000.00010000',
                '#address-cells' => '00000001',
                '#size-cells' => '00000000',
                'name' => 'cmp',
                'portid' => '00000006',
                '0xf007d548' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000002',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000001',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000016',
                    'mask#' => '00000031'
                }
            },
            'clock-frequency' => '08f0d180',
            '0xf0079df8' => {
                'compatible' => [
                    'SUNW,UltraSPARC-III,mc',
                    'SUNW,mc'
                ],
                'device_type' => 'memory-controller',
                'reg' => '00000400.00400000.00000000.00000048',
                'name' => 'memory-controller',
                'portid' => '00000000',
                'memory-layout' => '4a323930.30000000.4a323930.31000000.4a333030.31000000.4a333030.30000000.4a333130.30000000.4a333130.31000000.4a333230.31000000.4a333230.30000000.01aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.5556ca6f.e3207607.997bbb25.7bca2a6a.564cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.854cc051.c560d465.d96ade5b.cf2a9e47.02760720.94168a1b.8f0c8011.854cc051.c560d465.d95bcfde.6fe39e47.bb029425.99168a1b.8f0c8011.854cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.8557cb70.e4217708.9a7cbc26.7ccb2b6b.574dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.864dc152.c661d566.da6bdf5c.d02b9f48.03770821.95178b1c.900d8112.864dc152.c661d566.da5cd0df.70e49f48.bc039526.9a178b1c.900d8112.864dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.8658cc71.e5227809.9b7dbd27.7dcc2c6c.584ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.874ec253.c762d667.db6ce05d.d12ca049.04780922.96188c1d.910e8213.874ec253.c762d667.db5dd1e0.71e5a049.bd049627.9b188c1d.910e8213.874ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.8759cd72.e623790a.9c7ebe28.7ecd2d6d.594fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.884fc354.c863d768.dc6de15e.d22da14a.05790a23.97198d1e.920f8314.884fc354.c863d768.dc5ed2e1.72e6a14a.be059728.9c198d1e.920f8314.884fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.88'
            },
            '0xf01349c4' => {
                'device_type' => 'console',
                'name' => 'os-io'
            },
            '0xf008e2c4' => {
                'compatible' => 'pci108e,8001',
                '0xf011a40c' => {
                    'min-grant' => '00000008',
                    'cache-line-size' => '00000010',
                    'aty,refclk' => '00006978',
                    'model' => 'SUNW,375-3181',
                    'assigned-addresses' => 'c2001810.00000000.08000000.00000000.08000000.81001814.00000000.00000300.00000000.00000100.82001818.00000000.00130000.00000000.00010000.82001830.00000000.00140000.00000000.00020000',
                    'device-id' => '00005159',
                    'linebytes' => '00000500',
                    'device_type' => 'display',
                    'aty,fcode' => '1.86',
                    'name' => 'SUNW,XVR-100',
                    'subsystem-vendor-id' => '00001002',
                    'depth' => '00000008',
                    'latency-timer' => '00000040',
                    'class-code' => '00030000',
                    'aty,card#' => '102-85514-00',
                    'width' => '00000480',
                    'vendor-id' => '00001002',
                    'aty,rom#' => '113-85514-101',
                    'aty,flags' => '00000080',
                    'fcode-rom-offset' => '00000000',
                    'revision-id' => '00000000',
                    'aty,sclk' => '000249f0',
                    'max-latency' => '00000000',
                    'display-type' => 'NONE',
                    'interrupts' => '00000001',
                    'character-set' => 'ISO8859-1',
                    'version' => '@(#)xvr100.fth 2.3 03/10/17 SMI ',
                    'aty,mclk' => '000249f0',
                    'height' => '00000384',
                    'subsystem-id' => '00000908',
                    'reg' => '00001800.00000000.00000000.00000000.00000000.02001810.00000000.00000000.00000000.04000000.02001814.00000000.00000000.00000000.00000100.02001818.00000000.00000000.00000000.00008000.02001830.00000000.00000000.00000000.00020000',
                    'devsel-speed' => '00000001'
                },
                'implementation#' => '0000002b',
                '#interrupt-cells' => '00000001',
                'version#' => '00000007',
                'ranges' => '00000000.00000000.00000000.000007ff.ea000000.00000000.01000000.01000000.00000000.00000000.000007ff.eb000000.00000000.01000000.02000000.00000000.00000000.000007fc.00000000.00000001.00000000.03000000.00000000.00000000.000007fc.00000000.00000001.00000000',
                'interrupt-map' => '00000800.00000000.00000000.00000002.f008e2c4.0000001d.00000800.00000000.00000000.00000003.f008e2c4.0000001e.00000800.00000000.00000000.00000004.f008e2c4.0000001f.00001000.00000000.00000000.00000001.f008e2c4.0000000c.00001000.00000000.00000000.00000002.f008e2c4.0000000d.00001000.00000000.00000000.00000003.f008e2c4.0000000e.00001000.00000000.00000000.00000004.f008e2c4.0000000f.00001800.00000000.00000000.00000001.f008e2c4.00000010.00001800.00000000.00000000.00000002.f008e2c4.00000011.00001800.00000000.00000000.00000003.f008e2c4.00000012.00001800.00000000.00000000.00000004.f008e2c4.00000013.00002000.00000000.00000000.00000001.f008e2c4.00000014.00002000.00000000.00000000.00000002.f008e2c4.00000015.00002000.00000000.00000000.00000003.f008e2c4.00000016.00002000.00000000.00000000.00000004.f008e2c4.00000017',
                '#address-cells' => '00000003',
                'device_type' => 'pci',
                'interrupts' => '00000033.00000030.00000031.00000034',
                'bus-range' => '00000000.00000000',
                'no-probe-list' => '0',
                'available' => '81000000.00000000.00000400.00000000.0000fc00.82000000.00000000.00124000.00000000.0000c000.82000000.00000000.00160000.00000000.002a0000.82000000.00000000.02000000.00000000.06000000.82000000.00000000.10000000.00000000.6c000000',
                '0xf0114204' => {
                    'vendor-id' => '0000108e',
                    'min-grant' => '0000000a',
                    'compatible' => [
                        'pci108e,1103.1',
                        'pci108e,1103',
                        'pciclass,0c0310',
                        'pciclass,0c03'
                    ],
                    'cache-line-size' => '00000010',
                    'revision-id' => '00000001',
                    'assigned-addresses' => '82000b10.00000000.01000000.00000000.01000000.82000b30.00000000.00c00000.00000000.00400000',
                    'device-id' => '00001103',
                    'sunw,find-fcode' => 'f011955c',
                    'max-latency' => '00000005',
                    '#address-cells' => '00000001',
                    'interrupts' => '00000004',
                    '#size-cells' => '00000000',
                    'name' => 'usb',
                    'maximum-frame#' => '0000ffff',
                    'class-code' => '000c0310',
                    'latency-timer' => '00000040',
                    'devsel-speed' => '00000001',
                    'reg' => '00000b00.00000000.00000000.00000000.00000000.02000b10.00000000.00000000.00000000.01000000'
                },
                '0xf00a4934' => {
                    '0xf00c3e90' => {
                        'compatible' => [
                            'rsc-control',
                            'su16550',
                            'su'
                        ],
                        'device_type' => 'serial',
                        'reg' => '00000001.003062f8.00000008',
                        'interrupts' => '00000001',
                        'name' => 'rsc-control'
                    },
                    'vendor-id' => '0000108e',
                    'min-grant' => '0000000a',
                    '0xf00c3cdc' => {
                        'compatible' => 'ns87317-pmc',
                        'reg' => '00000001.00300700.00000002',
                        'name' => 'pmc',
                        'address' => 'fff3e700'
                    },
                    '0xf00c5678' => {
                        'compatible' => [
                            'rsc-console',
                            'su16550',
                            'su'
                        ],
                        'device_type' => 'serial',
                        'reg' => '00000001.003083f8.00000008',
                        'interrupts' => '00000001',
                        'name' => 'rsc-console'
                    },
                    '0xf00c3164' => {
                        'compatible' => 'ds1287',
                        'reg' => '00000001.00300070.00000002',
                        'interrupts' => '00000001',
                        'name' => 'rtc',
                        'model' => 'ds1287',
                        'address' => 'fff52070'
                    },
                    '#interrupt-cells' => '00000001',
                    'revision-id' => '00000001',
                    '0xf00c6e60' => {
                        'compatible' => [
                            'sab82532',
                            'se'
                        ],
                        'device_type' => 'serial',
                        'reg' => '00000001.00400000.00000080',
                        'interrupts' => '00000001',
                        'name' => 'serial'
                    },
                    'device-id' => '00001100',
                    'ranges' => '00000000.00000000.82000810.00000000.7d000000.01000000.00000001.00000000.82000814.00000000.7e000000.00800000',
                    'max-latency' => '00000019',
                    'interrupt-map' => '00000001.0000002e.00000001.f008e2c4.00000023.00000001.00000030.00000001.f008e2c4.00000023.00000001.0050002e.00000001.f008e2c4.00000028.00000001.00500030.00000001.f008e2c4.00000028.00000001.00300070.00000001.f008e2c4.00000024.00000001.003062f8.00000001.f008e2c4.0000002e.00000001.003083f8.00000001.f008e2c4.0000002d.00000001.00400000.00000001.f008e2c4.00000022',
                    '#address-cells' => '00000002',
                    '0xf00a6c28' => {
                        'reg' => '00000001.00000000.00100000',
                        'name' => 'bbc'
                    },
                    '0xf00afaa8' => {
                        'compatible' => 'SUNW,bbc-i2c',
                        '0xf00b441c' => {
                            'compatible' => 'i2c-pcf8591',
                            'reg' => '00000000.00000090',
                            'name' => 'adio'
                        },
                        '0xf00b3eac' => {
                            'compatible' => 'i2c-ssc050',
                            'reg' => '00000000.00000082',
                            'name' => 'ioexp'
                        },
                        '0xf00b2f04' => {
                            'compatible' => 'i2c-pcf8574',
                            'reg' => '00000000.00000046',
                            'name' => 'ioexp'
                        },
                        '0xf00b297c' => {
                            'compatible' => 'i2c-max1617',
                            'reg' => '00000000.00000030',
                            'name' => 'temperature'
                        },
                        '#interrupt-cells' => '00000001',
                        '0xf00b272c' => {
                            'compatible' => 'i2c-ssc100',
                            'reg' => '00000000.00000016',
                            'name' => 'controller'
                        },
                        'interrupt-map' => '00000000.000000e2.00000001.f00a4934.00000027.00000000.000000e6.00000001.f00a4934.00000027.00000000.000000e8.00000001.f00a4934.00000027.00000000.000000ec.00000001.f00a4934.00000026',
                        '0xf00b5ae8' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a8',
                            'name' => 'fru'
                        },
                        '#address-cells' => '00000002',
                        '0xf00b3974' => {
                            'compatible' => 'i2c-pcf8574',
                            'reg' => '00000000.00000072',
                            'name' => 'ioexp'
                        },
                        '0xf00b4938' => {
                            'compatible' => 'i2c-pcf8591',
                            'reg' => '00000000.00000096',
                            'name' => 'adio'
                        },
                        '0xf00b5d8c' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000ae',
                            'name' => 'fru'
                        },
                        '0xf00b60f0' => {
                            'compatible' => 'i2c-hpc3130',
                            'reg' => '00000000.000000e2',
                            'interrupts' => '00000001',
                            'name' => 'hotplug-controller',
                            'slot-table' => '2f706369.40392c36.30303030.30003100.32002f70.63694039.2c363030.30303000.30003100'
                        },
                        '0xf00b55a0' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a4',
                            'name' => 'fru'
                        },
                        '#size-cells' => '00000000',
                        '0xf00b6030' => {
                            'compatible' => 'i2c-ds1307',
                            'reg' => '00000000.000000d0',
                            'name' => 'rscrtc'
                        },
                        'name' => 'i2c',
                        '0xf00b4cc4' => {
                            'compatible' => 'i2c-max1617',
                            'reg' => '00000000.0000009a',
                            'name' => 'temperature'
                        },
                        '0xf00b5058' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a0',
                            'name' => 'fru'
                        },
                        'interrupt-map-mask' => '0000001f.000fffff.00000003',
                        '0xf00b407c' => {
                            'compatible' => 'i2c-ssc050',
                            'reg' => '00000000.00000088',
                            'name' => 'ioexp'
                        },
                        '0xf00b3b28' => {
                            'compatible' => 'i2c-pcf8574',
                            'reg' => '00000000.00000074',
                            'name' => 'ioexp'
                        },
                        '0xf00b3700' => {
                            'compatible' => 'i2c-ltc1427',
                            'reg' => '00000000.0000005e',
                            'name' => 'adio'
                        },
                        '0xf00b666c' => {
                            'compatible' => 'i2c-hpc3130',
                            'reg' => '00000000.000000e6',
                            'interrupts' => '00000001',
                            'name' => 'hotplug-controller',
                            'slot-table' => '2f706369.40382c37.30303030.30003300.35002f70.63694038.2c373030.30303000.32003400.2f706369.40382c37.30303030.30003100.33002f70.63694038.2c373030.30303000.30003200'
                        },
                        '0xf00b3640' => {
                            'compatible' => 'i2c-ltc1427',
                            'reg' => '00000000.0000005a',
                            'name' => 'adio'
                        },
                        '0xf00b4784' => {
                            'compatible' => 'i2c-pcf8591',
                            'reg' => '00000000.00000094',
                            'name' => 'adio'
                        },
                        '0xf00b2d2c' => {
                            'compatible' => 'i2c-max1617',
                            'reg' => '00000000.00000034',
                            'name' => 'temperature'
                        },
                        '0xf00b45d0' => {
                            'compatible' => 'i2c-pcf8591',
                            'reg' => '00000000.00000092',
                            'name' => 'adio'
                        },
                        '0xf00b30b8' => {
                            'compatible' => 'i2c-max1617',
                            'reg' => '00000000.00000052',
                            'name' => 'temperature'
                        },
                        '0xf00b5844' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a6',
                            'name' => 'fru'
                        },
                        '0xf00b4e9c' => {
                            'compatible' => 'i2c-lm75',
                            'reg' => '00000000.0000009c',
                            'name' => 'temperature-sensor'
                        },
                        '0xf00b28b8' => {
                            'compatible' => 'i2c-ssc100',
                            'reg' => '00000000.0000001a',
                            'name' => 'controller'
                        },
                        'interrupts' => '00000001',
                        '0xf00b52fc' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a2',
                            'name' => 'fru'
                        },
                        '0xf00b3290' => {
                            'compatible' => 'i2c-max1617',
                            'reg' => '00000000.00000054',
                            'name' => 'temperature'
                        },
                        '0xf00b719c' => {
                            'compatible' => 'i2c-hpc3130',
                            'reg' => '00000000.000000ec',
                            'interrupts' => '00000001',
                            'name' => 'hotplug-controller',
                            'slot-table' => '2f707365.75646f2f.67707477.6f403000.30003000.2f707365.75646f2f.67707477.6f403000.31003100.2f707365.75646f2f.67707477.6f403000.32003200.2f707365.75646f2f.67707477.6f403000.33003300'
                        },
                        '0xf00b37c0' => {
                            'compatible' => 'i2c-pcf8574',
                            'reg' => '00000000.00000070',
                            'name' => 'ioexp'
                        },
                        '0xf00b2b54' => {
                            'compatible' => 'i2c-max1617',
                            'reg' => '00000000.00000032',
                            'name' => 'temperature'
                        },
                        '0xf00b3468' => {
                            'compatible' => 'i2c-max1617',
                            'reg' => '00000000.00000056',
                            'name' => 'temperature'
                        },
                        '0xf00b424c' => {
                            'compatible' => 'i2c-ssc050',
                            'reg' => '00000000.0000008a',
                            'name' => 'ioexp'
                        },
                        '0xf00b6c0c' => {
                            'compatible' => 'i2c-hpc3130',
                            'reg' => '00000000.000000e8',
                            'interrupts' => '00000001',
                            'name' => 'hotplug-controller',
                            'slot-table' => '2f706369.40392c37.30303030.30003200.34002f70.63694039.2c373030.30303000.31003300.2f706369.40392c37.30303030.30003000.3200'
                        },
                        'reg' => '00000001.00000030.00000002',
                        '0xf00b3cdc' => {
                            'compatible' => 'i2c-ssc050',
                            'reg' => '00000000.00000080',
                            'name' => 'ioexp'
                        },
                        '0xf00b27f0' => {
                            'compatible' => 'i2c-smbus-ara',
                            'reg' => '00000000.00000018',
                            'name' => 'smbus-ara'
                        },
                        '0xf00b4aec' => {
                            'compatible' => 'i2c-max1617',
                            'reg' => '00000000.00000098',
                            'name' => 'temperature'
                        }
                    },
                    '0xf00a6cc0' => {
                        'compatible' => [
                            'SUNW,bbc-power',
                            'ebus-power'
                        ],
                        'reg' => '00000001.0030002e.00000002.00000001.00300600.00000008',
                        'name' => 'power'
                    },
                    '#size-cells' => '00000001',
                    '0xf00b77b0' => {
                        'reg' => '00000001.00500000.00100000',
                        'name' => 'bbc'
                    },
                    'name' => 'ebus',
                    '0xf00b7848' => {
                        '0xf00bc170' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000a6',
                            'name' => 'fru'
                        },
                        'compatible' => 'SUNW,bbc-i2c',
                        '0xf00bd3ec' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000a4',
                            'name' => 'fru'
                        },
                        '0xf00bbecc' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000a4',
                            'name' => 'fru'
                        },
                        '#interrupt-cells' => '00000001',
                        '0xf00bf8e4' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000004.000000a4',
                            'name' => 'fru'
                        },
                        '0xf00bcea4' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000a0',
                            'name' => 'fru'
                        },
                        '0xf00bf39c' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000ac',
                            'name' => 'fru'
                        },
                        '#address-cells' => '00000002',
                        '0xf00bc6b8' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000aa',
                            'name' => 'fru'
                        },
                        '0xf00bde7c' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000ac',
                            'name' => 'fru'
                        },
                        '0xf00bc95c' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000ac',
                            'name' => 'fru'
                        },
                        '#size-cells' => '00000000',
                        'name' => 'i2c',
                        '0xf00bf640' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000ae',
                            'name' => 'fru'
                        },
                        '0xf00bf0f8' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000aa',
                            'name' => 'fru'
                        },
                        '0xf00be120' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000ae',
                            'name' => 'fru'
                        },
                        '0xf00bd934' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000a8',
                            'name' => 'fru'
                        },
                        '0xf00bd148' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000a2',
                            'name' => 'fru'
                        },
                        'interrupt-map-mask' => '0000001f.000fffff.00000003',
                        '0xf00bd690' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000a6',
                            'name' => 'fru'
                        },
                        '0xf00bcc00' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000ae',
                            'name' => 'fru'
                        },
                        '0xf00ba708' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a2',
                            'name' => 'fru'
                        },
                        '0xf00bac50' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a6',
                            'name' => 'fru'
                        },
                        '0xf00bfb88' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000004.000000a6',
                            'name' => 'fru'
                        },
                        '0xf00bb984' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000a0',
                            'name' => 'fru'
                        },
                        '0xf00ba464' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a0',
                            'name' => 'fru'
                        },
                        '0xf00be668' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000a2',
                            'name' => 'fru'
                        },
                        'interrupts' => '00000001',
                        '0xf00bee54' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000a8',
                            'name' => 'fru'
                        },
                        '0xf00baef4' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a8',
                            'name' => 'fru'
                        },
                        '0xf00bb6e0' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000ae',
                            'name' => 'fru'
                        },
                        '0xf00bdbd8' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000aa',
                            'name' => 'fru'
                        },
                        '0xf00bebb0' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000a6',
                            'name' => 'fru'
                        },
                        '0xf00ba9ac' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a4',
                            'name' => 'fru'
                        },
                        '0xf00bc414' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000a8',
                            'name' => 'fru'
                        },
                        '0xf00bb198' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000aa',
                            'name' => 'fru'
                        },
                        '0xf00bbc28' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000a2',
                            'name' => 'fru'
                        },
                        '0xf00be90c' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000a4',
                            'name' => 'fru'
                        },
                        'reg' => '00000001.0050002e.00000002.00000001.0050002d.00000001',
                        '0xf00be3c4' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000a0',
                            'name' => 'fru'
                        },
                        '0xf00bb43c' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000ac',
                            'name' => 'fru'
                        }
                    },
                    'class-code' => '00068000',
                    '0xf00c3a04' => {
                        'compatible' => 'ns87317-gpio',
                        'reg' => '00000001.00300600.00000008',
                        'name' => 'gpio'
                    },
                    'reg' => '00000800.00000000.00000000.00000000.00000000.02000810.00000000.00000000.00000000.01000000.02000814.00000000.00000000.00000000.00800000',
                    'devsel-speed' => '00000001',
                    '0xf00bfe98' => {
                        'compatible' => 'SUNW,bbc-i2c',
                        '#size-cells' => '00000000',
                        '#interrupt-cells' => '00000001',
                        '0xf00c2aa8' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'nvram',
                            'reg' => '00000000.000000a0',
                            'name' => 'nvram'
                        },
                        'name' => 'i2c',
                        '0xf00c2e7c' => {
                            'reg' => '00000000.000000a0',
                            'device_type' => 'idprom',
                            'name' => 'idprom'
                        },
                        'reg' => '00000001.00500030.00000002',
                        '#address-cells' => '00000002',
                        'interrupts' => '00000001',
                        'interrupt-map-mask' => '0000001f.000fffff.00000003'
                    },
                    '0xf00a6f10' => {
                        '0xf00ab838' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000a6',
                            'name' => 'fru'
                        },
                        'compatible' => 'SUNW,bbc-i2c',
                        '0xf00ad544' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000ac',
                            'name' => 'fru'
                        },
                        '#interrupt-cells' => '00000001',
                        '0xf00aada8' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000ae',
                            'name' => 'fru'
                        },
                        '0xf00ac024' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000ac',
                            'name' => 'fru'
                        },
                        '0xf00abadc' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000a8',
                            'name' => 'fru'
                        },
                        '#address-cells' => '00000002',
                        '0xf00add30' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000a2',
                            'name' => 'fru'
                        },
                        '0xf00adfd4' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000a4',
                            'name' => 'fru'
                        },
                        '0xf00acffc' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000a8',
                            'name' => 'fru'
                        },
                        '0xf00aa074' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a4',
                            'name' => 'fru'
                        },
                        '0xf00ab04c' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000a0',
                            'name' => 'fru'
                        },
                        '#size-cells' => '00000000',
                        '0xf00af4f4' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000004.000000a8',
                            'name' => 'fru'
                        },
                        '0xf00ada8c' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000a0',
                            'name' => 'fru'
                        },
                        '0xf00a9b2c' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a0',
                            'name' => 'fru'
                        },
                        'name' => 'i2c',
                        '0xf00af798' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000004.000000aa',
                            'name' => 'fru'
                        },
                        '0xf00ac810' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000a2',
                            'name' => 'fru'
                        },
                        '0xf00aa5bc' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a8',
                            'name' => 'fru'
                        },
                        'interrupt-map-mask' => '0000001f.000fffff.00000003',
                        '0xf00aefac' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000004.000000a0',
                            'name' => 'fru'
                        },
                        '0xf00ac56c' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000a0',
                            'name' => 'fru'
                        },
                        '0xf00a9dd0' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a2',
                            'name' => 'fru'
                        },
                        '0xf00acd58' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000a6',
                            'name' => 'fru'
                        },
                        '0xf00ad7e8' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000ae',
                            'name' => 'fru'
                        },
                        '0xf00af250' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000004.000000a2',
                            'name' => 'fru'
                        },
                        '0xf00ae51c' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000a8',
                            'name' => 'fru'
                        },
                        '0xf00ac2c8' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000ae',
                            'name' => 'fru'
                        },
                        '0xf00acab4' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000a4',
                            'name' => 'fru'
                        },
                        'interrupts' => '00000001',
                        '0xf00aa860' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000aa',
                            'name' => 'fru'
                        },
                        '0xf00ab2f0' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000a2',
                            'name' => 'fru'
                        },
                        '0xf00ab594' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000a4',
                            'name' => 'fru'
                        },
                        '0xf00aea64' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000ac',
                            'name' => 'fru'
                        },
                        '0xf00ae7c0' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000aa',
                            'name' => 'fru'
                        },
                        '0xf00abd80' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000001.000000aa',
                            'name' => 'fru'
                        },
                        '0xf00aed08' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000ae',
                            'name' => 'fru'
                        },
                        '0xf00ae278' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000003.000000a6',
                            'name' => 'fru'
                        },
                        '0xf00aa318' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000a6',
                            'name' => 'fru'
                        },
                        'reg' => '00000001.0000002e.00000002.00000001.0000002d.00000001',
                        '0xf00aab04' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000000.000000ac',
                            'name' => 'fru'
                        },
                        '0xf00ad2a0' => {
                            'compatible' => 'i2c-at24c64',
                            'device_type' => 'fru-prom',
                            'reg' => '00000002.000000aa',
                            'name' => 'fru'
                        }
                    },
                    'interrupt-map-mask' => '0000001f.00ffffff.00000003',
                    '0xf00a5fa4' => {
                        'reg' => '00000000.00000000.00200000',
                        'version' => [
                            'OBP 4.15.6 2005/01/06 04:25',
                            'POST 4.15.6 2005/01/06 10:46',
                            'OBDIAG 4.15.6 2005/01/06 04:30  '
                        ],
                        'name' => 'flashprom',
                        'model' => 'SUNW,525-1793'
                    }
                },
                '#size-cells' => '00000002',
                'slot-names' => '0000001c.50434920.36005043.49203500.50434920.3400',
                'name' => 'pci',
                'clock-frequency' => '01f78a40',
                '0xf010be34' => {
                    'vendor-id' => '0000108e',
                    'min-grant' => '0000000a',
                    'local-mac-address' => '0003bace.77fb',
                    'compatible' => [
                        'pci108e,1101.1',
                        'pci108e,1101',
                        'pciclass,020000',
                        'pciclass,0200'
                    ],
                    'cache-line-size' => '00000010',
                    'max-frame-size' => '00004000',
                    'address-bits' => '00000030',
                    'revision-id' => '00000001',
                    'model' => 'SUNW,pci-eri',
                    'assigned-addresses' => '82000910.00000000.00100000.00000000.00020000.82000930.00000000.00400000.00000000.00400000',
                    'device-id' => '00001101',
                    'max-latency' => '00000005',
                    'device_type' => 'network',
                    'interrupts' => '00000002',
                    'shared-pins' => 'mii',
                    'version' => '1.11',
                    'name' => 'network',
                    'class-code' => '00020000',
                    'latency-timer' => '00000040',
                    'reg' => '00000900.00000000.00000000.00000000.00000000.02000910.00000000.00000000.00000000.00008000',
                    'devsel-speed' => '00000001'
                },
                'reg' => '00000400.04f00000.00000000.00018000.00000400.04c10000.00000000.00000050.000007ff.ea000000.00000000.00000100',
                'ino-bitmap' => 'f0fff000.0008617f',
                'portid' => '00000009',
                'interrupt-map-mask' => '00fff800.00000000.00000000.00000007'
            },
            '0xf007b198' => {
                'compatible' => [
                    'SUNW,UltraSPARC-III,mc',
                    'SUNW,mc'
                ],
                'device_type' => 'memory-controller',
                'reg' => '00000400.01400000.00000000.00000048',
                'name' => 'memory-controller',
                'portid' => '00000002',
                'memory-layout' => '4a373930.30000000.4a373930.31000000.4a383030.31000000.4a383030.30000000.4a383130.30000000.4a383130.31000000.4a383230.31000000.4a383230.30000000.01aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.5556ca6f.e3207607.997bbb25.7bca2a6a.564cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.854cc051.c560d465.d96ade5b.cf2a9e47.02760720.94168a1b.8f0c8011.854cc051.c560d465.d95bcfde.6fe39e47.bb029425.99168a1b.8f0c8011.854cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.8557cb70.e4217708.9a7cbc26.7ccb2b6b.574dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.864dc152.c661d566.da6bdf5c.d02b9f48.03770821.95178b1c.900d8112.864dc152.c661d566.da5cd0df.70e49f48.bc039526.9a178b1c.900d8112.864dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.8658cc71.e5227809.9b7dbd27.7dcc2c6c.584ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.874ec253.c762d667.db6ce05d.d12ca049.04780922.96188c1d.910e8213.874ec253.c762d667.db5dd1e0.71e5a049.bd049627.9b188c1d.910e8213.874ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.8759cd72.e623790a.9c7ebe28.7ecd2d6d.594fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.884fc354.c863d768.dc6de15e.d22da14a.05790a23.97198d1e.920f8314.884fc354.c863d768.dc5ed2e1.72e6a14a.be059728.9c198d1e.920f8314.884fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.88'
            },
            '0xf007d8d8' => {
                'compatible' => [
                    'SUNW,UltraSPARC-III,mc',
                    'SUNW,mc'
                ],
                'device_type' => 'memory-controller',
                'reg' => '00000400.03400000.00000000.00000048',
                'name' => 'memory-controller',
                'portid' => '00000006',
                'memory-layout' => '4a373930.30000000.4a373930.31000000.4a383030.31000000.4a383030.30000000.4a383130.30000000.4a383130.31000000.4a383230.31000000.4a383230.30000000.01aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.5556ca6f.e3207607.997bbb25.7bca2a6a.564cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.854cc051.c560d465.d96ade5b.cf2a9e47.02760720.94168a1b.8f0c8011.854cc051.c560d465.d95bcfde.6fe39e47.bb029425.99168a1b.8f0c8011.854cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.8557cb70.e4217708.9a7cbc26.7ccb2b6b.574dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.864dc152.c661d566.da6bdf5c.d02b9f48.03770821.95178b1c.900d8112.864dc152.c661d566.da5cd0df.70e49f48.bc039526.9a178b1c.900d8112.864dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.8658cc71.e5227809.9b7dbd27.7dcc2c6c.584ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.874ec253.c762d667.db6ce05d.d12ca049.04780922.96188c1d.910e8213.874ec253.c762d667.db5dd1e0.71e5a049.bd049627.9b188c1d.910e8213.874ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.8759cd72.e623790a.9c7ebe28.7ecd2d6d.594fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.884fc354.c863d768.dc6de15e.d22da14a.05790a23.97198d1e.920f8314.884fc354.c863d768.dc5ed2e1.72e6a14a.be059728.9c198d1e.920f8314.884fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.88'
            },
            '0xf007a904' => {
                'reg' => '00000400.01000000.00000000.00010000',
                '#address-cells' => '00000001',
                '#size-cells' => '00000000',
                'name' => 'cmp',
                'portid' => '00000002',
                '0xf007ae08' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000002',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000001',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000012',
                    'mask#' => '00000031'
                },
                '0xf007aab0' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000001',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000000',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000002',
                    'mask#' => '00000031'
                }
            },
            '0xf0096a70' => {
                'compatible' => 'pci108e,8001',
                'implementation#' => '0000002b',
                '#interrupt-cells' => '00000001',
                'version#' => '00000007',
                'ranges' => '00000000.00000000.00000000.000007ff.e8000000.00000000.01000000.01000000.00000000.00000000.000007ff.e9000000.00000000.01000000.02000000.00000000.00000000.000007fb.00000000.00000001.00000000.03000000.00000000.00000000.000007fb.00000000.00000001.00000000',
                'interrupt-map' => '00000800.00000000.00000000.00000001.f0096a70.00000000.00000800.00000000.00000000.00000002.f0096a70.00000001.00000800.00000000.00000000.00000003.f0096a70.00000002.00000800.00000000.00000000.00000004.f0096a70.00000003.00001000.00000000.00000000.00000001.f0096a70.00000004.00001000.00000000.00000000.00000002.f0096a70.00000005.00001000.00000000.00000000.00000003.f0096a70.00000006.00001000.00000000.00000000.00000004.f0096a70.00000007',
                '#address-cells' => '00000003',
                'device_type' => 'pci',
                'interrupts' => '00000032.00000030.00000031.00000034',
                'bus-range' => '00000000.00000000',
                'no-probe-list' => '0',
                'available' => '81000000.00000000.00000300.00000000.0000fd00.82000000.00000000.00100000.00000000.7ef00000',
                '#size-cells' => '00000002',
                'slot-names' => '00000006.50434920.38005043.49203700',
                'name' => 'pci',
                'clock-frequency' => '03ef1480',
                'reg' => '00000400.04e00000.00000000.00018000.00000400.04c10000.00000000.00000050.000007ff.e8000000.00000000.00000100',
                'ino-bitmap' => '0000001f.00170080',
                'portid' => '00000009',
                'interrupt-map-mask' => '00fff800.00000000.00000000.00000007'
            },
            '0xf002ca90' => {
                '0xf009e3e4' => {
                    'name' => 'obp-tftp'
                },
                '0xf009d5f4' => {
                    'name' => 'kbd-translator'
                },
                '0xf00684e4' => {
                    'name' => 'SUNW,debug'
                },
                '0xf005ff94' => {
                    'name' => 'disk-label'
                },
                '0xf012b2dc' => {
                    'name' => 'ufs-file-system'
                },
                'name' => 'packages',
                '0xf00a38e8' => {
                    'name' => 'SUNW,i2c-ram-device'
                },
                '0xf00608e8' => {
                    'name' => 'terminal-emulator'
                },
                '0xf005fab0' => {
                    'name' => 'deblocker'
                },
                '0xf012e718' => {
                    'name' => 'hsfs-file-system'
                },
                '0xf00a412c' => {
                    'name' => 'SUNW,fru-device'
                },
                '0xf004c7a0' => {
                    'name' => 'SUNW,builtin-drivers'
                },
                '0xf0068814' => {
                    'source' => '/flashprom:',
                    'name' => 'dropins'
                }
            },
            '0xf007a7c8' => {
                'compatible' => [
                    'SUNW,UltraSPARC-III,mc',
                    'SUNW,mc'
                ],
                'device_type' => 'memory-controller',
                'reg' => '00000400.00c00000.00000000.00000048',
                'name' => 'memory-controller',
                'portid' => '00000001',
                'memory-layout' => '4a323930.30000000.4a323930.31000000.4a333030.31000000.4a333030.30000000.4a333130.30000000.4a333130.31000000.4a333230.31000000.4a333230.30000000.01aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.5556ca6f.e3207607.997bbb25.7bca2a6a.564cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.854cc051.c560d465.d96ade5b.cf2a9e47.02760720.94168a1b.8f0c8011.854cc051.c560d465.d95bcfde.6fe39e47.bb029425.99168a1b.8f0c8011.854cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.8557cb70.e4217708.9a7cbc26.7ccb2b6b.574dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.864dc152.c661d566.da6bdf5c.d02b9f48.03770821.95178b1c.900d8112.864dc152.c661d566.da5cd0df.70e49f48.bc039526.9a178b1c.900d8112.864dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.8658cc71.e5227809.9b7dbd27.7dcc2c6c.584ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.874ec253.c762d667.db6ce05d.d12ca049.04780922.96188c1d.910e8213.874ec253.c762d667.db5dd1e0.71e5a049.bd049627.9b188c1d.910e8213.874ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.8759cd72.e623790a.9c7ebe28.7ecd2d6d.594fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.884fc354.c863d768.dc6de15e.d22da14a.05790a23.97198d1e.920f8314.884fc354.c863d768.dc5ed2e1.72e6a14a.be059728.9c198d1e.920f8314.884fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.88'
            },
            '0xf007e3e4' => {
                'compatible' => 'pci108e,8001',
                'implementation#' => '0000002b',
                '0xf00f3ebc' => {
                    'vendor-id' => '00001000',
                    'min-grant' => '00000010',
                    'compatible' => [
                        'pci1000,30.1000.10c0.8',
                        'pci1000,30.1000.10c0',
                        'pci1000,10c0',
                        'pci1000,30.8',
                        'pci1000,30',
                        'pciclass,010000',
                        'pciclass,0100'
                    ],
                    'cache-line-size' => '00000010',
                    'revision-id' => '00000008',
                    'fcode-rom-offset' => '0000f000',
                    'model' => 'LSI,1030',
                    'assigned-addresses' => '81002810.00000000.00000600.00000000.00000100.83002814.00000000.00180000.00000000.00020000.8300281c.00000000.001a0000.00000000.00020000.82002830.00000000.00400000.00000000.00100000',
                    'device-id' => '00000030',
                    '0xf00fefe0' => {
                        'compatible' => 'st',
                        'device_type' => 'byte',
                        'name' => 'tape'
                    },
                    'max-latency' => '00000006',
                    'device_type' => 'scsi-2',
                    'interrupts' => '00000001',
                    'version' => 'LSI1030 SCSI Host Adapter FCode Driver: 1.11 04/03/18',
                    'name' => 'scsi',
                    'subsystem-vendor-id' => '00001000',
                    'class-code' => '00010000',
                    'latency-timer' => '00000040',
                    '0xf00fe450' => {
                        'compatible' => 'sd',
                        'device_type' => 'block',
                        'name' => 'disk'
                    },
                    'subsystem-id' => '000010c0',
                    'reg' => '00002800.00000000.00000000.00000000.00000000.01002810.00000000.00000000.00000000.00000100.03002814.00000000.00000000.00000000.00020000.0300281c.00000000.00000000.00000000.00020000.02002830.00000000.00000000.00000000.00100000',
                    'devsel-speed' => '00000001'
                },
                '#interrupt-cells' => '00000001',
                'version#' => '00000007',
                'ranges' => '00000000.00000000.00000000.000007ff.ee000000.00000000.01000000.01000000.00000000.00000000.000007ff.ef000000.00000000.01000000.02000000.00000000.00000000.000007fe.00000000.00000001.00000000.03000000.00000000.00000000.000007fe.00000000.00000001.00000000',
                'interrupt-map' => '00000800.00000000.00000000.00000001.f007e3e4.0000001c.00001000.00000000.00000000.00000001.f007e3e4.0000000c.00001000.00000000.00000000.00000002.f007e3e4.0000000d.00001000.00000000.00000000.00000003.f007e3e4.0000000e.00001000.00000000.00000000.00000004.f007e3e4.0000000f.00001800.00000000.00000000.00000001.f007e3e4.00000010.00001800.00000000.00000000.00000002.f007e3e4.00000011.00001800.00000000.00000000.00000003.f007e3e4.00000012.00001800.00000000.00000000.00000004.f007e3e4.00000013.00002000.00000000.00000000.00000001.f007e3e4.00000014.00002000.00000000.00000000.00000002.f007e3e4.00000015.00002000.00000000.00000000.00000003.f007e3e4.00000016.00002000.00000000.00000000.00000004.f007e3e4.00000017.00002800.00000000.00000000.00000001.f007e3e4.00000018.00002800.00000000.00000000.00000002.f007e3e4.00000019.00002800.00000000.00000000.00000003.f007e3e4.0000001a.00002800.00000000.00000000.00000004.f007e3e4.0000001b',
                '#address-cells' => '00000003',
                'device_type' => 'pci',
                'interrupts' => '00000033.00000030.00000031.00000034',
                '0xf00e8040' => {
                    'vendor-id' => '00001000',
                    'min-grant' => '00000010',
                    'compatible' => [
                        'pci1000,30.1000.10c0.8',
                        'pci1000,30.1000.10c0',
                        'pci1000,10c0',
                        'pci1000,30.8',
                        'pci1000,30',
                        'pciclass,010000',
                        'pciclass,0100'
                    ],
                    'cache-line-size' => '00000010',
                    'revision-id' => '00000008',
                    'fcode-rom-offset' => '0000f000',
                    'model' => 'LSI,1030',
                    'assigned-addresses' => '81002110.00000000.00000500.00000000.00000100.83002114.00000000.00140000.00000000.00020000.8300211c.00000000.00160000.00000000.00020000.82002130.00000000.00300000.00000000.00100000',
                    'device-id' => '00000030',
                    'max-latency' => '00000006',
                    'device_type' => 'scsi-2',
                    'interrupts' => '00000002',
                    '0xf00f25d4' => {
                        'compatible' => 'sd',
                        'device_type' => 'block',
                        'name' => 'disk'
                    },
                    'version' => 'LSI1030 SCSI Host Adapter FCode Driver: 1.11 04/03/18',
                    'name' => 'scsi',
                    'subsystem-vendor-id' => '00001000',
                    '0xf00f3164' => {
                        'compatible' => 'st',
                        'device_type' => 'byte',
                        'name' => 'tape'
                    },
                    'class-code' => '00010000',
                    'latency-timer' => '00000040',
                    'subsystem-id' => '000010c0',
                    'reg' => '00002100.00000000.00000000.00000000.00000000.01002110.00000000.00000000.00000000.00000100.03002114.00000000.00000000.00000000.00020000.0300211c.00000000.00000000.00000000.00020000.02002130.00000000.00000000.00000000.00100000',
                    'devsel-speed' => '00000001'
                },
                '0xf00dc1c4' => {
                    'vendor-id' => '00001000',
                    'min-grant' => '00000010',
                    'compatible' => [
                        'pci1000,30.1000.10c0.8',
                        'pci1000,30.1000.10c0',
                        'pci1000,10c0',
                        'pci1000,30.8',
                        'pci1000,30',
                        'pciclass,010000',
                        'pciclass,0100'
                    ],
                    'cache-line-size' => '00000010',
                    'revision-id' => '00000008',
                    'fcode-rom-offset' => '0000f000',
                    'model' => 'LSI,1030',
                    '0xf00e6758' => {
                        'compatible' => 'sd',
                        'device_type' => 'block',
                        'name' => 'disk'
                    },
                    'assigned-addresses' => '81002010.00000000.00000400.00000000.00000100.83002014.00000000.00100000.00000000.00020000.8300201c.00000000.00120000.00000000.00020000.82002030.00000000.00200000.00000000.00100000',
                    '0xf00e72e8' => {
                        'compatible' => 'st',
                        'device_type' => 'byte',
                        'name' => 'tape'
                    },
                    'device-id' => '00000030',
                    'max-latency' => '00000006',
                    'device_type' => 'scsi-2',
                    'interrupts' => '00000001',
                    'version' => 'LSI1030 SCSI Host Adapter FCode Driver: 1.11 04/03/18',
                    'name' => 'scsi',
                    'subsystem-vendor-id' => '00001000',
                    'class-code' => '00010000',
                    'latency-timer' => '00000040',
                    'subsystem-id' => '000010c0',
                    'reg' => '00002000.00000000.00000000.00000000.00000000.01002010.00000000.00000000.00000000.00000100.03002014.00000000.00000000.00000000.00020000.0300201c.00000000.00000000.00000000.00020000.02002030.00000000.00000000.00000000.00100000',
                    'devsel-speed' => '00000001'
                },
                'bus-range' => '00000000.00000000',
                'no-probe-list' => '0',
                'available' => '81000000.00000000.00000330.00000000.000000d0.81000000.00000000.00000800.00000000.0000f800.82000000.00000000.00600000.00000000.7ba00000',
                '#size-cells' => '00000002',
                'slot-names' => '0000003c.50434920.33005043.49203200.50434920.31005043.49203000',
                'name' => 'pci',
                '0xf00d8414' => {
                    'vendor-id' => '00001095',
                    'min-grant' => '00000002',
                    'compatible' => [
                        'pci1095,646.1095.646.7',
                        'pci1095,646.1095.646',
                        'pci1095,646',
                        'pci1095,646.7',
                        'pci1095,646',
                        'pciclass,01018f',
                        'pciclass,0101'
                    ],
                    'cache-line-size' => '00000000',
                    'revision-id' => '00000007',
                    'assigned-addresses' => '81000810.00000000.00000300.00000000.00000008.81000814.00000000.00000318.00000000.00000008.81000818.00000000.00000310.00000000.00000008.8100081c.00000000.00000308.00000000.00000008.81000820.00000000.00000320.00000000.00000010',
                    'device-id' => '00000646',
                    'max-latency' => '00000004',
                    '#address-cells' => '00000002',
                    'device_type' => 'ide',
                    'interrupts' => '00000001',
                    '0xf00db1a8' => {
                        'compatible' => 'ide-disk',
                        'device_type' => 'block',
                        'name' => 'disk'
                    },
                    '0xf00db85c' => {
                        'compatible' => 'ide-cdrom',
                        'device_type' => 'block',
                        'name' => 'cdrom'
                    },
                    'name' => 'ide',
                    'subsystem-vendor-id' => '00001095',
                    'class-code' => '0001018f',
                    'latency-timer' => '00000040',
                    'subsystem-id' => '00000646',
                    'devsel-speed' => '00000001',
                    'reg' => '00000800.00000000.00000000.00000000.00000000.01000810.00000000.00000000.00000000.00000008.01000814.00000000.00000000.00000000.00000004.01000818.00000000.00000000.00000000.00000008.0100081c.00000000.00000000.00000000.00000004.01000820.00000000.00000000.00000000.00000010'
                },
                'clock-frequency' => '01f78a40',
                'reg' => '00000400.04700000.00000000.00018000.00000400.04410000.00000000.00000050.000007ff.ee000000.00000000.00000100',
                'ino-bitmap' => '1ffff000.00080142',
                'portid' => '00000008',
                'interrupt-map-mask' => '00fff800.00000000.00000000.00000007',
                '0xf00ffd38' => {
                    'vendor-id' => '00001000',
                    'min-grant' => '00000010',
                    'compatible' => [
                        'pci1000,30.1000.10c0.8',
                        'pci1000,30.1000.10c0',
                        'pci1000,10c0',
                        'pci1000,30.8',
                        'pci1000,30',
                        'pciclass,010000',
                        'pciclass,0100'
                    ],
                    'cache-line-size' => '00000010',
                    'revision-id' => '00000008',
                    'fcode-rom-offset' => '0000f000',
                    'model' => 'LSI,1030',
                    'assigned-addresses' => '81002910.00000000.00000700.00000000.00000100.83002914.00000000.001c0000.00000000.00020000.8300291c.00000000.001e0000.00000000.00020000.82002930.00000000.00500000.00000000.00100000',
                    'device-id' => '00000030',
                    'max-latency' => '00000006',
                    'device_type' => 'scsi-2',
                    'interrupts' => '00000002',
                    '0xf010a2cc' => {
                        'compatible' => 'sd',
                        'device_type' => 'block',
                        'name' => 'disk'
                    },
                    'version' => 'LSI1030 SCSI Host Adapter FCode Driver: 1.11 04/03/18',
                    'name' => 'scsi',
                    'subsystem-vendor-id' => '00001000',
                    'class-code' => '00010000',
                    'latency-timer' => '00000040',
                    'subsystem-id' => '000010c0',
                    '0xf010ae5c' => {
                        'compatible' => 'st',
                        'device_type' => 'byte',
                        'name' => 'tape'
                    },
                    'reg' => '00002900.00000000.00000000.00000000.00000000.01002910.00000000.00000000.00000000.00000100.03002914.00000000.00000000.00000000.00020000.0300291c.00000000.00000000.00000000.00020000.02002930.00000000.00000000.00000000.00100000',
                    'devsel-speed' => '00000001'
                }
            },
            '0xf007cf08' => {
                'compatible' => [
                    'SUNW,UltraSPARC-III,mc',
                    'SUNW,mc'
                ],
                'device_type' => 'memory-controller',
                'reg' => '00000400.02c00000.00000000.00000048',
                'name' => 'memory-controller',
                'portid' => '00000005',
                'memory-layout' => '4a323930.30000000.4a323930.31000000.4a333030.31000000.4a333030.30000000.4a333130.30000000.4a333130.31000000.4a333230.31000000.4a333230.30000000.01aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.55aaaaaa.aaaaaaaa.aaaaffff.ffffffff.ff555555.55555555.00000000.00000000.00ffd57f.5556ca6f.e3207607.997bbb25.7bca2a6a.564cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.854cc051.c560d465.d96ade5b.cf2a9e47.02760720.94168a1b.8f0c8011.854cc051.c560d465.d95bcfde.6fe39e47.bb029425.99168a1b.8f0c8011.854cc051.c560d465.d956ca5b.cf6ade6f.e32a9e47.bb027607.7b209425.99168a1b.8f0c8011.8557cb70.e4217708.9a7cbc26.7ccb2b6b.574dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.864dc152.c661d566.da6bdf5c.d02b9f48.03770821.95178b1c.900d8112.864dc152.c661d566.da5cd0df.70e49f48.bc039526.9a178b1c.900d8112.864dc152.c661d566.da57cb5c.d06bdf70.e42b9f48.bc037708.7c219526.9a178b1c.900d8112.8658cc71.e5227809.9b7dbd27.7dcc2c6c.584ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.874ec253.c762d667.db6ce05d.d12ca049.04780922.96188c1d.910e8213.874ec253.c762d667.db5dd1e0.71e5a049.bd049627.9b188c1d.910e8213.874ec253.c762d667.db58cc5d.d16ce071.e52ca049.bd047809.7d229627.9b188c1d.910e8213.8759cd72.e623790a.9c7ebe28.7ecd2d6d.594fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.884fc354.c863d768.dc6de15e.d22da14a.05790a23.97198d1e.920f8314.884fc354.c863d768.dc5ed2e1.72e6a14a.be059728.9c198d1e.920f8314.884fc354.c863d768.dc59cd5e.d26de172.e62da14a.be05790a.7e239728.9c198d1e.920f8314.88'
            },
            '0xf0079144' => {
                '0xf0079710' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000001',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000000',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000000',
                    'mask#' => '00000031'
                },
                'reg' => '00000400.00000000.00000000.00010000',
                '#address-cells' => '00000001',
                '#size-cells' => '00000000',
                'name' => 'cmp',
                'portid' => '00000000',
                '0xf0079a68' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000002',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000001',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000010',
                    'mask#' => '00000031'
                }
            },
            '0xf007c674' => {
                '0xf007cb78' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000002',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000001',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000015',
                    'mask#' => '00000031'
                },
                '0xf007c820' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000001',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000000',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000005',
                    'mask#' => '00000031'
                },
                'reg' => '00000400.02800000.00000000.00010000',
                '#address-cells' => '00000001',
                '#size-cells' => '00000000',
                'name' => 'cmp',
                'portid' => '00000005'
            },
            '0xf002cd3c' => {
                'bbc0' => '/pci@9,700000/ebus@1/bbc@1,0',
                'pci9b' => '/pci@9,700000',
                'idprom' => '/pci@9,700000/ebus@1/i2c@1,500030/idprom@0,a0',
                'net' => '/pci@9,700000/network@1,1',
                'disk0' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@0,0',
                'disk4' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@4,0',
                'disk11' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@d,0',
                'ttya' => '/pci@9,700000/ebus@1/serial@1,400000:a',
                'i2c0' => '/pci@9,700000/ebus@1/i2c@1,2e',
                'pci9a' => '/pci@9,600000',
                'flash' => '/pci@9,700000/ebus@1/flashprom@0,0',
                'disk7' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@9,0',
                'disk2' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@2,0',
                'name' => 'aliases',
                'cdrom' => '/pci@8,700000/ide@1/cdrom@0,0:f',
                'ide' => '/pci@8,700000/ide@1',
                'disk9' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@b,0',
                'i2c1' => '/pci@9,700000/ebus@1/i2c@1,30',
                'ebus' => '/pci@9,700000/ebus@1',
                'disk' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@0,0',
                'disk5' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@5,0',
                'disk8' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@a,0',
                'ttyb' => '/pci@9,700000/ebus@1/serial@1,400000:b',
                'i2c3' => '/pci@9,700000/ebus@1/i2c@1,500030',
                'disk6' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@8,0',
                'pci8a' => '/pci@8,600000',
                'rsc-console' => '/pci@9,700000/ebus@1/rsc-console@1,3083f8',
                'gem' => '/pci@8,600000/network@1',
                'i2c2' => '/pci@9,700000/ebus@1/i2c@1,50002e',
                'rsc-control' => '/pci@9,700000/ebus@1/rsc-control@1,3062f8',
                'scsi' => '/pci@8,600000/SUNW,qlc@2',
                'disk1' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@1,0',
                'nvram' => '/pci@9,700000/ebus@1/i2c@1,500030/nvram@0,a0',
                'screen' => '/pci@9,700000/SUNW,XVR-100@3',
                'disk3' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@3,0',
                'bbc1' => '/pci@9,700000/ebus@1/bbc@1,500000',
                'pci8b' => '/pci@8,700000',
                'disk10' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@c,0'
            },
            '0xf0079f34' => {
                '0xf007a438' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000002',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000001',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000011',
                    'mask#' => '00000031'
                },
                'reg' => '00000400.00800000.00000000.00010000',
                '#address-cells' => '00000001',
                '#size-cells' => '00000000',
                'name' => 'cmp',
                'portid' => '00000001',
                '0xf007a0e0' => {
                    'l1-icache-size' => '00008000',
                    'l1-dcache-associativity' => '00000004',
                    'compatible' => 'SUNW,UltraSPARC-IV',
                    'l1-dcache-size' => '00010000',
                    'implementation#' => '00000018',
                    'l2-cache-size' => '00800000',
                    'device_type' => 'cpu',
                    '#itlb-entries' => '00000010',
                    'l2-cache-sharing' => '00000000.00000001',
                    'l2-cache-line-size' => '00000080',
                    'l1-dcache-line-size' => '00000020',
                    'name' => 'cpu',
                    'l1-icache-line-size' => '00000020',
                    'l1-icache-associativity' => '00000004',
                    'l2-cache-associativity' => '00000002',
                    'clock-frequency' => '50775d80',
                    'sparc-version' => '00000009',
                    'manufacturer#' => '0000003e',
                    'reg' => '00000000',
                    '#dtlb-entries' => '00000010',
                    'cpuid' => '00000001',
                    'mask#' => '00000031'
                }
            },
            '0xf00408c4' => {
                'page-size' => '00002000',
                'existing' => '00000000.00000000.00000800.00000000.fffff800.00000000.00000800.00000000',
                'translations' => '00000000.00002000.00000000.009fe000.800000a0.00002036.00000000.01000000.00000000.00400000.800000d1.ff400036.00000000.01800000.00000000.00400000.800000d1.ff000036.00000000.02000000.00000000.01000000.800000d1.f9000036.00000000.03000000.00000000.00040000.800000d1.fa500036.00000000.03040000.00000000.00800000.800000d1.f8800036.00000000.70000000.00000000.00002000.800000d1.fa4ce036.00000000.70002000.00000000.00002000.800000d1.fa000036.00000000.70004000.00000000.0000c000.800000d1.fa54c036.00000000.70010000.00000000.00002000.800000d1.fa236036.00000000.70012000.00000000.0007c000.800000d1.fa0a2036.00000000.7008e000.00000000.00004000.800000d1.fa092036.00000000.70092000.00000000.00006000.800000d1.fa084036.00000000.70098000.00000000.00026000.800000d1.d1e2a036.00000000.700be000.00000000.0000a000.800000d1.d1e08036.00000000.700c8000.00000000.0000e000.800000d1.d1dc0036.00000000.700d6000.00000000.00014000.800000d1.d1d6e036.00000000.700ea000.00000000.00008000.800000d1.d1d66036.00000000.700f2000.00000000.0000c000.800000d1.d1d2e036.00000000.700fe000.00000000.00016000.800000d1.d1ce2036.00000000.70114000.00000000.000c6000.800000d1.d1c0c036.00000000.701da000.00000000.0003a000.800000d1.d1b98036.00000000.70214000.00000000.00010000.800000d1.d1b76036.00000000.f0000000.00000000.00400000.800000d1.ffc000b6.00000000.fecbc000.00000000.00002000.800000d1.fa5600b6.00000000.fecbe000.00000000.0003e000.800000d1.ff8d60b6.00000000.fed1c000.00000000.00200000.800007fc.7d00008e.00000000.fef1c000.00000000.00002000.800007ff.e800008e.00000000.fef1e000.00000000.00004000.800000d1.ffb2c0b6.00000000.fef22000.00000000.00002000.80000400.04c0008e.00000000.fef24000.00000000.00002000.80000400.04c1008e.00000000.fef26000.00000000.00010000.80000400.04e0008e.00000000.fef38000.00000000.00004000.800000d1.ffb300b6.00000000.fef3c000.00000000.00002000.80000400.04c0008e.00000000.fef3e000.00000000.00002000.80000400.04c1008e.00000000.fef40000.00000000.00010000.80000400.04f0008e.00000000.fef52000.00000000.00004000.800000d1.ffb340b6.00000000.fef56000.00000000.00002000.80000400.0440008e.00000000.fef58000.00000000.00002000.80000400.0441008e.00000000.fef5a000.00000000.00010000.80000400.0460008e.00000000.fef6c000.00000000.00004000.800000d1.ffb380b6.00000000.fef70000.00000000.00090000.800000d1.ffb580b6.00000000.fff00000.00000000.00002000.80000400.0440008e.00000000.fff02000.00000000.00002000.80000400.0441008e.00000000.fff04000.00000000.00010000.80000400.0470008e.00000000.fff1c000.00000000.00002000.800000d1.ffb460b6.00000000.fff1e000.00000000.00002000.800000d1.ffb4a0b6.00000000.fff22000.00000000.00002000.800007fc.7e30808e.00000000.fff26000.00000000.0000c000.800000d1.ffb120b6.00000000.fff32000.00000000.00008000.800000d1.ffb200b6.00000000.fff3a000.00000000.00002000.800007ff.ee00008e.00000000.fff3c000.00000000.00002000.800000d1.ffb280b6.00000000.fff3e000.00000000.00002000.800007fc.7e30008e.00000000.fff40000.00000000.00002000.800007fc.7e50008e.00000000.fff42000.00000000.00002000.800007fc.7e50008e.00000000.fff44000.00000000.00002000.800007fc.7e50008e.00000000.fff46000.00000000.00002000.800007fc.7e50008e.00000000.fff48000.00000000.00002000.800000d1.ffb2a0b6.00000000.fff4a000.00000000.00002000.800007fc.7e00008e.00000000.fff4c000.00000000.00002000.800007fc.7e00008e.00000000.fff4e000.00000000.00002000.800000d1.ffb3c0b6.00000000.fff50000.00000000.00002000.800007fc.7e00008e.00000000.fff52000.00000000.00002000.800007fc.7e30008e.00000000.fff54000.00000000.00002000.800007ff.ec00008e.00000000.fff56000.00000000.00002000.800007fc.7e30008e.00000000.fff58000.00000000.00002000.800007fc.7e00008e.00000000.fff5a000.00000000.00002000.800000d1.ffb420b6.00000000.fff5c000.00000000.00002000.800007ff.ea00008e.00000000.fff5e000.00000000.00002000.800000d1.ffb3e0b6.00000000.fff64000.00000000.00002000.800000d1.feffe0b6.00000000.fff66000.00000000.0000a000.800000d1.ffb4c0b6.00000000.fff70000.00000000.00010000.800000d1.ffbf00b6.00000300.00002000.00000000.00002000.800000d1.fa54a036.00000300.00004000.00000000.00002000.800000d1.fa544036.00000300.00006000.00000000.00002000.800000d1.fa542036.00000300.00008000.00000000.00002000.800000d1.fa540036.00000300.0000a000.00000000.00002000.800000d1.fa4fe036.00000300.0000c000.00000000.00004000.800000d1.fa4fa036.00000300.00010000.00000000.00004000.800000d1.fa4ec036.00000300.00014000.00000000.00004000.800000d1.fa4de036.00000300.00018000.00000000.00002000.800000d1.fa4d0036.00000300.0001a000.00000000.00002000.800000d1.fa4ca036.00000300.0001c000.00000000.00002000.800000d1.fa4c8036.00000300.0001e000.00000000.00002000.800000d1.fa3c0036.00000300.00020000.00000000.00002000.800000d1.fa38e036.00000300.00022000.00000000.00002000.800000d1.fa382036.00000300.00024000.00000000.00002000.800000d1.fa380036.00000300.00026000.00000000.00002000.800000d1.fa37c036.00000300.00028000.00000000.00002000.800000d1.fa362036.00000300.0002a000.00000000.00002000.800000d1.fa354036.00000300.0002c000.00000000.00002000.800000d1.fa1a4036.00000300.0002e000.00000000.00002000.800000d1.fa1a0036.00000300.00030000.00000000.00002000.800000d1.fa09e036.00000300.00032000.00000000.00002000.800000d1.fa09c036.00000300.00034000.00000000.00002000.800000d1.fa008036.00000300.00036000.00000000.00002000.800000d1.d1d00036.00000300.00038000.00000000.00002000.800000d1.d16a6036.00000300.0003a000.00000000.00002000.800000d1.d16a2036.00000300.00042000.00000000.00002000.800000d1.fa4f8036.00000300.00044000.00000000.00002000.800000d1.fa4f6036.00000300.00046000.00000000.00002000.800000d1.fa4f4036.00000300.00048000.00000000.00002000.800000d1.fa4f2036.00000300.0004a000.00000000.00002000.800000d1.fa4f0036.00000300.0004c000.00000000.00002000.800000d1.fa4ea036.00000300.0004e000.00000000.00002000.800000d1.fa4e8036.00000300.00050000.00000000.00002000.800000d1.fa4e6036.00000300.00052000.00000000.00002000.800000d1.fa4e4036.00000300.00054000.00000000.00002000.800000d1.fa4e2036.00000300.00056000.00000000.00002000.800000d1.fa4dc036.00000300.00058000.00000000.00002000.800000d1.fa4da036.00000300.0005a000.00000000.00002000.800000d1.fa4d8036.00000300.0005c000.00000000.00002000.800000d1.fa4d6036.00000300.0005e000.00000000.00002000.800000d1.fa4d4036.00000300.00060000.00000000.00002000.800000d1.fa4d2036.00000300.00062000.00000000.00002000.800000d1.fa3c4036.00000300.00064000.00000000.00002000.800000d1.fa3c2036.00000300.00066000.00000000.00002000.800000d1.fa3be036.00000300.00068000.00000000.00002000.800000d1.fa3bc036.00000300.0006a000.00000000.00002000.800000d1.fa3ba036.00000300.0006c000.00000000.00002000.800000d1.fa396036.00000300.0006e000.00000000.00002000.800000d1.fa394036.00000300.00070000.00000000.00002000.800000d1.fa38a036.00000300.00072000.00000000.00002000.800000d1.fa37a036.00000300.00074000.00000000.00002000.800000d1.fa378036.00000300.00076000.00000000.00002000.800000d1.fa36c036.00000300.00078000.00000000.00002000.800000d1.fa368036.00000300.0007a000.00000000.00002000.800000d1.fa366036.00000300.0007c000.00000000.00002000.800000d1.fa314036.00000300.0007e000.00000000.00002000.800000d1.fa1a8036.00000300.00080000.00000000.00002000.800000d1.fa1a2036.00000300.00082000.00000000.00002000.800000d1.fa4cc036.00000300.00084000.00000000.00002000.800000d1.fa4c6036.00000300.00086000.00000000.00080000.800000d1.fa446036.00000300.00106000.00000000.00080000.800000d1.fa3c6036.00000300.00186000.00000000.00002000.800000d1.fa356036.00000300.00188000.00000000.00002000.800000d1.fa364036.00000300.0018a000.00000000.00002000.800000d1.fa36a036.00000300.0018c000.00000000.0000a000.800000d1.fa36e036.00000300.00196000.00000000.00002000.800000d1.fa37e036.00000300.00198000.00000000.00006000.800000d1.fa384036.00000300.0019e000.00000000.00002000.800000d1.fa38c036.00000300.001a0000.00000000.00004000.800000d1.fa390036.00000300.001a4000.00000000.00022000.800000d1.fa398036.00000300.001c6000.00000000.0000a000.800000d1.fa358036.00000300.001d0000.00000000.00016000.800000d1.fa034036.00000300.001e6000.00000000.00004000.800000d1.fa050036.00000300.001ea000.00000000.00004000.800000d1.fa05a036.00000300.001ee000.00000000.00002000.800000d1.fa06e036.00000300.001f0000.00000000.00002000.800000d1.fa082036.00000300.001f2000.00000000.00002000.800000d1.fa09a036.00000300.001f4000.00000000.00002000.800000d1.fa0a0036.00000300.001f6000.00000000.00002000.800000d1.fa1a6036.00000300.001f8000.00000000.0000a000.800000d1.fa22c036.00000300.00202000.00000000.00004000.800000d1.fa238036.00000300.00206000.00000000.00008000.800000d1.fa242036.00000300.0020e000.00000000.00002000.800000d1.fa352036.00000300.00210000.00000000.0003c000.800000d1.fa316036.00000300.0024c000.00000000.00010000.800000d1.fa304036.00000300.0025c000.00000000.0005a000.800000d1.fa2aa036.00000300.002b6000.00000000.00048000.800000d1.fa262036.00000300.002fe000.00000000.00008000.800000d1.fa25a036.00000300.00306000.00000000.00006000.800000d1.fa254036.00000300.0030c000.00000000.0000a000.800000d1.fa24a036.00000300.00328000.00000000.00006000.800000d1.d1b42036.00000300.0032e000.00000000.00006000.800000d1.d1b4a036.00000300.00334000.00000000.0000c000.800000d1.d1dac036.00000300.00340000.00000000.0000c000.800000d1.fa076036.00000300.0034c000.00000000.00006000.800000d1.fa23c036.00000300.00356000.00000000.00082000.800000d1.fa1aa036.00000300.003d8000.00000000.00002000.800000d1.fa19e036.00000300.00418000.00000000.00002000.800000d1.fa19c036.00000300.0041a000.00000000.0007c000.800000d1.fa11e036.00000300.004d2000.00000000.00004000.800000d1.fa096036.00000300.004fe000.00000000.00008000.800000d1.d1d48036.00000300.00506000.00000000.00008000.800000d1.d1db8036.00000300.0050e000.00000000.00008000.800000d1.fa08a036.00000300.00516000.00000000.00006000.800000d1.fa070036.00000300.0051c000.00000000.00008000.800000d1.fa066036.00000300.00524000.00000000.00002000.800000d1.fa064036.00000300.00526000.00000000.00006000.800000d1.fa05e036.00000300.0052c000.00000000.00006000.800000d1.fa054036.00000300.00532000.00000000.00006000.800000d1.fa04a036.00000300.00548000.00000000.00004000.800000d1.d1b3e036.00000300.0054c000.00000000.00002000.800000d1.d1b48036.00000300.0054e000.00000000.00002000.800000d1.d1b62036.00000300.00550000.00000000.00002000.800000d1.d1ce0036.00000300.00552000.00000000.00002000.800000d1.d1df2036.00000300.00554000.00000000.00002000.800000d1.d1e06036.00000300.00556000.00000000.00002000.800000d1.d1e28036.00000300.00558000.00000000.00008000.800000d1.d1e76036.00000300.00560000.00000000.00006000.800000d1.fa002036.00000300.00566000.00000000.00002000.800000d1.fa00a036.00000300.00568000.00000000.00010000.800000d1.fa024036.00000300.00578000.00000000.00018000.800000d1.fa00c036.00000300.00590000.00000000.00182000.800000d1.d1e7e036.00000300.00712000.00000000.00026000.800000d1.d1e50036.00000300.00738000.00000000.0000c000.800000d1.d1e1c036.00000300.00744000.00000000.0000a000.800000d1.d1e12036.00000300.0074e000.00000000.00008000.800000d1.d1dfe036.00000300.00756000.00000000.0000a000.800000d1.d1df4036.00000300.00760000.00000000.00006000.800000d1.d1dec036.00000300.00766000.00000000.00006000.800000d1.d1de6036.00000300.0076c000.00000000.00006000.800000d1.d1de0036.00000300.00772000.00000000.00002000.800000d1.d1dde036.00000300.00774000.00000000.00010000.800000d1.d1dce036.00000300.00784000.00000000.00002000.800000d1.d1daa036.00000300.00786000.00000000.00006000.800000d1.d1da4036.00000300.0078c000.00000000.00004000.800000d1.d1da0036.00000300.00790000.00000000.00008000.800000d1.d1d98036.00000300.00798000.00000000.00016000.800000d1.d1d82036.00000300.007ae000.00000000.00016000.800000d1.d1d50036.00000300.007c4000.00000000.0000e000.800000d1.d1d3a036.00000300.007d2000.00000000.00004000.800000d1.d1d2a036.00000300.007d6000.00000000.0000e000.800000d1.d1d1c036.00000300.007e4000.00000000.00004000.800000d1.d1d18036.00000300.007e8000.00000000.00010000.800000d1.d1d08036.00000300.007f8000.00000000.00006000.800000d1.d1d02036.00000300.007fe000.00000000.00002000.800000d1.d16a4036.00000300.01000000.00000000.00400000.800000d1.d2000036.00000300.01400000.00000000.00008000.800000d1.d1cf8036.00000300.01408000.00000000.0000e000.800000d1.d1cd2036.00000300.01416000.00000000.0003a000.800000d1.d1bd2036.00000300.01450000.00000000.00012000.800000d1.d1b86036.00000300.01462000.00000000.00012000.800000d1.d1b64036.00000300.01474000.00000000.00006000.800000d1.d1b5c036.00000300.0147a000.00000000.00008000.800000d1.d1b54036.00000300.01482000.00000000.00004000.800000d1.d1b50036.00000300.01486000.00000000.00004000.800000d1.d1b3a036.00000300.0148a000.00000000.00006000.800000d1.d1b34036.00000300.01490000.00000000.00006000.800000d1.d1b2e036.00000300.01496000.00000000.00006000.800000d1.d1b28036.00000300.0149c000.00000000.00006000.800000d1.d1b22036.00000300.014a2000.00000000.00478000.800000d1.d16aa036',
                'name' => 'virtual-memory',
                'available' => 'fffff800.00000000.000007fc.00000000.00000700.26400000.000000ff.d9c00000.00000300.0191a000.000003ff.fe6e6000.00000300.00800000.00000000.00800000.00000300.00538000.00000000.00010000.00000300.004d6000.00000000.00028000.00000300.00496000.00000000.0003c000.00000300.003da000.00000000.0003e000.00000300.00352000.00000000.00004000.00000300.00316000.00000000.00012000.00000300.0003c000.00000000.00006000.00000001.00000000.000002ff.00002000.00000000.ffff0000.00000000.0000e000.00000000.70224000.00000000.7fddc000.00000000.03840000.00000000.6c7c0000.00000000.01c00000.00000000.00400000.00000000.01400000.00000000.00400000.00000000.00000000.00000000.01000000.00000000.fff24000.00000000.00002000.00000000.fff20000.00000000.00002000.00000000.fff14000.00000000.00008000.00000000.fef6a000.00000000.00002000.00000000.fef50000.00000000.00002000.00000000.fef36000.00000000.00002000.00000000.fecfc000.00000000.00020000.00000000.f0800000.00000000.0e4bc000'
            },
            '0xf012de78' => {
                'compatible' => 'SUNW,ramdisk',
                'device_type' => 'block',
                'name' => 'ramdisk-root',
                'address' => '51000000',
                'alloc-size' => '00000000',
                'size' => '04902000'
            },
            '0xf002cb08' => {
                'mmu' => 'fff73328',
                'bootargs' => '-v',
                'elfheader-length' => '0015c000',
                'impl-arch-name' => 'SUNW,Sun-Fire-V890',
                'bootfs' => 'fff31e10',
                'bootpath' => '/pci@8,600000/SUNW,qlc@2/fp@0,0/disk@w21000014c34173c0,0:a',
                'elfheader-address' => '50000000',
                'stdout' => 'fff30e58',
                'whoami' => '/platform/sun4u/kernel/sparcv9/unix',
                'stdin' => 'fff30f68',
                'name' => 'chosen',
                'archfs' => 'fff30f48',
                'archive-fstype' => 'hsfs',
                'memory' => 'fff73538',
                'bootarchive' => '/ramdisk-root',
                'stdout-#lines' => 'ffffffff',
                'fs-package' => 'hsfs-file-system',
                'fstype' => 'ufs'
            },
            '0xf0040240' => {
                'reg' => '000000a0.00000000.00000002.00000000.000000b0.00000000.00000002.00000000.000000c0.00000000.00000002.00000000.000000d0.00000000.00000002.00000000',
                'name' => 'memory',
                'available' => '000000d1.ffada000.00000000.00028000.000000d1.ff962000.00000000.00164000.000000d1.ff916000.00000000.00048000.000000d1.ff8d4000.00000000.00002000.000000d1.ff800000.00000000.000d2000.000000d1.fa564000.00000000.04a9a000.000000d0.00000000.00000001.d16a2000.000000c0.00000000.00000002.00000000.000000b0.00000000.00000002.00000000.000000a0.00000000.00000002.00000000'
            }
        }
    },
    sparc3 => {
        'Memory size' => '4096 Megabytes',
        'System Configuration' => 'Oracle Corporation  sun4u',
        '0xf002a150' => {
            'model' => 'SUNW,375-3463',
            '0xf002d540' => {
                'ttyb' => '/ebus@1f,464000/serial@2,40',
                'ide' => '/pci@1e,600000/pci@0/pci@1/pci@0/ide@1f',
                'disk' => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@0,0',
                'net1' => '/pci@1e,600000/pci@0/pci@9/pci@0/network@4,1',
                'disk1' => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@1,0',
                'disk0' => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@0,0',
                'disk2' => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@2,0',
                'ttya' => '/ebus@1f,464000/serial@2,80',
                'net2' => '/pci@1e,600000/pci@0/pci@a/pci@0/network@4',
                'net' => '/pci@1e,600000/pci@0/pci@9/pci@0/network@4',
                'scsi' => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1',
                'net0' => '/pci@1e,600000/pci@0/pci@9/pci@0/network@4',
                'cdrom' => '/pci@1e,600000/pci@0/pci@1/pci@0/ide@1f/cdrom@0,0:f',
                'disk3' => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@3,0',
                'name' => 'aliases',
                'sc-control' => '/ebus@1f,464000/rmc-comm@2,0',
                'net3' => '/pci@1e,600000/pci@0/pci@a/pci@0/network@4,1'
            },
            '0xf002d4c8' => {
                'ttyb-ignore-cd' => 'true',
                'verbosity' => 'normal',
                'screen-#columns' => '80',
                'boot-device' => 'disk1:a disk',
                'security-#badlogins' => '0',
                'name' => 'options',
                'ttyb-mode' => '9600,8,n,1,-',
                'auto-boot-on-error?' => 'true',
                'security-mode' => 'none',
                'boot-command' => 'boot',
                'oem-logo?' => 'false',
                'local-mac-address?' => 'true',
                'ttya-mode' => '9600,8,n,1,-',
                'ttyb-rts-dtr-off' => 'false',
                'nvramrc' => 'devalias rootmirror /pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@1,0',
                'error-reset-recovery' => 'sync',
                'output-device' => 'screen',
                'ttya-ignore-cd' => 'true',
                'input-device' => 'keyboard',
                'diag-passes' => '1',
                'diag-switch?' => 'false',
                'ansi-terminal?' => 'true',
                'asr-policy' => 'normal',
                'load-base' => '16384',
                'diag-level' => 'max',
                'auto-boot?' => 'true',
                'fcode-debug?' => 'false',
                'diag-script' => 'normal',
                'diag-trigger' => 'error-reset power-on-reset ',
                'oem-banner?' => 'false',
                'scsi-initiator-id' => '7',
                'diag-device' => 'disk0 disk1',
                'screen-#rows' => '34',
                'ttya-rts-dtr-off' => 'false',
                'service-mode?' => 'false',
                'use-nvramrc?' => 'false'
            },
            '#interrupt-cells' => '00000001',
            'clock-frequency' => '0b34a700',
            'name' => 'SUNW,Sun-Fire-V215',
            'interrupt-map' => '00000400.0fd30000.00000001.f0067c2c.0000003d.00000400.0fd20000.00000001.f0067c2c.0000003c',
            'device_type' => 'jbus',
            'banner-name' => 'Sun Fire V215',
            '0xf002d380' => {
                '0xf002d410' => {
                    'name' => 'client-services'
                },
                'model' => 'SUNW,4.25.10',
                'name' => 'openprom',
                'version' => 'OBP 4.25.10 2007/09/18 09:56'
            },
            'stick-frequency' => '01312d00',
            '0xf002d30c' => {
                'impl-arch-name' => 'SUNW,Sun-Fire-V215',
                'elfheader-length' => '0017c000',
                'bootarchive' => '/ramdisk-root',
                'stdin' => 'fff0a1a8',
                'whoami' => '/platform/sun4u/kernel/sparcv9/unix',
                'stdout' => 'fff11f20',
                'elfheader-address' => '50000000',
                'zfs-bootfs' => 'rpool/59',
                'stdout-#lines' => 'ffffffff',
                'name' => 'chosen',
                'mmu' => 'fff74080',
                'bootpath' => '/pci@1e,600000/pci@0/pci@a/pci@0/pci@8/scsi@1/disk@1,0:a',
                'bootargs' => '00',
                'fstype' => 'zfs',
                'fs-package' => 'hsfs-file-system',
                'memory' => 'fff74290',
                'archfs' => 'fff17f00',
                'archive-fstype' => 'hsfs',
                'bootfs' => 'fff11ed0'
            },
            '0xf003f938' => {
                'reg' => '00000000.00000000.00000000.40000000.00000002.00000000.00000000.40000000.00000010.00000000.00000000.40000000.00000012.00000000.00000000.40000000',
                'name' => 'memory',
                'available' => '00000012.3ff06000.00000000.00002000.00000012.3ff00000.00000000.00002000.00000012.3fee0000.00000000.00008000.00000012.3fe9a000.00000000.00006000.00000012.3fe70000.00000000.00010000.00000012.3fe5c000.00000000.00008000.00000012.3fe0a000.00000000.0004e000.00000012.3fe06000.00000000.00002000.00000012.3fdea000.00000000.0001a000.00000012.3f6ea000.00000000.006fc000.00000012.3f422000.00000000.00286000.00000012.39d9e000.00000000.05260000.00000012.00000000.00000000.32c42000.00000010.00000000.00000000.40000000.00000002.00000000.00000000.40000000.00000000.00000000.00000000.40000000'
            },
            '0xf00f95bc' => {
                'address' => '51000000',
                'alloc-size' => '00000000',
                'size' => '05260000',
                'compatible' => 'SUNW,ramdisk',
                'device_type' => 'block',
                'name' => 'ramdisk-root'
            },
            '0xf008f0b0' => {
                '#address-cells' => '00000002',
                'interrupt-map-mask' => '00000003.000fffff.00000003',
                '#size-cells' => '00000001',
                'reg' => '00000400.0fc64000.00000000.00000020',
                '0xf0095c9c' => {
                    'version' => '5.10',
                    'reg' => '00000003.00000000.00000081',
                    'compatible' => 'epic',
                    'name' => 'env-monitor'
                },
                '0xf008fc60' => {
                    'name' => 'flashprom',
                    'model' => 'SUNW,525-2320',
                    'version' => [
                        'OBP 4.25.10 2007/09/18 09:56 Sun Fire V215/V245',
                        'POST 4.25.10 2007/09/18 10:18',
                        'OBDIAG 4.25.10 2007/09/18 10:09  '
                    ],
                    'reg' => '00000000.00000000.00200000'
                },
                'compatible' => 'jbus-ebus',
                'ranges' => '00000000.00000000.000007ff.f0000000.01000000.00000001.00000000.000007ff.f1000000.01000000.00000002.00000000.000007ff.f2000000.01000000.00000003.00000000.000007ff.f3000000.01000000',
                '0xf009097c' => {
                    'interrupts' => '00000001',
                    'device_type' => 'serial',
                    'name' => 'serial',
                    'reg' => '00000002.00000080.00000008',
                    'compatible' => [
                        'su16552',
                        'su16550',
                        'su'
                    ]
                },
                'device_type' => 'ebus',
                'interrupt-map' => '00000002.00000080.00000001.f00705d0.00000008.00000002.00000040.00000001.f00705d0.00000009.00000002.00000000.00000001.f00705d0.0000000a.00000003.00000000.00000001.f00705d0.00000000.00000003.00000040.00000001.f00705d0.00000003',
                'name' => 'ebus',
                '0xf0095bac' => {
                    'name' => 'gpio',
                    'compatible' => 'pmugpio',
                    'gpio-device-type' => 'SUNW,cpld',
                    'reg' => '00000002.000000c0.00000001'
                },
                'portid' => '0000001f',
                '0xf009403c' => {
                    'compatible' => 'rmc_comm',
                    'reg' => '00000002.00000000.00000008',
                    'name' => 'rmc-comm',
                    'device_type' => 'serial',
                    'interrupts' => '00000001'
                },
                '#interrupt-cells' => '00000001',
                '0xf00924dc' => {
                    'name' => 'serial',
                    'device_type' => 'serial',
                    'interrupts' => '00000001',
                    'compatible' => [
                        'su16552',
                        'su16550',
                        'su'
                    ],
                    'reg' => '00000002.00000040.00000008'
                },
                'revision' => '00000000',
                '0xf0095fcc' => {
                    'power-device-type' => 'SUNW,pic18lf65j10',
                    'reg' => '00000003.00000040.00000082',
                    'interrupts' => '00000001',
                    'name' => 'power'
                }
            },
            '0xf002d294' => {
                '0xf0089b30' => {
                    'name' => 'SUNW,fru-device'
                },
                '0xf0059620' => {
                    'name' => 'deblocker'
                },
                '0xf0049a4c' => {
                    'name' => 'SUNW,builtin-drivers'
                },
                'name' => 'packages',
                '0xf0062168' => {
                    'name' => 'dropins',
                    'source' => '/flashprom:'
                },
                '0xf0079944' => {
                    'name' => 'obp-tftp'
                },
                '0xf00f9e5c' => {
                    'name' => 'hsfs-file-system'
                },
                '0xf005a458' => {
                    'name' => 'terminal-emulator'
                },
                '0xf008a338' => {
                    'maximum-reason-length' => '000000fa',
                    'name' => 'SUNW,asr'
                },
                '0xf0059b04' => {
                    'name' => 'disk-label'
                },
                '0xf0078b54' => {
                    'name' => 'kbd-translator'
                },
                '0xf00892ec' => {
                    'name' => 'SUNW,i2c-ram-device'
                },
                '0xf00f6624' => {
                    'name' => 'zfs-file-system'
                }
            },
            '0xf0067690' => {
                'name' => 'memory-controller',
                'memory-control-register-1' => '3000014a.3f801cb7',
                'device_type' => 'memory-controller',
                'portid' => '00000000',
                'compatible' => [
                    'SUNW,UltraSPARC-IIIi,mc',
                    'SUNW,mc'
                ],
                'reg' => '00000400.00000000.00000000.00000008',
                'memory-layout' => '42302f44.30000000.42302f44.31000000.42312f44.30000000.42312f44.31000000.01ff00ff.0000ff00.ff0000ff.ffff00ff.00800000.00000000.00001718.1c1f7275.797b2c53.545758ae.afb2b353.545758ae.afb2b348.494f50a5.a6aaab48.494f50a5.a6aaab3d.40444599.9ba1a235.37393c92.9396973d.40444599.9ba1a235.37393c92.93969702.0406085e.5f626302.0406085e.5f62630c.0d131469.6a6d6e0c.0d131469.6a6d6e21.2327287e.7f838517.181c1f72.75797b2c.2d313386.878e9021.2327287e.7f838500'
            },
            '0xf0067af0' => {
                'name' => 'memory-controller',
                'memory-control-register-1' => '3000014a.3f801cb7',
                'device_type' => 'memory-controller',
                'compatible' => [
                    'SUNW,UltraSPARC-IIIi,mc',
                    'SUNW,mc'
                ],
                'portid' => '00000001',
                'memory-layout' => '42302f44.30000000.42302f44.31000000.42312f44.30000000.42312f44.31000000.01ff00ff.0000ff00.ff0000ff.ffff00ff.00800000.00000000.00001718.1c1f7275.797b2c53.545758ae.afb2b353.545758ae.afb2b348.494f50a5.a6aaab48.494f50a5.a6aaab3d.40444599.9ba1a235.37393c92.9396973d.40444599.9ba1a235.37393c92.93969702.0406085e.5f626302.0406085e.5f62630c.0d131469.6a6d6e0c.0d131469.6a6d6e21.2327287e.7f838517.181c1f72.75797b2c.2d313386.878e9021.2327287e.7f838500',
                'reg' => '00000400.00800000.00000000.00000008'
            },
            '0xf010013c' => {
                'name' => 'os-io',
                'device_type' => 'console'
            },
            '0xf0066f4c' => {
                'dcache-associativity' => '00000004',
                'clock-frequency' => '59a53800',
                'clock-divisors' => '00000001.00000002.00000020',
                'icache-line-size' => '00000020',
                'name' => 'SUNW,UltraSPARC-IIIi',
                'device_type' => 'cpu',
                '#dtlb-entries' => '00000010',
                'dcache-line-size' => '00000020',
                'dcache-size' => '00010000',
                'portid' => '00000000',
                'ecache-line-size' => '00000040',
                'manufacturer#' => '0000003e',
                'icache-size' => '00008000',
                'cpuid' => '00000000',
                'implementation#' => '00000016',
                'ecache-size' => '00100000',
                '#itlb-entries' => '00000010',
                'ecache-associativity' => '00000004',
                'mask#' => '00000034',
                'icache-associativity' => '00000004',
                'sparc-version' => '00000009',
                'reg' => '00000400.00000000.00000000.00010000'
            },
            '0xf00705d0' => {
                'module-revision#' => '00000003',
                'msi-data-mask' => '000000ff',
                '#interrupt-cells' => '00000001',
                'ino-bitmap' => 'fff3c77d.ffffffff',
                'interrupt-map' => '00000000.00000000.00000000.00000001.f00705d0.00000014.00000000.00000000.00000000.00000002.f00705d0.00000015.00000000.00000000.00000000.00000003.f00705d0.00000016.00000000.00000000.00000000.00000004.f00705d0.00000017',
                'msi-eq-devino' => '00000000.00000024.00000018',
                'name' => 'pci',
                'interrupts' => '0000003f.0000003e',
                'device_type' => 'pciex',
                'available' => '81000000.00000000.00000000.00000000.00010000.82000000.00000000.00100000.00000000.bff00000.82000000.00000000.e0000000.00000000.00000000',
                'msi-eq-size' => '00000080',
                'portid' => '0000001f',
                'bus-range' => '00000002.000000ff',
                'module-manufacturer#' => '00000036',
                'msi-address-ranges' => '00000000.7fff0000.00010000.00000003.ffff0000.00010000',
                'ranges' => '00000000.00000000.00000000.000007f6.00000000.00000000.10000000.01000000.00000000.00000000.000007f6.10000000.00000000.10000000.02000000.00000000.00000000.000007f7.00000000.00000000.80000000.03000000.00000000.00000000.000007f4.00000000.00000000.80000000',
                'compatible' => 'pciex108e,80f0',
                'interrupt-map-mask' => '00000000.00000000.00000000.00000007',
                '#address-cells' => '00000003',
                'fire-revision#' => '00000004',
                'msix-data-width' => '00000020',
                '#msi-eqs' => '00000024',
                '#size-cells' => '00000002',
                'msi-ranges' => '00000000.00000100',
                '#msi' => '00000100',
                'reg' => '00000400.0ff00000.00000000.000f0000.00000400.0fc10000.00000000.00064000'
            },
            'breakpoint-trap' => '0000007f',
            'idprom' => '01840014.4f7aa3f2.00000000.7aa3f2de.f1010a00.00000000.00000000.000000fa',
            'interrupt-map-mask' => '00000fff.0fff0000.00000003',
            '0xf00677cc' => {
                'clock-frequency' => '59a53800',
                'clock-divisors' => '00000001.00000002.00000020',
                'icache-line-size' => '00000020',
                'dcache-associativity' => '00000004',
                'dcache-size' => '00010000',
                'portid' => '00000001',
                'ecache-line-size' => '00000040',
                'name' => 'SUNW,UltraSPARC-IIIi',
                'dcache-line-size' => '00000020',
                '#dtlb-entries' => '00000010',
                'device_type' => 'cpu',
                'implementation#' => '00000016',
                'ecache-size' => '00100000',
                '#itlb-entries' => '00000010',
                'ecache-associativity' => '00000004',
                'manufacturer#' => '0000003e',
                'cpuid' => '00000001',
                'icache-size' => '00008000',
                'sparc-version' => '00000009',
                'reg' => '00000400.00800000.00000000.00010000',
                'mask#' => '00000034',
                'icache-associativity' => '00000004'
            },
            '0xf0067c2c' => {
                '#address-cells' => '00000003',
                'interrupt-map-mask' => '00000000.00000000.00000000.00000007',
                '#msi-eqs' => '00000024',
                '#size-cells' => '00000002',
                'msi-ranges' => '00000000.00000100',
                '#msi' => '00000100',
                'reg' => '00000400.0f600000.00000000.000f0000.00000400.0f410000.00000000.00064000',
                'fire-revision#' => '00000004',
                'msix-data-width' => '00000020',
                '0xf009afa0' => {
                    'class-code' => '00060400',
                    'cache-line-size' => '00000010',
                    '0xf00bccd4' => {
                        'ranges' => '82000000.00000000.fff00000.82000000.00000000.fff00000.ffffffff.00200000',
                        'compatible' => [
                            'pciex10b5,8532.ba',
                            'pciex10b5,8532',
                            'pciexclass,060400',
                            'pciexclass,0604'
                        ],
                        '#size-cells' => '00000002',
                        'reg' => '00034000.00000000.00000000.00000000.00000000',
                        '#address-cells' => '00000003',
                        'class-code' => '00060400',
                        'cache-line-size' => '00000010',
                        'revision-id' => '000000ba',
                        'slot-names' => '00000001.5043492d.45203000',
                        'vendor-id' => '000010b5',
                        'physical-slot#' => '000000e0',
                        'bus-range' => '00000007.00000007',
                        'device-id' => '00008532',
                        'name' => 'pci',
                        'interrupts' => '00000001',
                        'device_type' => 'pciex'
                    },
                    'revision-id' => '000000ba',
                    'vendor-id' => '000010b5',
                    'bus-range' => '00000003.0000000d',
                    '0xf00bed18' => {
                        'cache-line-size' => '00000010',
                        'class-code' => '00060400',
                        'compatible' => [
                            'pciex10b5,8532.ba',
                            'pciex10b5,8532',
                            'pciexclass,060400',
                            'pciexclass,0604'
                        ],
                        'ranges' => '82000000.00000000.04000000.82000000.00000000.04000000.00000000.00600000',
                        'revision-id' => '000000ba',
                        'vendor-id' => '000010b5',
                        '#size-cells' => '00000002',
                        '0xf00c0c98' => {
                            'class-code' => '00060400',
                            'cache-line-size' => '00000010',
                            'vendor-id' => '00001166',
                            'revision-id' => '000000b5',
                            'bus-range' => '00000009.0000000a',
                            '0xf00d04ec' => {
                                'class-code' => '00060400',
                                'cache-line-size' => '00000010',
                                'latency-timer' => '00000040',
                                'slot-names' => '00000002.5043492d.58203100',
                                'vendor-id' => '00001166',
                                'revision-id' => '000000b4',
                                '#interrupt-cells' => '00000001',
                                'bus-range' => '0000000a.0000000a',
                                'device-id' => '00000104',
                                'interrupt-map' => '00000000.00000000.00000000.00000001.f0067c2c.0000000b.00000000.00000000.00000000.00000002.f0067c2c.0000000c.00000000.00000000.00000000.00000003.f0067c2c.0000000d.00000000.00000000.00000000.00000004.f0067c2c.0000000e',
                                'name' => 'pci',
                                'device_type' => 'pci',
                                'devsel-speed' => '00000001',
                                'compatible' => [
                                    'pci1166,104.b4',
                                    'pci1166,104',
                                    'pciclass,060400',
                                    'pciclass,0604'
                                ],
                                'ranges' => '82000000.00000000.fff00000.82000000.00000000.fff00000.ffffffff.00200000',
                                '#size-cells' => '00000002',
                                'reg' => '00094000.00000000.00000000.00000000.00000000',
                                'interrupt-map-mask' => '00000000.00000000.00000000.00000007',
                                '#address-cells' => '00000003'
                            },
                            'device-id' => '00000103',
                            'name' => 'pci',
                            'available' => '82000000.00000000.04000000.00000000.00010000.82000000.00000000.04040000.00000000.001c0000',
                            'device_type' => 'pciex',
                            '0xf00c9878' => {
                                'compatible' => [
                                    'pci14e4,1668.108e.1668.a3',
                                    'pci14e4,1668.108e.1668',
                                    'pci108e,1668',
                                    'pci14e4,1668.a3',
                                    'pci14e4,1668',
                                    'pciclass,020000',
                                    'pciclass,0200'
                                ],
                                'devsel-speed' => '00000001',
                                'reg' => '00092100.00000000.00000000.00000000.00000000.03092110.00000000.00000000.00000000.00200000.03092118.00000000.00000000.00000000.00010000',
                                'min-grant' => '00000040',
                                'subsystem-vendor-id' => '0000108e',
                                'max-frame-size' => '00010000',
                                'cache-line-size' => '00000010',
                                'class-code' => '00020000',
                                'local-mac-address' => '00144f7a.a3f3',
                                'vendor-id' => '000014e4',
                                'revision-id' => '000000a3',
                                'subsystem-id' => '00001668',
                                'latency-timer' => '00000040',
                                'address-bits' => '00000030',
                                'network-interface-type' => 'ethernet',
                                'device-id' => '00001668',
                                'assigned-addresses' => '82092110.00000000.04400000.00000000.00200000.82092118.00000000.04030000.00000000.00010000',
                                'device_type' => 'network',
                                'interrupts' => '00000002',
                                'name' => 'network',
                                'max-latency' => '00000000'
                            },
                            'ranges' => '82000000.00000000.04000000.82000000.00000000.04000000.00000000.00600000',
                            'compatible' => [
                                'pciex1166,103.b5',
                                'pciex1166,103',
                                'pciexclass,060400',
                                'pciexclass,0604'
                            ],
                            '0xf00c2bf0' => {
                                'devsel-speed' => '00000001',
                                'compatible' => [
                                    'pci14e4,1668.108e.1668.a3',
                                    'pci14e4,1668.108e.1668',
                                    'pci108e,1668',
                                    'pci14e4,1668.a3',
                                    'pci14e4,1668',
                                    'pciclass,020000',
                                    'pciclass,0200'
                                ],
                                'max-frame-size' => '00010000',
                                'subsystem-vendor-id' => '0000108e',
                                'min-grant' => '00000040',
                                'reg' => '00092000.00000000.00000000.00000000.00000000.03092010.00000000.00000000.00000000.00200000.03092018.00000000.00000000.00000000.00010000',
                                'latency-timer' => '00000040',
                                'subsystem-id' => '00001668',
                                'revision-id' => '000000a3',
                                'vendor-id' => '000014e4',
                                'local-mac-address' => '00144f7a.a3f2',
                                'class-code' => '00020000',
                                'cache-line-size' => '00000010',
                                'max-latency' => '00000000',
                                'name' => 'network',
                                'interrupts' => '00000001',
                                'device_type' => 'network',
                                'assigned-addresses' => '82092010.00000000.04200000.00000000.00200000.82092018.00000000.04010000.00000000.00010000.82092030.00000000.04020000.00000000.00010000',
                                'network-interface-type' => 'ethernet',
                                'device-id' => '00001668',
                                'address-bits' => '00000030'
                            },
                            'reg' => '00080000.00000000.00000000.00000000.00000000',
                            '#size-cells' => '00000002',
                            '#address-cells' => '00000003'
                        },
                        'device-id' => '00008532',
                        'reg' => '00034800.00000000.00000000.00000000.00000000',
                        'bus-range' => '00000008.0000000a',
                        'interrupts' => '00000001',
                        'device_type' => 'pciex',
                        '#address-cells' => '00000003',
                        'name' => 'pci'
                    },
                    'assigned-addresses' => '82020010.00000000.00100000.00000000.00020000',
                    'device-id' => '00008532',
                    'name' => 'pci',
                    'device_type' => 'pciex',
                    'interrupts' => '00000001',
                    'compatible' => [
                        'pciex10b5,8532.ba',
                        'pciex10b5,8532',
                        'pciexclass,060400',
                        'pciexclass,0604'
                    ],
                    'ranges' => '81000000.00000000.00000000.81000000.00000000.00000000.00000000.00003000.82000000.00000000.00200000.82000000.00000000.00200000.00000000.04e00000',
                    '0xf009cf20' => {
                        'device-id' => '00008532',
                        '#size-cells' => '00000002',
                        'reg' => '00030800.00000000.00000000.00000000.00000000',
                        'bus-range' => '00000004.00000005',
                        'interrupts' => '00000001',
                        'device_type' => 'pciex',
                        '#address-cells' => '00000003',
                        'name' => 'pci',
                        'cache-line-size' => '00000010',
                        'class-code' => '00060400',
                        '0xf009eea0' => {
                            '0xf00b4260' => {
                                'assigned-addresses' => '8205e310.00000000.00200000.00000000.00002000',
                                'device-id' => '00005239',
                                'name' => 'usb',
                                'max-latency' => '00000020',
                                'interrupts' => '00000004',
                                'class-code' => '000c0320',
                                'cache-line-size' => '00000010',
                                'latency-timer' => '00000040',
                                'subsystem-id' => '00005238',
                                'vendor-id' => '000010b9',
                                'revision-id' => '00000001',
                                'subsystem-vendor-id' => '000010b9',
                                'reg' => '0005e300.00000000.00000000.00000000.00000000.0205e310.00000000.00000000.00000000.00002000',
                                'min-grant' => '00000010',
                                'compatible' => [
                                    'pci10b9,5239.10b9.5238.2001',
                                    'pci10b9,5239.10b9.5238',
                                    'pci10b9,5238',
                                    'pci10b9,5239.2001',
                                    'pci10b9,5239',
                                    'pciclass,0c0320',
                                    'pciclass,0c03'
                                ],
                                'devsel-speed' => '00000001'
                            },
                            'compatible' => [
                                'pciex10b9,5249.0',
                                'pciex10b9,5249',
                                'pciexclass,060400',
                                'pciexclass,0604'
                            ],
                            'ranges' => '81000000.00000000.00001000.81000000.00000000.00001000.00000000.00001000.82000000.00000000.00200000.82000000.00000000.00200000.00000000.03e00000',
                            '#address-cells' => '00000003',
                            'interrupt-map-mask' => '0000ff00.00000000.00000000.00000007',
                            '#size-cells' => '00000002',
                            'reg' => '00040000.00000000.00000000.00000000.00000000',
                            '0xf00a0dfc' => {
                                'vendor-id' => '000010b9',
                                'revision-id' => '00000003',
                                'latency-timer' => '00000040',
                                'sunw,find-fcode' => 'f00a662c',
                                'subsystem-id' => '00005237',
                                'cache-line-size' => '00000010',
                                'class-code' => '000c0310',
                                'interrupts' => '00000001',
                                'max-latency' => '00000050',
                                'name' => 'usb',
                                'device-id' => '00005237',
                                'assigned-addresses' => '8205e010.00000000.01000000.00000000.01000000',
                                'compatible' => [
                                    'pci10b9,5237.10b9.5237.3',
                                    'pci10b9,5237.10b9.5237',
                                    'pci10b9,5237',
                                    'pci10b9,5237.3',
                                    'pci10b9,5237',
                                    'pciclass,0c0310',
                                    'pciclass,0c03'
                                ],
                                'devsel-speed' => '00000001',
                                'maximum-frame#' => '0000ffff',
                                '#address-cells' => '00000001',
                                'min-grant' => '00000000',
                                'reg' => '0005e000.00000000.00000000.00000000.00000000.0205e010.00000000.00000000.00000000.01000000',
                                '#size-cells' => '00000000',
                                'subsystem-vendor-id' => '000010b9'
                            },
                            '0xf00a74c8' => {
                                'maximum-frame#' => '0000ffff',
                                'devsel-speed' => '00000001',
                                'compatible' => [
                                    'pci10b9,5237.10b9.5237.3',
                                    'pci10b9,5237.10b9.5237',
                                    'pci10b9,5237',
                                    'pci10b9,5237.3',
                                    'pci10b9,5237',
                                    'pciclass,0c0310',
                                    'pciclass,0c03'
                                ],
                                '#address-cells' => '00000001',
                                '#size-cells' => '00000000',
                                'reg' => '0005e100.00000000.00000000.00000000.00000000.0205e110.00000000.00000000.00000000.01000000',
                                'min-grant' => '00000000',
                                'subsystem-vendor-id' => '000010b9',
                                'vendor-id' => '000010b9',
                                'revision-id' => '00000003',
                                'latency-timer' => '00000040',
                                'sunw,find-fcode' => 'f00accf8',
                                'subsystem-id' => '00005237',
                                'cache-line-size' => '00000010',
                                'class-code' => '000c0310',
                                'interrupts' => '00000002',
                                'max-latency' => '00000050',
                                'name' => 'usb',
                                'device-id' => '00005237',
                                'assigned-addresses' => '8205e110.00000000.02000000.00000000.01000000'
                            },
                            'revision-id' => '00000000',
                            'vendor-id' => '000010b9',
                            '#interrupt-cells' => '00000001',
                            'cache-line-size' => '00000010',
                            '0xf00b66dc' => {
                                'assigned-addresses' => '8105f810.00000000.00001040.00000000.00000040.8105f814.00000000.00001080.00000000.00000040.8105f818.00000000.000010c0.00000000.00000040.8105f81c.00000000.00001100.00000000.00000040.8105f820.00000000.00001000.00000000.00000040',
                                '0xf00ba0a4' => {
                                    'compatible' => 'ide-cdrom',
                                    'name' => 'cdrom',
                                    'device_type' => 'block'
                                },
                                'device-id' => '00005229',
                                'max-latency' => '00000000',
                                'name' => 'ide',
                                'interrupts' => '00000001',
                                'device_type' => 'ide',
                                'class-code' => '0001018f',
                                'cache-line-size' => '00000010',
                                'latency-timer' => '00000040',
                                'subsystem-id' => '00005229',
                                'vendor-id' => '000010b9',
                                'revision-id' => '000000c8',
                                'subsystem-vendor-id' => '000010b9',
                                'min-grant' => '00000000',
                                'reg' => '0005f800.00000000.00000000.00000000.00000000.0105f810.00000000.00000000.00000000.00000028.0105f814.00000000.00000000.00000000.00000024.0105f818.00000000.00000000.00000000.00000028.0105f81c.00000000.00000000.00000000.00000024.0105f820.00000000.00000000.00000000.00000030',
                                '0xf00b99b0' => {
                                    'compatible' => 'ide-disk',
                                    'name' => 'disk',
                                    'device_type' => 'block'
                                },
                                '#address-cells' => '00000002',
                                'devsel-speed' => '00000001',
                                'compatible' => [
                                    'pci10b9,5229.10b9.5229.c8',
                                    'pci10b9,5229.10b9.5229',
                                    'pci10b9,5229',
                                    'pci10b9,5229.c8',
                                    'pci10b9,5229',
                                    'pciclass,01018f',
                                    'pciclass,0101'
                                ]
                            },
                            'class-code' => '00060400',
                            '0xf00b4958' => {
                                'revision-id' => '00000000',
                                'vendor-id' => '000010b9',
                                'subsystem-id' => '00001575',
                                'latency-timer' => '00000040',
                                'cache-line-size' => '00000000',
                                'class-code' => '00060100',
                                'name' => 'isa',
                                'max-latency' => '00000018',
                                'device-id' => '00001575',
                                'assigned-addresses' => '8105f010.00000000.00000000.00000000.00001000',
                                '0xf00b57b4' => {
                                    'name' => 'rtc',
                                    'model' => 'm5823',
                                    'compatible' => 'isa-m5823p',
                                    'reg' => '00000000.00000070.00000004',
                                    'address' => 'fff06070'
                                },
                                'devsel-speed' => '00000001',
                                'ranges' => '00000000.00000000.8105f010.00000000.00000000.00001000',
                                '#address-cells' => '00000002',
                                '#size-cells' => '00000001',
                                'min-grant' => '00000001',
                                'reg' => '0005f000.00000000.00000000.00000000.00000000.8105f010.00000000.00000000.00000000.00001000',
                                'subsystem-vendor-id' => '000010b9'
                            },
                            'device_type' => 'pciex',
                            'available' => '81000000.00000000.00001140.00000000.00000ec0.82000000.00000000.00202000.00000000.00002000.82000000.00000000.00208000.00000000.00df8000',
                            'interrupt-map' => '0000e000.00000000.00000000.00000001.f0067c2c.00000000.0000e100.00000000.00000000.00000002.f0067c2c.00000000.0000e200.00000000.00000000.00000003.f0067c2c.00000000.0000e300.00000000.00000000.00000004.f0067c2c.00000001.0000f800.00000000.00000000.00000001.f0067c2c.00000004',
                            'name' => 'pci',
                            'device-id' => '00005249',
                            'bus-range' => '00000005.00000005'
                        },
                        'compatible' => [
                            'pciex10b5,8532.ba',
                            'pciex10b5,8532',
                            'pciexclass,060400',
                            'pciexclass,0604'
                        ],
                        'ranges' => '81000000.00000000.00000000.81000000.00000000.00000000.00000000.00002000.82000000.00000000.00200000.82000000.00000000.00200000.00000000.03e00000',
                        'revision-id' => '000000ba',
                        'vendor-id' => '000010b5'
                    },
                    '0xf00bac90' => {
                        'bus-range' => '00000006.00000006',
                        'physical-slot#' => '000000e2',
                        'reg' => '00031000.00000000.00000000.00000000.00000000',
                        'device-id' => '00008532',
                        '#size-cells' => '00000002',
                        'name' => 'pci',
                        'device_type' => 'pciex',
                        '#address-cells' => '00000003',
                        'interrupts' => '00000001',
                        'compatible' => [
                            'pciex10b5,8532.ba',
                            'pciex10b5,8532',
                            'pciexclass,060400',
                            'pciexclass,0604'
                        ],
                        'ranges' => '82000000.00000000.fff00000.82000000.00000000.fff00000.ffffffff.00200000',
                        'class-code' => '00060400',
                        'cache-line-size' => '00000010',
                        'revision-id' => '000000ba',
                        'vendor-id' => '000010b5'
                    },
                    '0xf00d26c8' => {
                        '#size-cells' => '00000002',
                        'device-id' => '00008532',
                        'reg' => '00035000.00000000.00000000.00000000.00000000',
                        '0xf00d4648' => {
                            'bus-range' => '0000000c.0000000d',
                            '0xf00d65a0' => {
                                'devsel-speed' => '00000001',
                                'compatible' => [
                                    'pci14e4,1668.108e.1668.a3',
                                    'pci14e4,1668.108e.1668',
                                    'pci108e,1668',
                                    'pci14e4,1668.a3',
                                    'pci14e4,1668',
                                    'pciclass,020000',
                                    'pciclass,0200'
                                ],
                                'max-frame-size' => '00010000',
                                'min-grant' => '00000040',
                                'reg' => '000c2000.00000000.00000000.00000000.00000000.030c2010.00000000.00000000.00000000.00200000.030c2018.00000000.00000000.00000000.00010000',
                                'subsystem-vendor-id' => '0000108e',
                                'vendor-id' => '000014e4',
                                'revision-id' => '000000a3',
                                'local-mac-address' => '00144f7a.a3f4',
                                'latency-timer' => '00000040',
                                'subsystem-id' => '00001668',
                                'cache-line-size' => '00000010',
                                'class-code' => '00020000',
                                'interrupts' => '00000001',
                                'device_type' => 'network',
                                'name' => 'network',
                                'max-latency' => '00000000',
                                'device-id' => '00001668',
                                'network-interface-type' => 'ethernet',
                                'address-bits' => '00000030',
                                'assigned-addresses' => '820c2010.00000000.04800000.00000000.00200000.820c2018.00000000.04610000.00000000.00010000.820c2030.00000000.04620000.00000000.00010000'
                            },
                            'device-id' => '00000103',
                            'name' => 'pci',
                            'available' => '82000000.00000000.04600000.00000000.00010000.82000000.00000000.04640000.00000000.001c0000',
                            '0xf00e3e9c' => {
                                '#address-cells' => '00000003',
                                'interrupt-map-mask' => '00000000.00000000.00000000.00000007',
                                '#size-cells' => '00000002',
                                'reg' => '000c4000.00000000.00000000.00000000.00000000',
                                '0xf00e5e5c' => {
                                    'latency-timer' => '000000f8',
                                    'subsystem-id' => '00003020',
                                    'model' => 'LSI,1064',
                                    'revision-id' => '00000002',
                                    'vendor-id' => '00001000',
                                    'wide' => '00000010',
                                    'class-code' => '00010000',
                                    'mpt-version' => '1.05',
                                    'cache-line-size' => '00000080',
                                    'max-latency' => '0000000a',
                                    'name' => 'scsi',
                                    'interrupts' => '00000001',
                                    'device_type' => 'scsi-2',
                                    'assigned-addresses' => '810d0810.00000000.00002000.00000000.00000100.820d0814.00000000.04c00000.00000000.00010000.820d081c.00000000.04c10000.00000000.00010000.820d0830.00000000.04e00000.00000000.00200000',
                                    'device-id' => '00000050',
                                    'local-wwid' => '50800200.00002999',
                                    'devsel-speed' => '00000001',
                                    '0xf00f1f98' => {
                                        'device_type' => 'byte',
                                        'name' => 'tape',
                                        'compatible' => 'st'
                                    },
                                    'compatible' => [
                                        'pci1000,50.1000.3020.2',
                                        'pci1000,50.1000.3020',
                                        'pci1000,3020',
                                        'pci1000,50.2',
                                        'pci1000,50',
                                        'pciclass,010000',
                                        'pciclass,0100'
                                    ],
                                    'version' => '1.00.40',
                                    '0xf00f2bd0' => {
                                        'device_type' => 'block',
                                        'name' => 'disk',
                                        'compatible' => 'sd'
                                    },
                                    'firmware-version' => '1.08.04.00',
                                    'subsystem-vendor-id' => '00001000',
                                    'min-grant' => '00000040',
                                    'reg' => '000d0800.00000000.00000000.00000000.00000000.010d0810.00000000.00000000.00000000.00000100.030d0814.00000000.00000000.00000000.00010000.030d081c.00000000.00000000.00000000.00010000.020d0830.00000000.00000000.00000000.00200000'
                                },
                                'devsel-speed' => '00000001',
                                'ranges' => '81000000.00000000.00002000.81000000.00000000.00002000.00000000.00001000.82000000.00000000.04c00000.82000000.00000000.04c00000.00000000.00400000',
                                'compatible' => [
                                    'pci1166,104.b4',
                                    'pci1166,104',
                                    'pciclass,060400',
                                    'pciclass,0604'
                                ],
                                'device_type' => 'pci',
                                'available' => '81000000.00000000.00002100.00000000.00000f00.82000000.00000000.04c20000.00000000.001e0000',
                                'interrupt-map' => '00000000.00000000.00000000.00000001.f0067c2c.0000000f.00000000.00000000.00000000.00000002.f0067c2c.00000010.00000000.00000000.00000000.00000003.f0067c2c.00000011.00000000.00000000.00000000.00000004.f0067c2c.00000012',
                                'name' => 'pci',
                                'device-id' => '00000104',
                                'bus-range' => '0000000d.0000000d',
                                'vendor-id' => '00001166',
                                'revision-id' => '000000b4',
                                '#interrupt-cells' => '00000001',
                                'latency-timer' => '00000040',
                                'cache-line-size' => '00000010',
                                'class-code' => '00060400'
                            },
                            'device_type' => 'pciex',
                            '0xf00dd228' => {
                                'subsystem-id' => '00001668',
                                'latency-timer' => '00000040',
                                'local-mac-address' => '00144f7a.a3f5',
                                'revision-id' => '000000a3',
                                'vendor-id' => '000014e4',
                                'class-code' => '00020000',
                                'cache-line-size' => '00000010',
                                'name' => 'network',
                                'max-latency' => '00000000',
                                'device_type' => 'network',
                                'interrupts' => '00000002',
                                'assigned-addresses' => '820c2110.00000000.04a00000.00000000.00200000.820c2118.00000000.04630000.00000000.00010000',
                                'address-bits' => '00000030',
                                'device-id' => '00001668',
                                'network-interface-type' => 'ethernet',
                                'compatible' => [
                                    'pci14e4,1668.108e.1668.a3',
                                    'pci14e4,1668.108e.1668',
                                    'pci108e,1668',
                                    'pci14e4,1668.a3',
                                    'pci14e4,1668',
                                    'pciclass,020000',
                                    'pciclass,0200'
                                ],
                                'devsel-speed' => '00000001',
                                'max-frame-size' => '00010000',
                                'subsystem-vendor-id' => '0000108e',
                                'min-grant' => '00000040',
                                'reg' => '000c2100.00000000.00000000.00000000.00000000.030c2110.00000000.00000000.00000000.00200000.030c2118.00000000.00000000.00000000.00010000'
                            },
                            'class-code' => '00060400',
                            'cache-line-size' => '00000010',
                            'vendor-id' => '00001166',
                            'revision-id' => '000000b5',
                            'reg' => '000b0000.00000000.00000000.00000000.00000000',
                            '#size-cells' => '00000002',
                            '#address-cells' => '00000003',
                            'ranges' => '81000000.00000000.00002000.81000000.00000000.00002000.00000000.00001000.82000000.00000000.04600000.82000000.00000000.04600000.00000000.00a00000',
                            'compatible' => [
                                'pciex1166,103.b5',
                                'pciex1166,103',
                                'pciexclass,060400',
                                'pciexclass,0604'
                            ]
                        },
                        'bus-range' => '0000000b.0000000d',
                        'interrupts' => '00000001',
                        '#address-cells' => '00000003',
                        'device_type' => 'pciex',
                        'name' => 'pci',
                        'cache-line-size' => '00000010',
                        'class-code' => '00060400',
                        'compatible' => [
                            'pciex10b5,8532.ba',
                            'pciex10b5,8532',
                            'pciexclass,060400',
                            'pciexclass,0604'
                        ],
                        'ranges' => '81000000.00000000.00002000.81000000.00000000.00002000.00000000.00001000.82000000.00000000.04600000.82000000.00000000.04600000.00000000.00a00000',
                        'vendor-id' => '000010b5',
                        'revision-id' => '000000ba'
                    },
                    'reg' => '00020000.00000000.00000000.00000000.00000000',
                    '#size-cells' => '00000002',
                    '#address-cells' => '00000003'
                },
                'compatible' => 'pciex108e,80f0',
                'ranges' => '00000000.00000000.00000000.000007f8.00000000.00000000.10000000.01000000.00000000.00000000.000007f8.10000000.00000000.10000000.02000000.00000000.00000000.000007f9.00000000.00000000.80000000.03000000.00000000.00000000.000007fc.00000000.00000000.80000000',
                'interrupts' => '0000003f.0000003e',
                'device_type' => 'pciex',
                'available' => '81000000.00000000.00003000.00000000.0000d000.82000000.00000000.00120000.00000000.000e0000.82000000.00000000.05000000.00000000.bb000000.82000000.00000000.e0000000.00000000.10000000',
                'msi-eq-size' => '00000080',
                'interrupt-map' => '00000000.00000000.00000000.00000001.f0067c2c.00000014.00000000.00000000.00000000.00000002.f0067c2c.00000015.00000000.00000000.00000000.00000003.f0067c2c.00000016.00000000.00000000.00000000.00000004.f0067c2c.00000017',
                'name' => 'pci',
                'msi-eq-devino' => '00000000.00000024.00000018',
                'module-manufacturer#' => '00000036',
                'msi-address-ranges' => '00000000.7fff0000.00010000.00000003.ffff0000.00010000',
                'bus-range' => '00000002.0000000d',
                'portid' => '0000001e',
                'msi-data-mask' => '000000ff',
                'module-revision#' => '00000003',
                '#interrupt-cells' => '00000001',
                'ino-bitmap' => 'fff7f817.ffffffff'
            },
            '0xf003ff44' => {
                'translations' => '00000000.00002000.00000000.009fe000.80000000.00002036.00000000.01000000.00000000.00400000.80000012.39800036.00000000.01800000.00000000.00400000.80000012.39400036.00000000.02000000.00000000.00800000.80000012.38800036.00000000.02800000.00000000.00200000.80000012.3f21a036.00000000.70000000.00000000.00002000.80000012.3f1da036.00000000.70002000.00000000.00002000.80000012.3f000036.00000000.70004000.00000000.0000c000.80000012.3f20c036.00000000.70010000.00000000.00004000.80000012.3f046036.00000000.70014000.00000000.0007c000.80000012.39004036.00000000.70090000.00000000.00008000.80000012.39c16036.00000000.70098000.00000000.00002000.80000012.3f002036.00000000.7009a000.00000000.00006000.80000012.332f4036.00000000.700a0000.00000000.00012000.80000012.332ba036.00000000.700b2000.00000000.00090000.80000012.330d0036.00000000.70142000.00000000.00016000.80000012.3307a036.00000000.70158000.00000000.0000e000.80000012.3306c036.00000000.70166000.00000000.00014000.80000012.33058036.00000000.7017a000.00000000.00010000.80000012.33032036.00000000.7018a000.00000000.0000a000.80000012.33018036.00000000.70194000.00000000.00018000.80000012.32ebc036.00000000.701ac000.00000000.0000c000.80000012.32ea2036.00000000.701b8000.00000000.0001c000.80000012.32e2c036.00000000.7be00000.00000000.00022000.80000012.32f1e036.00000000.7be22000.00000000.0001e000.80000012.32eec036.00000000.7be40000.00000000.0002a000.80000012.32e66036.00000000.7be6a000.00000000.00004000.80000012.32de6036.00000000.7be6e000.00000000.00004000.80000012.32dd8036.00000000.7be72000.00000000.0001a000.80000012.32db4036.00000000.f0000000.00000000.00080000.80000012.3ff800b6.00000000.f0080000.00000000.00010000.80000012.3ff200b6.00000000.f0090000.00000000.00010000.80000012.3ff100b6.00000000.f00a0000.00000000.00010000.80000012.3fef00b6.00000000.f00b0000.00000000.00010000.80000012.3fed00b6.00000000.f00c0000.00000000.00010000.80000012.3fec00b6.00000000.f00d0000.00000000.00010000.80000012.3feb00b6.00000000.f00e0000.00000000.00010000.80000012.3fea00b6.00000000.f00f0000.00000000.00010000.80000012.3fe800b6.00000000.f0100000.00000000.00010000.80000012.39c000b6.00000000.feb20000.00000000.00200000.800007ff.f000008e.00000000.fed20000.00000000.000f0000.80000400.0ff0008e.00000000.fee10000.00000000.000f0000.80000400.0f60008e.00000000.fef7a000.00000000.00004000.80000012.3f41c0b6.00000000.fef7e000.00000000.00042000.80000012.3f6a80b6.00000000.fff06000.00000000.00002000.800007f8.1000008e.00000000.fff08000.00000000.00002000.800007f9.0020408e.00000000.fff0a000.00000000.00004000.80000012.3fee80b6.00000000.fff0e000.00000000.00002000.800007f9.0020008e.00000000.fff10000.00000000.00004000.80000012.3feec0b6.00000000.fff14000.00000000.00002000.800007f9.0020008e.00000000.fff16000.00000000.00004000.80000012.3fde60b6.00000000.fff1a000.00000000.00002000.800007f9.0020008e.00000000.fff1e000.00000000.00002000.80000012.3ff080b6.00000000.fff22000.00000000.00002000.800007ff.f200008e.00000000.fff24000.00000000.00002000.80000012.3ff300b6.00000000.fff26000.00000000.00002000.80000012.3ff0e0b6.00000000.fff28000.00000000.00002000.800007ff.f100008e.00000000.fff2a000.00000000.00002000.80000012.3ff400b6.00000000.fff2c000.00000000.00002000.80000012.3ff460b6.00000000.fff2e000.00000000.00006000.80000012.3ff320b6.00000000.fff34000.00000000.00002000.800007ff.f300008e.00000000.fff36000.00000000.00002000.80000012.3effe0b6.00000000.fff38000.00000000.00002000.800007f6.0000008e.00000000.fff3a000.00000000.00004000.80000012.3ff380b6.00000000.fff3e000.00000000.00002000.80000400.0fc0008e.00000000.fff40000.00000000.00002000.800007f8.00d0808e.00000000.fff42000.00000000.00004000.80000012.3ff3c0b6.00000000.fff46000.00000000.00002000.80000400.0f40008e.00000000.fff48000.00000000.00004000.80000012.3ff420b6.00000000.fff4c000.00000000.00002000.80000400.0fd3008e.00000000.fff4e000.00000000.00002000.80000012.3ff600b6.00000000.fff54000.00000000.00016000.80000012.3ff480b6.00000000.fff6a000.00000000.00006000.80000012.3ff620b6.00000000.fff70000.00000000.00010000.80000012.3ff700b6.00000300.00002000.00000000.00002000.80000012.3f20a036.00000300.00004000.00000000.00002000.80000012.3f204036.00000300.00006000.00000000.00002000.80000012.3f202036.00000300.00008000.00000000.00002000.80000012.3f200036.00000300.0000a000.00000000.00002000.80000012.3f1fe036.00000300.0000c000.00000000.00004000.80000012.3f1fa036.00000300.00010000.00000000.00004000.80000012.3f1f0036.00000300.00014000.00000000.00002000.80000012.3f1e0036.00000300.00016000.00000000.00004000.80000012.3f1dc036.00000300.0001a000.00000000.00002000.80000012.3f1d8036.00000300.0001c000.00000000.00002000.80000012.3f1d6036.00000300.0001e000.00000000.00002000.80000012.3f1a4036.00000300.00020000.00000000.00002000.80000012.3f196036.00000300.00022000.00000000.00002000.80000012.3f194036.00000300.00024000.00000000.00002000.80000012.3f190036.00000300.00026000.00000000.00002000.80000012.3f17c036.00000300.00028000.00000000.00002000.80000012.3f16e036.00000300.0002a000.00000000.00002000.80000012.3f024036.00000300.0002c000.00000000.00002000.80000012.3f022036.00000300.0002e000.00000000.00002000.80000012.3f012036.00000300.00030000.00000000.00002000.80000012.3f010036.00000300.00032000.00000000.00002000.80000012.33266036.00000300.00034000.00000000.00002000.80000012.32f6c036.00000300.00036000.00000000.00002000.80000012.32ddc036.00000300.00038000.00000000.00002000.80000012.32c44036.00000300.00042000.00000000.00002000.80000012.3f1f8036.00000300.00044000.00000000.00002000.80000012.3f1f6036.00000300.00046000.00000000.00002000.80000012.3f1f4036.00000300.00048000.00000000.00002000.80000012.3f1ee036.00000300.0004a000.00000000.00002000.80000012.3f1ec036.00000300.0004c000.00000000.00002000.80000012.3f1ea036.00000300.0004e000.00000000.00002000.80000012.3f1e8036.00000300.00050000.00000000.00002000.80000012.3f1e6036.00000300.00052000.00000000.00002000.80000012.3f1e4036.00000300.00054000.00000000.00002000.80000012.3f1e2036.00000300.00056000.00000000.00002000.80000012.3f1b2036.00000300.00058000.00000000.00002000.80000012.3f1b0036.00000300.0005a000.00000000.00002000.80000012.3f1ae036.00000300.0005c000.00000000.00002000.80000012.3f1ac036.00000300.0005e000.00000000.00002000.80000012.3f192036.00000300.00060000.00000000.00002000.80000012.3f18e036.00000300.00062000.00000000.00002000.80000012.3f184036.00000300.00064000.00000000.00002000.80000012.3f180036.00000300.00066000.00000000.00002000.80000012.3f17e036.00000300.00068000.00000000.00002000.80000012.3f12a036.00000300.0006a000.00000000.00002000.80000012.3f02a036.00000300.0006c000.00000000.00002000.80000012.3f01c036.00000300.00082000.00000000.00002000.80000012.3f1d4036.00000300.00084000.00000000.00010000.80000012.3f1c4036.00000300.00094000.00000000.00010000.80000012.3f1b4036.00000300.000a4000.00000000.00002000.80000012.3f00e036.00000300.000a6000.00000000.00004000.80000012.3f014036.00000300.000aa000.00000000.00002000.80000012.3f01e036.00000300.000ac000.00000000.00004000.80000012.3f026036.00000300.000b0000.00000000.0000e000.80000012.3f02c036.00000300.000be000.00000000.00006000.80000012.3f040036.00000300.000c4000.00000000.00002000.80000012.3f16c036.00000300.000c6000.00000000.00002000.80000012.3f170036.00000300.000c8000.00000000.00002000.80000012.3f182036.00000300.000ca000.00000000.00008000.80000012.3f186036.00000300.000d2000.00000000.0000c000.80000012.3f198036.00000300.000de000.00000000.00006000.80000012.3f1a6036.00000300.000f8000.00000000.00014000.80000012.32e18036.00000300.0010c000.00000000.0000a000.80000012.33022036.00000300.00116000.00000000.0000a000.80000012.3f172036.00000300.00124000.00000000.00040000.80000012.3f12c036.00000300.00164000.00000000.00012000.80000012.3f118036.00000300.00176000.00000000.00062000.80000012.3f0b6036.00000300.001d8000.00000000.00050000.80000012.3f066036.00000300.00228000.00000000.00008000.80000012.3f05e036.00000300.00230000.00000000.00006000.80000012.3f058036.00000300.00236000.00000000.0000a000.80000012.3f04e036.00000300.0027c000.00000000.00004000.80000012.3f04a036.00000300.002a4000.00000000.00006000.80000012.3302c036.00000300.002aa000.00000000.00006000.80000012.332fa036.00000300.002b0000.00000000.00006000.80000012.39c10036.00000300.002b6000.00000000.00006000.80000012.3f03a036.00000300.002c0000.00000000.00100000.80000012.39c9e036.00000300.003c0000.00000000.00002000.80000012.3f020036.00000300.003c2000.00000000.00006000.80000012.332ee036.00000300.003c8000.00000000.00008000.80000012.332e6036.00000300.003d0000.00000000.00002000.80000012.39000036.00000300.003d2000.00000000.00006000.80000012.332e0036.00000300.003d8000.00000000.00014000.80000012.332cc036.00000300.003ec000.00000000.00004000.80000012.332b6036.00000300.003f0000.00000000.00008000.80000012.332ae036.00000300.003f8000.00000000.00006000.80000012.332a4036.00000300.003fe000.00000000.00002000.80000012.32fb8036.00000300.00c00000.00000000.00380000.80000012.39080036.00000300.00f80000.00000000.00100000.80000012.33300036.00000300.01080000.00000000.00080000.80000012.39c1e036.00000300.01138000.00000000.00008000.80000012.3f006036.00000300.01148000.00000000.00002000.80000012.32dce036.00000300.0114a000.00000000.00002000.80000012.32f4e036.00000300.0114c000.00000000.00002000.80000012.32fae036.00000300.0114e000.00000000.00002000.80000012.33006036.00000300.01150000.00000000.00006000.80000012.33052036.00000300.01156000.00000000.00006000.80000012.33260036.00000300.0115c000.00000000.00002000.80000012.33268036.00000300.0115e000.00000000.00018000.80000012.33282036.00000300.01176000.00000000.00002000.80000012.332a2036.00000300.01178000.00000000.00004000.80000012.332aa036.00000300.0117c000.00000000.00002000.80000012.39002036.00000300.0117e000.00000000.00002000.80000012.3f004036.00000300.01180000.00000000.00008000.80000012.3329a036.00000300.01188000.00000000.00018000.80000012.3326a036.00000300.011a0000.00000000.00100000.80000012.33160036.00000300.012a0000.00000000.00040000.80000012.33090036.00000300.01310000.00000000.00010000.80000012.33042036.00000300.01320000.00000000.00006000.80000012.33012036.00000300.01326000.00000000.0000a000.80000012.33008036.00000300.01330000.00000000.00004000.80000012.33002036.00000300.01334000.00000000.00006000.80000012.32ffc036.00000300.0133a000.00000000.00008000.80000012.32ff4036.00000300.01342000.00000000.00004000.80000012.32ff0036.00000300.01346000.00000000.00022000.80000012.32fce036.00000300.01368000.00000000.00014000.80000012.32fba036.00000300.0137c000.00000000.00008000.80000012.32fb0036.00000300.01384000.00000000.00006000.80000012.32fa8036.00000300.0138a000.00000000.00006000.80000012.32fa2036.00000300.013b4000.00000000.0000c000.80000012.32f74036.00000300.013c0000.00000000.0000c000.80000012.32f96036.00000300.013d0000.00000000.00016000.80000012.32f80036.00000300.013e6000.00000000.00006000.80000012.32f6e036.00000300.013ec000.00000000.0000c000.80000012.32f60036.00000300.013f8000.00000000.00004000.80000012.32f5c036.00000300.013fc000.00000000.0000c000.80000012.32f50036.00000300.01408000.00000000.00004000.80000012.32f4a036.00000300.0140c000.00000000.00006000.80000012.32f44036.00000300.01412000.00000000.00004000.80000012.32f40036.00000300.01416000.00000000.00006000.80000012.32f16036.00000300.0141c000.00000000.0000c000.80000012.32f0a036.00000300.01428000.00000000.00018000.80000012.32ed4036.00000300.0146a000.00000000.0000e000.80000012.32eae036.00000300.01480000.00000000.00004000.80000012.32e9e036.00000300.01484000.00000000.0000e000.80000012.32e90036.00000300.01492000.00000000.0001e000.80000012.32e48036.00000300.014b0000.00000000.00006000.80000012.32e12036.00000300.014b6000.00000000.00006000.80000012.32e0c036.00000300.014bc000.00000000.00008000.80000012.32e04036.00000300.014c4000.00000000.0000a000.80000012.32dfa036.00000300.014ce000.00000000.00006000.80000012.32df4036.00000300.014d4000.00000000.0000a000.80000012.32dea036.00000300.014de000.00000000.00008000.80000012.32dde036.00000300.014e6000.00000000.00008000.80000012.32dd0036.00000300.014ee000.00000000.00012000.80000012.32da2036.00000300.01500000.00000000.00008000.80000012.32d9a036.00000300.01508000.00000000.0000a000.80000012.32d90036.00000300.01512000.00000000.00008000.80000012.32d88036.00000300.0151a000.00000000.00142000.80000012.32c46036.00000300.0165c000.00000000.00002000.80000012.32c42036',
                'name' => 'virtual-memory',
                'page-size' => '00002000',
                'available' => 'fffff800.00000000.000007fc.00000000.00000700.05400000.000000ff.fac00000.00000300.0165e000.000003ff.fe9a2000.00000300.01478000.00000000.00008000.00000300.01440000.00000000.0002a000.00000300.013cc000.00000000.00004000.00000300.01390000.00000000.00024000.00000300.012e0000.00000000.00030000.00000300.01140000.00000000.00008000.00000300.01100000.00000000.00038000.00000300.00400000.00000000.00800000.00000300.002bc000.00000000.00004000.00000300.00280000.00000000.00024000.00000300.00240000.00000000.0003c000.00000300.00120000.00000000.00004000.00000300.000e4000.00000000.00014000.00000300.0006e000.00000000.00014000.00000300.0003a000.00000000.00008000.00000001.00000000.000002ff.00002000.00000000.ffff0000.00000000.0000e000.00000000.7be8c000.00000000.74174000.00000000.701d4000.00000000.0bc2c000.00000000.02a00000.00000000.6d600000.00000000.01c00000.00000000.00400000.00000000.01400000.00000000.00400000.00000000.00000000.00000000.01000000.00000000.fff20000.00000000.00002000.00000000.fff1c000.00000000.00002000.00000000.fff00000.00000000.00006000.00000000.fefc0000.00000000.00040000.00000000.fef00000.00000000.0007a000.00000000.f0800000.00000000.0e320000',
                'existing' => '00000000.00000000.00000800.00000000.fffff800.00000000.00000800.00000000'
                },
                'scsi-initiator-id' => '00000007',
                '0xf0096330' => {
                '0xf009878c' => {
                'device_type' => 'fru-prom',
                'name' => 'motherboard-fru-prom',
                'reg' => '00000000.000000a2',
                'compatible' => 'i2c-at24c64'
                },
                '0xf0097cd8' => {
                'reg' => '00000000.00000064',
                'compatible' => 'i2c-at24c64',
                'device_type' => 'fru-prom',
                'name' => 'sasbp-fru-prom'
                },
                'reg' => '00000400.0fd30000.00000000.00000040',
                '0xf0099678' => {
                'device_type' => 'fru-prom',
                'name' => 'riser-fru-prom',
                'reg' => '00000000.000000aa',
                'compatible' => 'i2c-at24c64'
                },
                'interrupt-map-mask' => '000000ff.000000ff.00000003',
                '0xf009a7c0' => {
                'reg' => '00000000.000000ee',
                'compatible' => 'i2c-at34c02',
                'name' => 'dimm-spd'
                },
                '0xf00986cc' => {
                'name' => 'gpio',
                'reg' => '00000000.00000080',
                'compatible' => 'i2c-pca9555'
                },
                '0xf00993cc' => {
                'compatible' => 'i2c-at24c64',
                'reg' => '00000000.000000a8',
                'name' => 'riser-fru-prom',
                'device_type' => 'fru-prom'
                },
                '0xf0099f00' => {
                'reg' => '00000000.000000e4',
                'compatible' => 'i2c-at34c02',
                'name' => 'dimm-spd'
                },
                '0xf0099924' => {
                'name' => 'hardware-monitor',
                'reg' => '00000000.000000b0',
                'compatible' => 'i2c-adt7462'
                },
                '0xf0098518' => {
                'compatible' => 'i2c-pcf8574',
                'reg' => '00000000.0000007e',
                'name' => 'ioexp'
                },
                'name' => 'i2c',
                'i2c-clock-val' => '0000000f',
                '0xf0098364' => {
                'compatible' => 'i2c-pcf8574',
                'reg' => '00000000.0000007c',
                'name' => 'ioexp'
                },
                '0xf0098a44' => {
                'name' => 'nvram',
                'device_type' => 'nvram',
                'compatible' => 'i2c-at24c64',
                'reg' => '00000000.000000a6'
                },
                '0xf009a440' => {
                'name' => 'dimm-spd',
                'reg' => '00000000.000000ea',
                'compatible' => 'i2c-at34c02'
                },
                '0xf009a600' => {
                'name' => 'dimm-spd',
                'compatible' => 'i2c-at34c02',
                'reg' => '00000000.000000ec'
                },
                '0xf0097f84' => {
                'compatible' => 'i2c-at34c02',
                'reg' => '00000000.0000006c',
                'name' => 'power-supply-fru-prom'
                },
                '#size-cells' => '00000000',
                '0xf009a0c0' => {
                    'compatible' => 'i2c-at34c02',
                    'reg' => '00000000.000000e6',
                    'name' => 'dimm-spd'
                },
                '0xf00999f0' => {
                    'reg' => '00000000.000000d0',
                    'compatible' => 'i2c-ds1307',
                    'name' => 'rscrtc'
                },
                '#address-cells' => '00000002',
                'compatible' => 'fire-i2c',
                '0xf0097a2c' => {
                    'reg' => '00000000.00000032',
                    'compatible' => 'i2c-at24c64',
                    'device_type' => 'fru-prom',
                    'name' => 'pdb-fru-prom'
                },
                '0xf0099ab0' => {
                    'name' => 'clock-generator',
                    'compatible' => 'i2c-ics9fg108',
                    'reg' => '00000000.000000dc'
                },
                '0xf0099b80' => {
                    'compatible' => 'i2c-at34c02',
                    'reg' => '00000000.000000e0',
                    'name' => 'dimm-spd'
                },
                '0xf009a280' => {
                    'name' => 'dimm-spd',
                    'compatible' => 'i2c-at34c02',
                    'reg' => '00000000.000000e8'
                },
                'portid' => '0000001f',
                '0xf0098174' => {
                    'reg' => '00000000.0000006e',
                    'compatible' => 'i2c-at34c02',
                    'name' => 'power-supply-fru-prom'
                },
                '0xf0098e28' => {
                    'reg' => '00000000.000000a6',
                    'name' => 'idprom',
                    'device_type' => 'idprom'
                },
                'interrupt-map' => '00000000.000000d0.00000001.f00705d0.00000006',
                'device_type' => 'i2c',
                'interrupts' => '00000001',
                '0xf0099d40' => {
                    'reg' => '00000000.000000e2',
                    'compatible' => 'i2c-at34c02',
                    'name' => 'dimm-spd'
                },
                '#interrupt-cells' => '00000001'
            },
            '#size-cells' => '00000002'
        }
    }
);

plan tests => scalar (keys %prtconf_tests);

foreach my $test (keys %prtconf_tests) {
    my $file = "resources/solaris/prtconf/$test";
    my $info = getPrtconfInfos(file => $file);
    cmp_deeply($info, $prtconf_tests{$test}, "$test prtconf parsing");
}
