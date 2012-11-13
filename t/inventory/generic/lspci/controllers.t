#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Generic::Lspci::Controllers;

my %tests = (
    'dell-xt2' => [
        {
            NAME         => 'Mobile 4 Series Chipset Memory Controller Hub',
            TYPE         => 'Host bridge',
            CAPTION      => 'Mobile 4 Series Chipset Memory Controller Hub',
            DRIVER       => 'agpgart',
            PCISLOT      => '00:00.0',
            PCICLASS     => '0600',
            MANUFACTURER => 'Intel Corporation',
            REV          => '07',
            PCIID        => '8086:2a40'
        },
        {
            NAME         => 'Mobile 4 Series Chipset Integrated Graphics Controller',
            TYPE         => 'VGA compatible controller',
            CAPTION      => 'Mobile 4 Series Chipset Integrated Graphics Controller',
            DRIVER       => 'i915',
            PCISLOT      => '00:02.0',
            PCICLASS     => '0300',
            MANUFACTURER => 'Intel Corporation',
            REV          => '07',
            PCIID        => '8086:2a42'
        },
        {
            NAME         => 'Mobile 4 Series Chipset Integrated Graphics Controller',
            TYPE         => 'Display controller',
            CAPTION      => 'Mobile 4 Series Chipset Integrated Graphics Controller',
            PCISLOT      => '00:02.1',
            PCICLASS     => '0380',
            MANUFACTURER => 'Intel Corporation',
            REV          => '07',
            PCIID        => '8086:2a43'
        },
        {
            NAME         => '82567LM Gigabit Network Connection',
            TYPE         => 'Ethernet controller',
            CAPTION      => '82567LM Gigabit Network Connection',
            DRIVER       => 'e1000e',
            PCISLOT      => '00:19.0',
            PCICLASS     => '0200',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:10f5'
        },
        {
            NAME         => '82801I (ICH9 Family) USB UHCI Controller #4',
            TYPE         => 'USB controller',
            CAPTION      => '82801I (ICH9 Family) USB UHCI Controller #4',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1a.0',
            PCICLASS     => '0c03',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:2937'
        },
        {
            NAME         => '82801I (ICH9 Family) USB UHCI Controller #5',
            TYPE         => 'USB controller',
            CAPTION      => '82801I (ICH9 Family) USB UHCI Controller #5',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1a.1',
            PCICLASS     => '0c03',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:2938'
        },
        {
            NAME         => '82801I (ICH9 Family) USB UHCI Controller #6',
            TYPE         => 'USB controller',
            CAPTION      => '82801I (ICH9 Family) USB UHCI Controller #6',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1a.2',
            PCICLASS     => '0c03',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:2939'
        },
        {
            NAME         => '82801I (ICH9 Family) USB2 EHCI Controller #2',
            TYPE         => 'USB controller',
            CAPTION      => '82801I (ICH9 Family) USB2 EHCI Controller #2',
            DRIVER       => 'ehci_hcd',
            PCISLOT      => '00:1a.7',
            PCICLASS     => '0c03',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:293c'
        },
        {
            NAME         => '82801I (ICH9 Family) HD Audio Controller',
            TYPE         => 'Audio device',
            CAPTION      => '82801I (ICH9 Family) HD Audio Controller',
            DRIVER       => 'snd_hda_intel',
            PCISLOT      => '00:1b.0',
            PCICLASS     => '0403',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:293e'
        },
        {
            NAME         => '82801I (ICH9 Family) PCI Express Port 1',
            TYPE         => 'PCI bridge',
            CAPTION      => '82801I (ICH9 Family) PCI Express Port 1',
            DRIVER       => 'pcieport',
            PCISLOT      => '00:1c.0',
            PCICLASS     => '0604',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:2940'
        },
        {
            NAME         => '82801I (ICH9 Family) PCI Express Port 2',
            TYPE         => 'PCI bridge',
            CAPTION      => '82801I (ICH9 Family) PCI Express Port 2',
            DRIVER       => 'pcieport',
            PCISLOT      => '00:1c.1',
            PCICLASS     => '0604',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:2942'
        },
        {
            NAME         => '82801I (ICH9 Family) PCI Express Port 4',
            TYPE         => 'PCI bridge',
            CAPTION      => '82801I (ICH9 Family) PCI Express Port 4',
            DRIVER       => 'pcieport',
            PCISLOT      => '00:1c.3',
            PCICLASS     => '0604',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:2946'
        },
        {
            NAME         => '82801I (ICH9 Family) USB UHCI Controller #1',
            TYPE         => 'USB controller',
            CAPTION      => '82801I (ICH9 Family) USB UHCI Controller #1',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1d.0',
            PCICLASS     => '0c03',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:2934'
        },
        {
            NAME         => '82801I (ICH9 Family) USB UHCI Controller #2',
            TYPE         => 'USB controller',
            CAPTION      => '82801I (ICH9 Family) USB UHCI Controller #2',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1d.1',
            PCICLASS     => '0c03',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:2935'
        },
        {
            NAME         => '82801I (ICH9 Family) USB UHCI Controller #3',
            TYPE         => 'USB controller',
            CAPTION      => '82801I (ICH9 Family) USB UHCI Controller #3',
            DRIVER       => 'uhci_hcd',
            PCISLOT      => '00:1d.2',
            PCICLASS     => '0c03',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:2936'
        },
        {
            NAME         => '82801I (ICH9 Family) USB2 EHCI Controller #1',
            TYPE         => 'USB controller',
            CAPTION      => '82801I (ICH9 Family) USB2 EHCI Controller #1',
            DRIVER       => 'ehci_hcd',
            PCISLOT      => '00:1d.7',
            PCICLASS     => '0c03',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:293a'
        },
        {
            NAME         => '82801 Mobile PCI Bridge',
            TYPE         => 'PCI bridge',
            CAPTION      => '82801 Mobile PCI Bridge',
            PCISLOT      => '00:1e.0',
            PCICLASS     => '0604',
            MANUFACTURER => 'Intel Corporation',
            REV          => '93',
            PCIID        => '8086:2448'
        },
        {
            NAME         => 'ICH9M-E LPC Interface Controller',
            TYPE         => 'ISA bridge',
            CAPTION      => 'ICH9M-E LPC Interface Controller',
            PCISLOT      => '00:1f.0',
            PCICLASS     => '0601',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:2917'
        },
        {
            NAME         => '82801I (ICH9 Family) SMBus Controller',
            TYPE         => 'SMBus',
            CAPTION      => '82801I (ICH9 Family) SMBus Controller',
            DRIVER       => 'i801_smbus',
            PCISLOT      => '00:1f.3',
            PCICLASS     => '0c05',
            MANUFACTURER => 'Intel Corporation',
            REV          => '03',
            PCIID        => '8086:2930'
        },
        {
            NAME         => 'PCIxx12 Cardbus Controller',
            TYPE         => 'CardBus bridge',
            CAPTION      => 'PCIxx12 Cardbus Controller',
            DRIVER       => 'yenta_cardbus',
            PCISLOT      => '02:01.0',
            PCICLASS     => '0607',
            MANUFACTURER => 'Texas Instruments',
            REV          => undef,
            PCIID        => '104c:8039'
        },
        {
            NAME         => 'PCIxx12 OHCI Compliant IEEE 1394 Host Controller',
            TYPE         => 'FireWire (IEEE 1394)',
            CAPTION      => 'PCIxx12 OHCI Compliant IEEE 1394 Host Controller',
            DRIVER       => 'firewire_ohci',
            PCISLOT      => '02:01.1',
            PCICLASS     => '0c00',
            MANUFACTURER => 'Texas Instruments',
            REV          => undef,
            PCIID        => '104c:803a'
        },
        {
            NAME         => 'PCIxx12 SDA Standard Compliant SD Host Controller',
            TYPE         => 'SD Host controller',
            CAPTION      => 'PCIxx12 SDA Standard Compliant SD Host Controller',
            DRIVER       => 'sdhci',
            PCISLOT      => '02:01.3',
            PCICLASS     => '0805',
            MANUFACTURER => 'Texas Instruments',
            REV          => undef,
            PCIID        => '104c:803c'
        },
        {
            NAME         => 'WiFi Link 5100',
            TYPE         => 'Network controller',
            CAPTION      => 'WiFi Link 5100',
            DRIVER       => 'iwlwifi',
            PCISLOT      => '0c:00.0',
            PCICLASS     => '0280',
            MANUFACTURER => 'Intel Corporation',
            REV          => undef,
            PCIID        => '8086:4232'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/generic/lspci/$test";
    my @controllers = FusionInventory::Agent::Task::Inventory::Input::Generic::Lspci::Controllers::_getControllers(file => $file, datadir => 'share');
    is_deeply(\@controllers, $tests{$test}, $test);
}
