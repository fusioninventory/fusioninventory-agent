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
    }
);

plan tests => scalar (keys %prtconf_tests);

foreach my $test (keys %prtconf_tests) {
    my $file = "resources/solaris/prtconf/$test";
    my $info = getPrtconfInfos(file => $file);
    cmp_deeply($info, $prtconf_tests{$test}, "$test prtconf parsing");
}
