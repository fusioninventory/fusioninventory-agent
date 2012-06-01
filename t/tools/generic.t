#!/usr/bin/perl

use strict;
use warnings;

use Config;
use File::Temp;
use Test::More;

use FusionInventory::Agent::Tools::Generic;

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
            SPEED          => '3200',
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
            SPEED          => '3200',
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
            SPEED          => '4800',
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
    'openbsd-3.7' => [
        {
            ID             => '52 06 00 00 FF F9 83 01',
            NAME           => 'Pentium II',
            EXTERNAL_CLOCK => '100',
            SPEED          => '500',
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
            SPEED          => '3600',
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
            SPEED          => '3200',
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
            NAME           => '<OUT OF SPEC>',
            EXTERNAL_CLOCK => '266',
            SPEED          => '2400',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'Intel(R) Corporation',
            STEPPING       => '6',
            FAMILYNUMBER   => '6',
            MODEL          => '15',
            FAMILYNAME     => '<OUT OF SPEC>',
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
            SPEED          => '1800',
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
            FAMILYNAME     => 'Unknown',
            CORE           => undef
        },
        {
            ID             => '12 0F 00 00 FF FB 8B 07',
            NAME           => 'Unknown',
            SPEED          => '2133',
            THREAD         => undef,
            SERIAL         => undef,
            MANUFACTURER   => 'GenuineIntel',
            STEPPING       => '2',
            FAMILYNUMBER   => '15',
            MODEL          => '1',
            FAMILYNAME     => 'Unknown',
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
            FAMILYNAME     => 'Unknown',
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
            SPEED          => '3733',
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
    ]
);

plan tests =>
    (scalar keys %cpu_tests)       +
    (scalar keys %lspci_tests);

foreach my $test (keys %cpu_tests) {
    my $file = "resources/generic/dmidecode/$test";
    my @cpus = getCpusFromDmidecode(file => $file);
    is_deeply(\@cpus, $cpu_tests{$test}, "$test dmidecode cpu extraction");
}

foreach my $test (keys %lspci_tests) {
    my $file = "resources/generic/lspci/$test";
    my @devices = getPCIDevices(file => $file);
    is_deeply(\@devices, $lspci_tests{$test}, "$test lspci parsing");
}
