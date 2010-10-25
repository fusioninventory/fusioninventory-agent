#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Tools::Unix;
use FusionInventory::Logger;
use Test::More;

my %lspci_tests = (
    'latitude-xt2' => [
        {
            PCICLASS     => '0600',
            NAME         => 'Host bridge',
            MANUFACTURER => 'Intel Corporation Mobile 4 Series Chipset Memory Controller Hub',
            VERSION      => '07',
            PCIID        => '8086:2a40',
            DRIVER       => 'agpgart',
            PCISLOT      => '00:00.0'
        },
        {
            PCICLASS     => '0300',
            NAME         => 'VGA compatible controller',
            MANUFACTURER => 'Intel Corporation Mobile 4 Series Chipset Integrated Graphics Controller',
            VERSION      => '07',
            PCIID        => '8086:2a42',
            DRIVER       => 'i915',
            PCISLOT      => '00:02.0'
        },
        {
            PCICLASS     => '0380',
            NAME         => 'Display controller',
            MANUFACTURER => 'Intel Corporation Mobile 4 Series Chipset Integrated Graphics Controller',
            VERSION      => '07',
            PCIID        => '8086:2a43',
            PCISLOT      => '00:02.1'
        },
        {
            PCICLASS     => '0200',
            NAME         => 'Ethernet controller',
            MANUFACTURER => 'Intel Corporation 82567LM Gigabit Network Connection',
            VERSION      => '03',
            PCIID        => '8086:10f5',
            DRIVER       => 'e1000e',
            PCISLOT      => '00:19.0'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB Controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #4',
            VERSION      => '03',
            PCIID        => '8086:2937',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1a.0'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB Controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #5',
            VERSION      => '03',
            PCIID        => '8086:2938',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1a.1'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB Controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #6',
            VERSION      => '03',
            PCIID        => '8086:2939',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1a.2'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB Controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #2',
            VERSION      => '03',
            PCIID        => '8086:293c',
            DRIVER       => 'ehci_hcd',
            PCISLOT      => '00:1a.7'
        },
        {
            PCICLASS     => '0403',
            NAME         => 'Audio device',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) HD Audio Controller',
            VERSION      => '03',
            PCIID        => '8086:293e',
            DRIVER       => 'HDA',
            PCISLOT      => '00:1b.0'
        },
        {
            PCICLASS     => '0604',
            NAME         => 'PCI bridge',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) PCI Express Port 1',
            VERSION      => '03',
            PCIID        => '8086:2940',
            DRIVER       => 'pcieport',
            PCISLOT      => '00:1c.0'
        },
        {
            PCICLASS     => '0604',
            NAME         => 'PCI bridge',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) PCI Express Port 2',
            VERSION      => '03',
            PCIID        => '8086:2942',
            DRIVER       => 'pcieport',
            PCISLOT      => '00:1c.1'
        },
        {
            PCICLASS     => '0604',
            NAME         => 'PCI bridge',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) PCI Express Port 4',
            VERSION      => '03',
            PCIID        => '8086:2946',
            DRIVER       => 'pcieport',
            PCISLOT      => '00:1c.3'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB Controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #1',
            VERSION      => '03',
            PCIID        => '8086:2934',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1d.0'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB Controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #2',
            VERSION      => '03',
            PCIID        => '8086:2935',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1d.1'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB Controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #3',
            VERSION      => '03',
            PCIID        => '8086:2936',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1d.2'
        },
        {
            PCICLASS     => '0c03',
            NAME         => 'USB Controller',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #1',
            VERSION      => '03',
            PCIID        => '8086:293a',
            DRIVER       => 'ehci_hcd',
            PCISLOT      => '00:1d.7'
        },
        {
            PCICLASS     => '0604',
            NAME         => 'PCI bridge',
            MANUFACTURER => 'Intel Corporation 82801 Mobile PCI Bridge',
            VERSION      => '93',
            PCIID        => '8086:2448',
            PCISLOT      => '00:1e.0'
        },
        {
            PCICLASS     => '0601',
            NAME         => 'ISA bridge',
            MANUFACTURER => 'Intel Corporation ICH9M-E LPC Interface Controller',
            VERSION      => '03',
            PCIID        => '8086:2917',
            PCISLOT      => '00:1f.0'
        },
        {
            PCICLASS     => '0104',
            NAME         => 'RAID bus controller',
            MANUFACTURER => 'Intel Corporation Mobile 82801 SATA RAID Controller',
            VERSION      => '03',
            PCIID        => '8086:282a',
            DRIVER       => 'ahci',
            PCISLOT      => '00:1f.2'
        },
        {
            PCICLASS     => '0c05',
            NAME         => 'SMBus',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) SMBus Controller',
            VERSION      => '03',
            PCIID        => '8086:2930',
            DRIVER       => 'i801_smbus',
            PCISLOT      => '00:1f.3'
        },
        {
            PCICLASS     => '0607',
            NAME         => 'CardBus bridge',
            MANUFACTURER => 'Texas Instruments PCIxx12 Cardbus Controller',
            VERSION      => undef,
            PCIID        => '104c:8039',
            DRIVER       => 'yenta_cardbus',
            PCISLOT      => '02:01.0'
        },
        {
            PCICLASS     => '0c00',
            NAME         => 'FireWire (IEEE 1394)',
            MANUFACTURER => 'Texas Instruments PCIxx12 OHCI Compliant IEEE 1394 Host Controller',
            VERSION      => undef,
            PCIID        => '104c:803a',
            DRIVER       => 'ohci1394',
            PCISLOT      => '02:01.1'
        },
        {
            PCICLASS     => '0805',
            NAME         => 'SD Host controller',
            MANUFACTURER => 'Texas Instruments PCIxx12 SDA Standard Compliant SD Host Controller',
            VERSION     => undef,
            PCIID       => '104c:803c',
            DRIVER      => 'sdhci',
            PCISLOT     => '02:01.3'
        },
        {
            PCICLASS     => '0280',
            NAME         => 'Network controller',
            MANUFACTURER => 'Intel Corporation Wireless WiFi Link 5100',
            VERSION      => undef,
            PCIID        => '8086:4232',
            DRIVER       => 'iwlagn',
            PCISLOT      => '0c:00.0'
        }
    ]
);

