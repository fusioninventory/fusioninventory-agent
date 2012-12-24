#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Generic::Dmidecode::Slots;

my %tests = (
    'freebsd-6.2' => [
        {
            NAME        => 'PCI0',
            DESIGNATION => '1',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        }
    ],
    'freebsd-8.1' => [
        {
            NAME        => 'J5C1',
            DESIGNATION => undef,
            STATUS      => 'Available',
            DESCRIPTION => 'x16 PCI Express x16'
        },
        {
            NAME        => 'J6C1',
            DESIGNATION => undef,
            STATUS      => 'Available',
            DESCRIPTION => 'x1 PCI Express x1'
        },
        {
            NAME        => 'J6C2',
            DESIGNATION => undef,
            STATUS      => 'Available',
            DESCRIPTION => 'x1 PCI Express x1'
        },
        {
            NAME        => 'J6D2',
            DESIGNATION => undef,
            STATUS      => 'Available',
            DESCRIPTION => 'x1 PCI Express x1'
        },
        {
            NAME        => 'J7C1',
            DESIGNATION => undef,
            STATUS      => 'Available',
            DESCRIPTION => 'x1 PCI Express x1'
        },
        {
            NAME        => 'J7D2',
            DESIGNATION => undef,
            STATUS      => 'Available',
            DESCRIPTION => 'x1 PCI Express x1'
        },
        {
            NAME        => 'J8C2',
            DESIGNATION => undef,
            STATUS      => 'Available',
            DESCRIPTION => 'x16 PCI Express x16'
        },
        {
            NAME        => 'J8C1',
            DESIGNATION => undef,
            STATUS      => 'Available',
            DESCRIPTION => 'x1 PCI Express x1'
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
            DESCRIPTION => '32-bit Other',
            DESIGNATION => undef
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
            DESCRIPTION => '16-bit ISA',
            DESIGNATION => undef
        },
        {
            NAME        => 'ISA',
            STATUS      => 'Unknown',
            DESCRIPTION => '16-bit ISA',
            DESIGNATION => undef
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
            DESCRIPTION => '<OUT OF SPEC><OUT OF SPEC>',
            DESIGNATION => undef
        },
        {
            NAME        => 'SLOT3',
            STATUS      => 'Available',
            DESCRIPTION => '<OUT OF SPEC><OUT OF SPEC>',
            DESIGNATION => undef
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
            NAME        => undef,
            DESIGNATION => undef,
            STATUS      => undef,
            DESCRIPTION => undef
        },
        {
            NAME        => undef,
            DESIGNATION => undef,
            STATUS      => undef,
            DESCRIPTION => '32bit PCI'
        },
        {
            NAME        => undef,
            DESIGNATION => undef,
            STATUS      => undef,
            DESCRIPTION => '32bit PCI'
        },
        {
            NAME        => undef,
            DESIGNATION => undef,
            STATUS      => undef,
            DESCRIPTION => '32bit PCI'
        },
        {
            NAME        => undef,
            DESIGNATION => undef,
            STATUS      => undef,
            DESCRIPTION => '32bit PCI'
        },
        {
            NAME        => undef,
            DESIGNATION => undef,
            STATUS      => undef,
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
            DESCRIPTION => '<OUT OF SPEC><OUT OF SPEC>',
            DESIGNATION => undef,
        },
        {
            NAME        => 'PCI-E Slot 5',
            STATUS      => 'Available',
            DESCRIPTION => '<OUT OF SPEC><OUT OF SPEC>',
            DESIGNATION => undef,
        },
        {
            NAME        => 'PCI-E Slot 6',
            STATUS      => 'Available',
            DESCRIPTION => '<OUT OF SPEC><OUT OF SPEC>',
            DESIGNATION => undef,
        }
    ],
    'hp-dl180' => [
        {
            NAME        => 'SLOT1',
            DESIGNATION => '1',
            STATUS      => 'In Use',
            DESCRIPTION => 'x16 PCI Express'
        },
        {
            NAME        => 'SLOT2',
            DESIGNATION => '2',
            STATUS      => 'Available',
            DESCRIPTION => 'x16 PCI Express'
        },
        {
            NAME        => 'SLOT3',
            DESIGNATION => '3',
            STATUS      => 'Available',
            DESCRIPTION => 'x4 PCI Express'
        }
    ],
    'linux-1' => [
        {
            NAME        => 'PCIEX16_1',
            DESIGNATION => '1',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PCI Express'
        },
        {
            NAME        => 'PCIEX1_1',
            DESIGNATION => '5',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI Express'
        },
        {
            NAME        => 'PCIEX1_2',
            DESIGNATION => '6',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI Express'
        },
        {
            NAME        => 'PCI_1',
            DESIGNATION => '2',
            STATUS      => 'In Use',
            DESCRIPTION => '64-bit PCI Express'
        },
        {
            NAME        => 'PCI_2',
            DESIGNATION => '3',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI_3',
            DESIGNATION => '4',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PCI'
        }
    ],
    'openbsd-4.5' => [
        {
            NAME        => 'PCI1',
            DESIGNATION => '1',
            STATUS      => 'In Use',
            DESCRIPTION => '64-bit PCI-66'
        },
        {
            NAME        => 'PCI2',
            DESIGNATION => '2',
            STATUS      => 'In Use',
            DESCRIPTION => '64-bit PCI-66'
        },
        {
            NAME        => 'PCI3',
            DESIGNATION => '3',
            STATUS      => 'In Use',
            DESCRIPTION => '64-bit PCI-X'
        },
        {
            NAME        => 'PCI4',
            DESIGNATION => '4',
            STATUS      => 'In Use',
            DESCRIPTION => '64-bit PCI-X'
        },
        {
            NAME        => 'PCI5',
            DESIGNATION => '5',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI6',
            DESIGNATION => '6',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PCI'
        }
    ],
    'S3000AHLX' => [
        {
            NAME        => 'SLOT 6 PCI-E X8/PCI RISER EXPANSION SLOT 64/100',
            DESIGNATION => '6',
            STATUS      => 'Available',
            DESCRIPTION => 'x8 PCI Express'
        },
        {
            NAME        => 'SLOT 5 PCI-X 64/133',
            DESIGNATION => '5',
            STATUS      => 'In Use',
            DESCRIPTION => '64-bit PCI-X'
        },
        {
            NAME        => 'SLOT 3 PCI-E',
            DESIGNATION => '3',
            STATUS      => 'Available',
            DESCRIPTION => 'x1 PCI Express'
        },
        {
            NAME        => 'PCI SLOT 2 PCI 32/33',
            DESIGNATION => '2',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI SLOT 1 PCI 32/33',
            DESIGNATION => '1',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        }
    ],
    S5000VSA => [
        {
            NAME        => 'PCI SLOT1',
            DESIGNATION => '1',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI-E SLOT3',
            DESIGNATION => '3',
            STATUS      => 'Available',
            DESCRIPTION => 'x4 PCI Express'
        },
        {
            NAME        => 'PCI-X SLOT4',
            DESIGNATION => '4',
            STATUS      => 'Available',
            DESCRIPTION => '64-bit PCI-X'
        },
        {
            NAME        => 'PCI-X SLOT5',
            DESIGNATION => '5',
            STATUS      => 'In Use',
            DESCRIPTION => '64-bit PCI-X'
        },
        {
            NAME        => 'PCI-E SLOT6',
            DESIGNATION => '6',
            STATUS      => 'Available',
            DESCRIPTION => 'x4 PCI Express'
        }
    ],
    'vmware' => [
        {
            NAME        => 'ISA Slot J8',
            DESIGNATION => undef,
            STATUS      => 'Unknown',
            DESCRIPTION => '16-bit ISA'
        },
        {
            NAME        => 'ISA Slot J9',
            DESIGNATION => undef,
            STATUS      => 'Unknown',
            DESCRIPTION => '16-bit ISA'
        },
        {
            NAME        => 'ISA Slot J10',
            DESIGNATION => undef,
            STATUS      => 'Unknown',
            DESCRIPTION => '16-bit ISA'
        },
        {
            NAME        => 'PCI Slot J11',
            DESIGNATION => '1',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI Slot J12',
            DESIGNATION => '2',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI Slot J13',
            DESIGNATION => '3',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI Slot J14',
            DESIGNATION => '4',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        }
    ],
    'vmware-esx' => [
        {
            NAME        => 'ISA Slot J8',
            DESIGNATION => undef,
            STATUS      => 'Unknown',
            DESCRIPTION => '16-bit ISA'
        },
        {
            NAME        => 'ISA Slot J9',
            DESIGNATION => undef,
            STATUS      => 'Unknown',
            DESCRIPTION => '16-bit ISA'
        },
        {
            NAME        => 'ISA Slot J10',
            DESIGNATION => undef,
            STATUS      => 'Unknown',
            DESCRIPTION => '16-bit ISA'
        },
        {
            NAME        => 'PCI Slot J11',
            DESIGNATION => '1',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI Slot J12',
            DESIGNATION => '2',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI Slot J13',
            DESIGNATION => '3',
            STATUS      => 'In Use',
            DESCRIPTION => '32-bit PCI'
        },
        {
            NAME        => 'PCI Slot J14',
            DESIGNATION => '4',
            STATUS      => 'Available',
            DESCRIPTION => '32-bit PCI'
        }
    ],
    'vmware-esx-2.5' => [
        {
            NAME        => undef,
            DESIGNATION => undef,
            STATUS      => undef,
            DESCRIPTION => '16bit Long ISA'
        },
        {
            NAME        => undef,
            DESIGNATION => undef,
            STATUS      => undef,
            DESCRIPTION => '16bit Long ISA'
        },
        {
            NAME        => undef,
            DESIGNATION => undef,
            STATUS      => undef,
            DESCRIPTION => '16bit Long ISA'
        },
        {
            NAME        => undef,
            DESIGNATION => undef,
            STATUS      => undef,
            DESCRIPTION => '32bit PCI'
        },
        {
            NAME        => undef,
            DESIGNATION => undef,
            STATUS      => undef,
            DESCRIPTION => '32bit PCI'
        },
        {
            NAME        => undef,
            DESIGNATION => undef,
            STATUS      => undef,
            DESCRIPTION => '32bit PCI'
        },
        {
            NAME        => undef,
            DESIGNATION => undef,
            STATUS      => undef,
            DESCRIPTION => '32bit PCI'
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
            DESCRIPTION => 'Other',
            DESIGNATION => undef
        }
    ],
    'windows-hyperV' => undef,
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/generic/dmidecode/$test";
    my $slots = FusionInventory::Agent::Task::Inventory::Input::Generic::Dmidecode::Slots::_getSlots(file => $file);
    cmp_deeply($slots, $tests{$test}, $test);
}
