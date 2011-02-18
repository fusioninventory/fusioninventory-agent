#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use File::Glob;
use File::Basename;
use Data::Dumper;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Slots;

my %tests = (
          'hp-dl180' => [
                          {
                            'ID' => 'A5 06 01 00 FF FB EB BF',
                            'NAME' => 'Xeon',
                            'EXTERNAL_CLOCK' => '532',
                            'SPEED' => '2000',
                            'THREAD' => '4',
                            'SERIAL' => undef,
                            'MANUFACTURER' => 'Intel',
                            'CORE' => '4'
                          }
                        ],
          'freebsd-8.1' => [
                             {
                               'ID' => '52 06 02 00 FF FB EB BF',
                               'NAME' => 'Core 2 Duo',
                               'EXTERNAL_CLOCK' => '1066',
                               'SPEED' => '2270',
                               'THREAD' => '4',
                               'SERIAL' => undef,
                               'MANUFACTURER' => 'Intel(R) Corporation',
                               'CORE' => '2'
                             }
                           ],
          'rhel-4.6' => [
                          {
                            'ID' => '76 06 01 00 FF FB EB BF',
                            'NAME' => 'Xeon',
                            'EXTERNAL_CLOCK' => '1333',
                            'SPEED' => '4800',
                            'THREAD' => undef,
                            'SERIAL' => undef,
                            'MANUFACTURER' => 'Intel',
                            'CORE' => undef
                          }
                        ],
          'rhel-4.3' => [
                          {
                            'ID' => '29 0F 00 00 FF FB EB BF',
                            'NAME' => 'Xeon',
                            'EXTERNAL_CLOCK' => '133',
                            'SPEED' => '3200',
                            'THREAD' => undef,
                            'SERIAL' => undef,
                            'MANUFACTURER' => 'Intel',
                            'CORE' => undef
                          },
                          {
                            'ID' => '29 0F 00 00 FF FB EB BF',
                            'NAME' => 'Xeon',
                            'EXTERNAL_CLOCK' => '133',
                            'SPEED' => '3200',
                            'THREAD' => undef,
                            'SERIAL' => undef,
                            'MANUFACTURER' => 'Intel',
                            'CORE' => undef
                          }
                        ],
          'windows' => [
                         {
                           'ID' => '24 0F 00 00 00 00 00 00',
                           'NAME' => 'Pentium 4',
                           'EXTERNAL_CLOCK' => '100',
                           'SPEED' => '1700',
                           'THREAD' => undef,
                           'SERIAL' => undef,
                           'MANUFACTURER' => 'Intel Corporation',
                           'CORE' => undef
                         }
                       ],
          'freebsd-6.2' => [
                             {
                               'ID' => 'A9 06 00 00 FF BB C9 A7',
                               'NAME' => 'VIA C7',
                               'EXTERNAL_CLOCK' => '100',
                               'SPEED' => '2000',
                               'THREAD' => undef,
                               'SERIAL' => undef,
                               'MANUFACTURER' => 'VIA',
                               'CORE' => undef
                             }
                           ],
          'openbsd-3.7' => [
                             {
                               'ID' => '52 06 00 00 FF F9 83 01',
                               'NAME' => 'Pentium II',
                               'EXTERNAL_CLOCK' => '100',
                               'SPEED' => '500',
                               'THREAD' => undef,
                               'SERIAL' => undef,
                               'MANUFACTURER' => 'Intel',
                               'CORE' => undef
                             }
                           ],
          'rhel-3.9' => undef,
          'openbsd-4.5' => [
                             {
                               'ID' => '29 0F 00 00 FF FB EB BF',
                               'NAME' => 'Pentium 4',
                               'EXTERNAL_CLOCK' => '533',
                               'SPEED' => '3200',
                               'THREAD' => undef,
                               'SERIAL' => undef,
                               'MANUFACTURER' => 'Intel',
                               'CORE' => undef
                             }
                           ],
          'vmware' => [
                        {
                          'ID' => '12 0F 04 00 FF FB 8B 07',
                          'NAME' => undef,
                          'EXTERNAL_CLOCK' => undef,
                          'SPEED' => '2133',
                          'THREAD' => undef,
                          'SERIAL' => undef,
                          'MANUFACTURER' => 'AuthenticAMD',
                          'CORE' => undef
                        },
                        {
                          'ID' => '12 0F 00 00 FF FB 8B 07',
                          'NAME' => 'Unknown',
                          'EXTERNAL_CLOCK' => undef,
                          'SPEED' => '2133',
                          'THREAD' => undef,
                          'SERIAL' => undef,
                          'MANUFACTURER' => 'GenuineIntel',
                          'CORE' => undef
                        }
                      ],
          'S3000AHLX' => [
                           {
                             'ID' => 'F6 06 00 00 FF FB EB BF',
                             'NAME' => '<OUT OF SPEC>',
                             'EXTERNAL_CLOCK' => '266',
                             'SPEED' => '2400',
                             'THREAD' => undef,
                             'SERIAL' => undef,
                             'MANUFACTURER' => 'Intel(R) Corporation',
                             'CORE' => undef
                           }
                         ],
          'rhel-2.1' => [
                          {
                            'ID' => undef,
                            'NAME' => 'Pentium 4',
                            'EXTERNAL_CLOCK' => undef,
                            'SPEED' => undef,
                            'THREAD' => undef,
                            'SERIAL' => undef,
                            'MANUFACTURER' => 'Intel',
                            'CORE' => undef
                          }
                        ],
          'S5000VSA' => [
                          {
                            'ID' => 'F6 06 00 00 FF FB EB BF',
                            'NAME' => 'Xeon',
                            'EXTERNAL_CLOCK' => '1066',
                            'SPEED' => '1860',
                            'THREAD' => '2',
                            'SERIAL' => undef,
                            'MANUFACTURER' => 'Intel(R) Corporation',
                            'CORE' => '2'
                          },
                          {
                            'ID' => 'F6 06 00 00 FF FB EB BF',
                            'NAME' => 'Xeon',
                            'EXTERNAL_CLOCK' => '1066',
                            'SPEED' => '1860',
                            'THREAD' => '2',
                            'SERIAL' => undef,
                            'MANUFACTURER' => 'Intel(R) Corporation',
                            'CORE' => '2'
                          }
                        ],
          'linux-2.6' => [
                           {
                             'ID' => 'D8 06 00 00 FF FB E9 AF',
                             'NAME' => 'Pentium M',
                             'EXTERNAL_CLOCK' => '133',
                             'SPEED' => '1800',
                             'THREAD' => undef,
                             'SERIAL' => undef,
                             'MANUFACTURER' => 'Intel',
                             'CORE' => undef
                           }
                         ],
          'esx-2.5' => [
                         {
                           'ID' => undef,
                           'NAME' => 'Pentium III processor',
                           'EXTERNAL_CLOCK' => undef,
                           'SPEED' => undef,
                           'THREAD' => undef,
                           'SERIAL' => undef,
                           'MANUFACTURER' => 'GenuineIntel',
                           'CORE' => undef
                         }
                       ],
          'rhel-3.4' => [
                          {
                            'ID' => '41 0F 00 00 FF FB EB BF',
                            'NAME' => 'Xeon MP',
                            'EXTERNAL_CLOCK' => '200',
                            'SPEED' => '2800',
                            'THREAD' => undef,
                            'SERIAL' => undef,
                            'MANUFACTURER' => 'Intel Corporation',
                            'CORE' => undef
                          },
                          {
                            'ID' => '41 0F 00 00 FF FB EB BF',
                            'NAME' => 'Xeon MP',
                            'EXTERNAL_CLOCK' => '200',
                            'SPEED' => '2800',
                            'THREAD' => undef,
                            'SERIAL' => undef,
                            'MANUFACTURER' => 'Intel Corporation',
                            'CORE' => undef
                          }
                        ],
          'linux-1' => [
                         {
                           'ID' => '7A 06 01 00 FF FB EB BF',
                           'NAME' => 'Core 2 Duo',
                           'EXTERNAL_CLOCK' => '333',
                           'SPEED' => '3000',
                           'THREAD' => '2',
                           'SERIAL' => 'To Be Filled By O.E.M.',
                           'MANUFACTURER' => 'Intel',
                           'CORE' => '2'
                         }
                       ],
          'openbsd-3.8' => [
                             {
                               'ID' => '43 0F 00 00 FF FB EB BF',
                               'NAME' => 'Xeon',
                               'EXTERNAL_CLOCK' => '800',
                               'SPEED' => '3600',
                               'THREAD' => undef,
                               'SERIAL' => undef,
                               'MANUFACTURER' => 'Intel',
                               'CORE' => undef
                             }
                           ],
          'dmidecode-esx' => [
          {
            'ID' => '42 0F 10 00 FF FB 8B 07',
            'NAME' => undef,
            'EXTERNAL_CLOCK' => undef,
            'SPEED' => '30000',
            'THREAD' => undef,
            'SERIAL' => undef,
            'MANUFACTURER' => 'AuthenticAMD',
            'CORE' => undef
          }
        ]
);

my @list = glob("resources/dmidecode/*");
plan tests => int @list;

my $logger = FusionInventory::Agent::Logger->new();

my $t;
foreach my $file (@list) {
    my $cpus = FusionInventory::Agent::Tools::getCpusFromDmidecode($logger, $file);
    is_deeply($cpus, $tests{basename($file)}, "slots: ".basename($file)) or print Dumper($cpus);
}