my %df_tests = (
    'freebsd' => [
        {
            VOLUMN     => '/dev/ad4s1a',
            TOTAL      => '1447',
            FREE       => '965',
            TYPE       => '/',
            FILESYSTEM => 'ufs'
        },
        {
            VOLUMN     => '/dev/ad4s1g',
            TOTAL      => '138968',
            FREE       => '12851',
            TYPE       => '/Donnees',
            FILESYSTEM => 'ufs'
        },
        {
            VOLUMN     => '/dev/ad4s1e',
            TOTAL      => '495',
            FREE       => '397',
            TYPE       => '/tmp',
            FILESYSTEM => 'ufs'
        },
        {
            VOLUMN     => '/dev/ad4s1f',
            TOTAL      => '19832',
            FREE       => '5118',
            TYPE       => '/usr',
            FILESYSTEM => 'ufs'
        },
        {
            VOLUMN     => '/dev/ad4s1d',
            TOTAL      => '3880',
            FREE       => '2571',
            TYPE       => '/var',
            FILESYSTEM => 'ufs'
        }
    ],
    'linux' => [
        {
            VOLUMN     => '/dev/sda5',
            TOTAL      => '12106',
            FREE       => '6528',
            TYPE       => '/',
            FILESYSTEM => 'ext4'
        },
        {
            VOLUMN     => '/dev/sda3',
            TOTAL      => '60002',
            FREE       => '40540',
            TYPE       => '/media/windows',
            FILESYSTEM => 'fuseblk'
        },
        {
            VOLUMN     => '/dev/sda7',
            TOTAL      => '44110',
            FREE       => '21930',
            TYPE       => '/home',
            FILESYSTEM => 'crypt'
        }
    ],
    'netbsd' => [
          {
            VOLUMN     => '/dev/wd0a',
            TOTAL      => '15112',
            FREE       => '3581',
            TYPE       => '/',
            FILESYSTEM => undef
          }
    ],
    'openbsd' => [
        {
            VOLUMN     => '/dev/wd0a',
            TOTAL      => '784',
            FREE       => '174',
            TYPE       => '/',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/wd0e',
            TOTAL      => '251',
            FREE       => '239',
            TYPE       => '/home',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/wd0d',
            TOTAL      => '892',
            FREE       => '224',
            TYPE       => '/usr',
            FILESYSTEM => undef
        }
    ],
    'aix' => [
        {
            VOLUMN     => '/dev/hd4',
            TOTAL      => '2048',
            FREE       => '1065',
            TYPE       => '/',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/hd2',
            TOTAL      => '4864',
            FREE       => '2704',
            TYPE       => '/usr',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/hd9var',
            TOTAL      => '256',
            FREE       => '177',
            TYPE       => '/var',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/hd3',
            TOTAL      => '4096',
            FREE       => '837',
            TYPE       => '/tmp',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/fwdump',
            TOTAL      => '128',
            FREE       => '127',
            TYPE       => '/var/adm/ras/platform',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/hd1',
            TOTAL      => '2048',
            FREE       => '1027',
            TYPE       => '/home',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/hd11admin',
            TOTAL      => '128',
            FREE       => '127',
            TYPE       => '/admin',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/hd10opt',
            TOTAL      => '128',
            FREE       => '13',
            TYPE       => '/opt',
            FILESYSTEM => undef
        }
    ]
);

my @dhcp_leases_test = (
    {
        file => 'dhclient-wlan0-1.lease',
        result => '192.168.0.254',
        if => 'wlan0'
    },
    {
        file => 'dhclient-wlan0-2.lease',
        result => '192.168.10.1',
        if => 'wlan0'
    },
);


plan tests =>
    (scalar keys %lspci_tests) +
    (scalar keys %df_tests) +
    (scalar @dhcp_leases_test);

my $logger = FusionInventory::Logger->new();

foreach my $test (keys %lspci_tests) {
    my $file = "resources/lspci/$test";
    my $controllers = getControllersFromLspci(file => $file);
    is_deeply($controllers, $lspci_tests{$test}, "$test lspci parsing");
}

foreach my $test (keys %df_tests) {
    my $file = "resources/df/$test";
    my @infos = getFilesystemsFromDf(file => $file);
    is_deeply(\@infos, $df_tests{$test}, "$test df parsing");
}

foreach my $test (@dhcp_leases_test) {
    my $server = FusionInventory::Agent::Tools::Unix::_parseDhcpLeaseFile(undef, $test->{if}, "resources/dhcp/".$test->{file});
    ok(
        $server && ($server eq $test->{result}),
        "Parse DHCP lease"
    );
}
