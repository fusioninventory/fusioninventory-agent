#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Ports;
use FusionInventory::Logger;
use Test::More;

my %tests = (
    'freebsd-6.2' => [
        {
            NAME        => 'PRIMARY IDE',
            DESCRIPTION => 'On Board IDE',
            TYPE        => 'Other',
            CAPTION     => 'None'
        },
        {
            NAME        => 'SECONDARY IDE',
            DESCRIPTION => 'On Board IDE',
            TYPE        => 'Other',
            CAPTION     => 'None'
        },
        {
            NAME        => 'FDD',
            DESCRIPTION => 'On Board Floppy',
            TYPE        => '8251 FIFO Compatible',
            CAPTION     => 'None'
        },
        {
            NAME        => 'COM1',
            DESCRIPTION => '9 Pin Dual Inline (pin 10 cut)',
            TYPE        => 'Serial Port 16450 Compatible',
            CAPTION     => 'DB-9 male'
        },
        {
            NAME        => 'COM2',
            DESCRIPTION => '9 Pin Dual Inline (pin 10 cut)',
            TYPE        => 'Serial Port 16450 Compatible',
            CAPTION     => 'DB-9 male'
        },
        {
            NAME        => 'LPT1',
            DESCRIPTION => 'DB-25 female',
            TYPE        => 'Parallel Port ECP/EPP',
            CAPTION     => 'DB-25 female'
        },
        {
            NAME        => 'Keyboard',
            DESCRIPTION => 'PS/2',
            TYPE        => 'Keyboard Port',
            CAPTION     => 'PS/2'
        },
        {
            NAME        => 'PS/2 Mouse',
            DESCRIPTION => 'PS/2',
            TYPE        => 'Mouse Port',
            CAPTION     => 'PS/2'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'USB',
            CAPTION     => 'Other'
        }
    ],
    'linux-2.6' => [
         {
            NAME        => 'PARALLEL',
            DESCRIPTION => 'None',
            TYPE        => 'Parallel Port PS/2',
            CAPTION     => 'DB-25 female'
        },
        {
            NAME        => 'SERIAL1',
            DESCRIPTION => 'None',
            TYPE        => 'Serial Port 16550A Compatible',
            CAPTION     => 'DB-9 male'
        },
        {
            NAME        => 'USB',
            DESCRIPTION => 'None',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            NAME        => 'MONITOR',
            DESCRIPTION => 'None',
            TYPE        => 'Video Port',
            CAPTION     => 'DB-15 female'
        },
        {
            NAME        => 'IrDA',
            DESCRIPTION => 'None',
            TYPE        => 'Other',
            CAPTION     => 'Infrared'
        },
        {
            NAME        => 'Modem',
            DESCRIPTION => 'None',
            TYPE        => 'Modem Port',
            CAPTION     => 'RJ-11'
        },
        {
            NAME        => 'Ethernet',
            DESCRIPTION => 'None',
            TYPE        => 'Network Port',
            CAPTION     => 'RJ-45'
        }
    ],
    'openbsd-3.7' => [
         {
            NAME        => 'PRIMARY IDE',
            DESCRIPTION => 'On Board IDE',
            TYPE        => 'Other',
            CAPTION     => 'None'
        },
        {
            NAME        => 'SECONDARY IDE',
            DESCRIPTION => 'On Board IDE',
            TYPE        => 'Other',
            CAPTION     => 'None'
        },
        {
            NAME        => 'FLOPPY',
            DESCRIPTION => 'On Board Floppy',
            TYPE        => 'Other',
            CAPTION     => 'None'
        },
        {
            NAME        => 'COM1',
            DESCRIPTION => '9 Pin Dual Inline (pin 10 cut)',
            TYPE        => 'Serial Port 16550 Compatible',
            CAPTION     => 'DB-9 male'
        },
        {
            NAME        => 'COM2',
            DESCRIPTION => '9 Pin Dual Inline (pin 10 cut)',
            TYPE        => 'Serial Port 16550 Compatible',
            CAPTION     => 'DB-9 male'
        },
        {
            NAME        => 'LPT1',
            DESCRIPTION => 'DB-25 female',
            TYPE        => 'Parallel Port ECP/EPP',
            CAPTION     => 'DB-25 female'
        },
        {
            NAME        => 'Keyboard',
            DESCRIPTION => 'Other',
            TYPE        => 'Keyboard Port',
            CAPTION     => 'PS/2'
        },
        {
            NAME        => 'PS/2 Mouse',
            DESCRIPTION => 'Other',
            TYPE        => 'Mouse Port',
            CAPTION     => 'PS/2'
        },
        {
            NAME        => 'IR_CON',
            DESCRIPTION => 'Other',
            TYPE        => 'Other',
            CAPTION     => 'Infrared'
        },
        {
            NAME        => 'IR_CON2',
            DESCRIPTION => 'Other',
            TYPE        => 'Other',
            CAPTION     => 'Infrared'
        },
        {
            NAME        => 'USB',
            DESCRIPTION => 'Other',
            TYPE        => 'USB',
            CAPTION     => 'Other'
        }
    ],
    'openbsd-3.8' => [
        {
            NAME        => 'SCSI',
            DESCRIPTION => '68 Pin Dual Inline',
            TYPE        => 'SCSI Wide',
            CAPTION     => 'None'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Video Port',
            CAPTION     => 'DB-15 female'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Parallel Port PS/2',
            CAPTION     => 'DB-25 female'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Network Port',
            CAPTION     => 'RJ-45'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Serial Port 16550A Compatible',
            CAPTION     => 'DB-9 male'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Keyboard Port',
            CAPTION     => 'PS/2'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Mouse Port',
            CAPTION     => 'PS/2'
        }
    ],
    'rhel-2.1' => [
        {
            DESCRIPTION => 'None',
            TYPE        => 'Serial Port 16650A Compatible',
            CAPTION     => 'DB-9 pin male'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Serial Port 16650A Compatible',
            CAPTION     => 'DB-9 pin male'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Parallel Port ECP/EPP',
            CAPTION     => 'DB-25 pin female'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Keyboard Port',
            CAPTION     => 'PS/2'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Mouse Port',
            CAPTION     => 'PS/2'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            DESCRIPTION => 'On Board IDE',
            TYPE        => 'Other',
            CAPTION     => 'None'
        },
        {
            DESCRIPTION => 'On Board IDE',
            TYPE        => 'Other',
            CAPTION     => 'None'
        },
        {
            DESCRIPTION => 'On Board Floppy',
            TYPE        => 'Other',
            CAPTION     => 'None'
        },
        {
            DESCRIPTION => 'SSA SCSI',
            TYPE        => 'SCSI II',
            CAPTION     => 'None'
        }
    ],
    'rhel-3.4' => [
        {
            NAME        => 'J2A1',
            DESCRIPTION => '9 Pin Dual Inline (pin 10 cut)',
            TYPE        => 'Serial Port 16550A Compatible',
            CAPTION     => 'DB-9 male'
        },
        {
            NAME        => 'J2A2',
            DESCRIPTION => '9 Pin Dual Inline (pin 10 cut)',
            TYPE        => 'Serial Port 16550A Compatible',
            CAPTION     => 'DB-9 male'
        },
        {
            NAME        => 'J3A1',
            DESCRIPTION => '25 Pin Dual Inline (pin 26 cut)',
            TYPE        => 'Parallel Port ECP/EPP',
            CAPTION     => 'DB-25 female'
        },
        {
            NAME        => 'J1A1',
            DESCRIPTION => 'None',
            TYPE        => 'Keyboard Port',
            CAPTION     => 'Circular DIN-8 male'
        },
        {
            NAME        => 'J1A1',
            DESCRIPTION => 'None',
            TYPE        => 'Keyboard Port',
            CAPTION     => 'Circular DIN-8 male'
        }
    ],
    'rhel-4.3' => [
        {
            NAME        => 'IDE1',
            DESCRIPTION => 'On Board IDE',
            TYPE        => 'Other',
            CAPTION     => 'None'
        },
        {
            NAME        => 'IDE2',
            DESCRIPTION => 'On Board IDE',
            TYPE        => 'Other',
            CAPTION     => 'None'
        },
        {
            NAME        => 'FDD',
            DESCRIPTION => 'On Board Floppy',
            TYPE        => '8251 FIFO Compatible',
            CAPTION     => 'None'
        },
        {
            NAME        => 'COM1',
            DESCRIPTION => '9 Pin Dual Inline (pin 10 cut)',
            TYPE        => 'Serial Port 16450 Compatible',
            CAPTION     => 'DB-9 male'
        },
        {
            NAME        => 'COM2',
            DESCRIPTION => '9 Pin Dual Inline (pin 10 cut)',
            TYPE        => 'Serial Port 16450 Compatible',
            CAPTION     => 'DB-9 male'
        },
        {
            NAME        => 'LPT1',
            DESCRIPTION => 'DB-25 female',
            TYPE        => 'Parallel Port ECP/EPP',
            CAPTION     => 'DB-25 female'
        },
        {
            NAME        => 'Keyboard',
            DESCRIPTION => 'PS/2',
            TYPE        => 'Keyboard Port',
            CAPTION     => 'PS/2'
        },
        {
            NAME        => 'PS/2 Mouse',
            DESCRIPTION => 'PS/2',
            TYPE        => 'Mouse Port',
            CAPTION     => 'PS/2'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'USB',
            CAPTION     => 'Other'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'USB',
            CAPTION     => 'Other'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Audio Port',
            CAPTION     => 'None'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Network Port',
            CAPTION     => 'RJ-45'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'SCSI Wide',
            CAPTION     => 'None'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'SCSI Wide',
            CAPTION     => 'None'
        }
    ],
    'rhel-4.6' => [
        {
            NAME        => 'J16',
            DESCRIPTION => 'Access Bus (USB)',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            NAME        => 'J19',
            DESCRIPTION => 'Access Bus (USB)',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            NAME        => 'J69',
            DESCRIPTION => 'Access Bus (USB)',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            NAME        => 'J69',
            DESCRIPTION => 'Access Bus (USB)',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            NAME        => 'J02',
            DESCRIPTION => 'Access Bus (USB)',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            NAME        => 'J03',
            DESCRIPTION => 'Access Bus (USB)',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        }
    ],
    'windows' => [
        {
            DESCRIPTION => 'None',
            TYPE        => 'Parallel Port ECP',
            CAPTION     => 'DB-25 female'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Other',
            CAPTION     => 'DB-15 female'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Modem Port',
            CAPTION     => 'RJ-11'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Network Port',
            CAPTION     => 'RJ-45'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Other',
            CAPTION     => 'Infrared'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'USB',
            CAPTION     => 'Access Bus (USB)'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Other',
            CAPTION     => 'Mini Jack (headphones)'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Firewire (IEEE P1394)',
            CAPTION     => 'IEEE 1394'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Other',
            CAPTION     => 'Other'
        },
        {
            DESCRIPTION => 'None',
            TYPE        => 'Other',
            CAPTION     => 'Other'
        }
    ]
);

plan tests => scalar keys %tests;

my $logger = FusionInventory::Logger->new();

foreach my $test (keys %tests) {
    my $file = "resources/dmidecode/$test";
    my $ports = FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Ports::getPorts($logger, $file);
    is_deeply($ports, $tests{$test}, $test);
}
