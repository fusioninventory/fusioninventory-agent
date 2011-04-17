#!/usr/bin/perl
use strict;

use warnings;

use FusionInventory::Agent::Task::Inventory::OS::Linux::LVM; 

use Test::More;
use Data::Dumper;


plan tests => 3;
my %lvs = (
        'debian-5' => [
          {
            'SIZE' => 10737,
            'VGNAME' => 'system',
            'ATTR' => '-wi-ao',
            'UUID' => '2543rY-rFWG-KrWN-a3tl-u4JZ-DqLr-1hSow4',
            'LVNAME' => 'home'
          },
          {
            'SIZE' => 1421,
            'VGNAME' => 'system',
            'ATTR' => '-wi-ao',
            'UUID' => 'A21pfK-5Av2-MzAd-RAx2-1VXW-gcHL-ZSnpY6',
            'LVNAME' => 'root'
          },
          {
            'SIZE' => 4118,
            'VGNAME' => 'system',
            'ATTR' => '-wi-ao',
            'UUID' => 'AtPa3M-2k5L-WzFq-g1fB-HXIj-wcwb-OkXcD1',
            'LVNAME' => 'swap_1'
          },
          {
            'SIZE' => 1472,
            'VGNAME' => 'system',
            'ATTR' => '-wi-ao',
            'UUID' => 'CiMQS1-0ooK-FPTu-9cjw-rf9L-Zk74-pdhof0',
            'LVNAME' => 'tmp'
          },
          {
            'SIZE' => 8996,
            'VGNAME' => 'system',
            'ATTR' => '-wi-ao',
            'UUID' => 'eu6Kdt-RKCt-FO58-h4CJ-bFXa-LWxs-uvLj8c',
            'LVNAME' => 'usr'
          },
          {
            'SIZE' => 9441,
            'VGNAME' => 'system',
            'ATTR' => '-wi-ao',
            'UUID' => 'deO6Dc-ZHPo-UlPS-M7Vd-P4de-3d5X-G0b69B',
            'LVNAME' => 'var'
          }

]

);

my %pvs = (
        'debian-5' => [
          {
            'SIZE' => 53427,
            'FORMAT' => 'lvm2',
            'ATTR' => 'a-',
            'FREE' => 17238,
            'UUID' => 'PeB8Cv-Fp12-sLfi-2nXp-dG03-Vd1v-2VP6OR',
            'PVNAME' => 'system',
            'DEVICE' => '/dev/sda5'
          }

        ]


        );

my %vgs = (
        'debian-5' => [

        {
        'SIZE' => '53427',
        'ATTR' => 'wz--n-',
        'VGNAME' => 'system',
        'FREE' => '17238',
        'LV_COUNT' => '6',
        'PV_COUNT' => '1',
        'UUID' => 'fT7mMU-VlXP-35Sj-dTYd-N8N5-e0oX-OenPJR'
        }

        ]


        );


foreach my $test (keys %lvs) {
    my $lvs = FusionInventory::Agent::Task::Inventory::OS::Linux::LVM::_parseLvs('resources/lvm/linux/lvs/'.$test, '<');
    is_deeply($lvs, $lvs{$test}, '_parseLvs()') or print Dumper($lvs);
}

foreach my $test (keys %pvs) {
    my $pvs = FusionInventory::Agent::Task::Inventory::OS::Linux::LVM::_parsePvs('resources/lvm/linux/pvs/'.$test, '<');
    is_deeply($pvs, $pvs{$test}, '_parsePvs()') or print Dumper($pvs);
}

foreach my $test (keys %vgs) {
    my $vgs = FusionInventory::Agent::Task::Inventory::OS::Linux::LVM::_parseVgs('resources/lvm/linux/vgs/'.$test, '<');
    is_deeply($vgs, $vgs{$test}, '_parseVgs()') or print Dumper($vgs);
}
