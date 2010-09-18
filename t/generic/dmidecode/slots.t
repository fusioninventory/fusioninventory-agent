#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Slots;
use FusionInventory::Logger;
use Test::More;

my %tests = (
    'freebsd-6.2' => [
        {
            NAME        => 'PCI0',
            DESIGNATION => '1',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        }
    ],
    'linux-2.6' => [
        {
            NAME        => 'PCMCIA 0',
            DESIGNATION => 'Adapter 0, Socket 0',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PC Card (PCMCIA)'
        },
        {
            NAME        => 'MiniPCI',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit Other'
        }
    ],
    'openbsd-3.7' => [
        {
            NAME        => 'AGP',
            DESIGNATION => '32',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI1',
            DESIGNATION => '12',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI2',
            DESIGNATION => '11',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI3',
            DESIGNATION => '10',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI4',
            DESIGNATION => '9',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI5',
            DESIGNATION => '8',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME       => 'ISA',
            STATUS      => 'Unknown',
            DESCRIPTION => '16-bit ISA'
        },
        {
            NAME        => 'ISA',
            STATUS      => 'Unknown',
            DESCRIPTION => '16-bit ISA'
        },
        {
            NAME        => 'PCIx',
            DESIGNATION => '0',
            STATUS      => 'Unknown',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCIx',
            DESIGNATION => '0',
            STATUS      => 'Unknown',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCIx',
            DESIGNATION => '0',
            STATUS      => 'Unknown',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCIx',
            DESIGNATION => '0',
            STATUS      => 'Unknown',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCIx',
            DESIGNATION => '0',
            STATUS      => 'Unknown',
            DESCRIPTION => '32-bit PCI'
        }
    ],
    'openbsd-3.8' => [
        {
            NAME        => 'SLOT1',
            DESIGNATION => '1',
            STATUS      => 'Available',
            DESCRIPTION => '64-bit PCI'
        },
        {
            NAME        => 'SLOT2',
            STATUS      => 'Available',
            DESCRIPTION => '<OUT OF SPEC><OUT OF SPEC>'
        },
        {
            NAME        => 'SLOT3',
            STATUS      => 'Available',
            DESCRIPTION => '<OUT OF SPEC><OUT OF SPEC>'
        },
        {
            NAME        => 'SLOT4',
            DESIGNATION => '4',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'SLOT5',
            DESIGNATION => '5',
            STATUS      => 'In Use',
            DESCRIPTION => '64-bit PCI-X'
        },
        {
            NAME        => 'SLOT6',
            DESIGNATION => '6',
            STATUS      => 'Available',
            DESCRIPTION => '64-bit PCI-X'
        }
    ],
    'rhel-2.1' => [
        {
        },
        {
            DESCRIPTION => '32bit PCI'
        },
        {
            DESCRIPTION => '32bit PCI'
        },
        {
            DESCRIPTION => '32bit PCI'
        },
        {
            DESCRIPTION => '32bit PCI'
        },
        {
            DESCRIPTION => '32bit PCI'
        },
    ],
    'rhel-3.4' => [
        {
            NAME        => 'PCIE Slot #1',
            DESIGNATION => '1',
            STATUS      => 'Available',
            DESCRIPTION => 'PCI'
        },
        {
            NAME        => 'PCI/33 Slot #2',
            DESIGNATION => '2',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI/33 Slot #3',
            DESIGNATION => '3',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCIX 133 Slot #4',
            DESIGNATION => '4',
            STATUS      => 'Available',
            DESCRIPTION => '64-bit PCI-X'
        },
        {
            NAME        => 'PCIX100(ZCR) Slot #5',
            DESIGNATION => '5',
            STATUS      => 'Available',
            DESCRIPTION => '64-bit PCI-X'
        },
        {
            NAME        => 'PCIX100 Slot #6',
            DESIGNATION => '6',
            STATUS      => 'Available',
            DESCRIPTION => '64-bit PCI-X'
        }
    ],
    'rhel-4.3' => [
         {
            NAME        => 'PCI1',
            DESIGNATION => '1',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI6',
            DESIGNATION => '2',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'AGP',
            DESIGNATION => '8',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit AGP'
        },
        {
            NAME        => 'PCI2',
            DESIGNATION => '2',
            STATUS      => 'Available',
            DESCRIPTION => '64-bit PCI-X'
        },
          {
            NAME        => 'PCI3',
            DESIGNATION => '3',
            STATUS      => 'Available',
            DESCRIPTION => '64-bit PCI-X'
          },
          {
            NAME        => 'PCI4',
            DESIGNATION => '1',
            STATUS      => 'In Use',
            DESCRIPTION => '64-bit PCI-X'
          },
          {
            NAME        => 'PCI5',
            DESIGNATION => '2',
            STATUS      => 'Available',
            DESCRIPTION => '64-bit PCI-X'
          }
    ],
    'rhel-4.6' => [
        {
            NAME        => 'PCI Slot 1',
            DESIGNATION => '1',
            STATUS      => 'Available',
            DESCRIPTION => '64-bit PCI-X'
        },
        {
            NAME        => 'PCI Slot 2',
            DESIGNATION => '2',
            STATUS      => 'Available',
            DESCRIPTION => '64-bit PCI-X'
        },
        {
            NAME        => 'PCI Slot 3',
            DESIGNATION => '3',
            STATUS      => 'Available',
            DESCRIPTION => '64-bit PCI-X'
        },
        {
            NAME        => 'PCI-E Slot 4',
            STATUS      => 'Available',
            DESCRIPTION => '<OUT OF SPEC><OUT OF SPEC>'
        },
        {
            NAME        => 'PCI-E Slot 5',
            STATUS      => 'Available',
            DESCRIPTION => '<OUT OF SPEC><OUT OF SPEC>'
        },
        {
            NAME        => 'PCI-E Slot 6',
            STATUS      => 'Available',
            DESCRIPTION => '<OUT OF SPEC><OUT OF SPEC>'
        }
    ],
    'windows' => [
        {
            NAME        => 'PCMCIA0',
            DESIGNATION => 'Adapter 1, Socket 0',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PC Card (PCMCIA)'
        },
        {
            NAME        => 'PCMCIA1',
            DESIGNATION => 'Adapter 2, Socket 0',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PC Card (PCMCIA)'
        },
        {
            NAME        => 'SD CARD',
            STATUS      => 'In Use',
            DESCRIPTION => 'Other'
        }
    ]
);

plan tests => scalar keys %tests;

my $logger = FusionInventory::Logger->new();

foreach my $test (keys %tests) {
    my $file = "resources/dmidecode/$test";
    my $slots = FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Slots::_getSlots($logger, $file);
    is_deeply($slots, $tests{$test}, $test);
}
