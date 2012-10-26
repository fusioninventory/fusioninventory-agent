#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Generic::LocalGroups;

my %tests = (
    'group' => [
        { ID   => '0' ,
          NAME => 'root'
        } ,
        { ID => '1' ,
          NAME => 'daemon'
        },
        { ID   => '2',
          NAME => 'bin'
        },
        { ID   => '3',
          NAME => 'sys'
        },
        { ID   => '4',
          NAME => 'adm'
        },
        { ID   => '5',
          NAME => 'tty'
        },
        { ID   => '6',
          NAME => 'disk'
        },
        { ID   => '7',
          NAME => 'lp'
        },
        { ID   => '8',
          NAME => 'mail'
        },
        { ID   => '9',
          NAME => 'news'
        },
        { ID   => '10',
          NAME => 'uucp'
        },
        { ID   => '12',
          NAME => 'man'
        },
        { ID   => '13',
          NAME => 'proxy'
        },
        { ID   => '15',
          NAME => 'kmem'
        },
        { ID   => '20',
          NAME => 'dialout'
        },
        { ID   => '21',
          NAME => 'fax'
        },
        { ID   => '22',
          NAME => 'voice'
        },
        { ID   => '24',
          MEMBER => ['bkelso'],
          NAME => 'cdrom'
        },
        { ID   => '25',
          MEMBER => ['bkelso'],
          NAME => 'floppy'
        },
        { ID   => '26',
          NAME => 'tape'
        },
        { ID   => '27',
          NAME => 'sudo'
        },
        { ID   => '29',
          MEMBER => ['pulse', 'bkelso'],
          NAME => 'audio'
        },
        { ID   => '30',
          MEMBER => ['bkelso'],
          NAME => 'dip'
        },
        { ID   => '33',
          NAME => 'www-data'
        },
        { ID   => '34',
          NAME => 'backup'
        },
        { ID   => '37',
          NAME => 'operator'
        },
        { ID   => '38',
          NAME => 'list'
        },
        { ID   => '39',
          NAME => 'irc'
        },
        { ID   => '40',
          NAME => 'src'
        },
        { ID   => '41',
          NAME => 'gnats'
        },
        { ID   => '42',
          NAME => 'shadow'
        },
        { ID   => '43',
          NAME => 'utmp'
        },
        { ID   => '44',
          MEMBER => ['bkelso'],
          NAME => 'video'
        },
        { ID   => '45',
          NAME => 'sasl'
        },
        { ID   => '46',
          MEMBER => ['bkelso'],
          NAME => 'plugdev'
        },
        { ID   => '50',
          NAME => 'staff'
        },
        { ID   => '60',
          NAME => 'games'
        },
        { ID   => '100',
          NAME => 'users'
        },
        { ID   => '65534',
          NAME => 'nogroup'
        },
        { ID   => '101',
          NAME => 'libuuid'
        },
        { ID   => '102',
          NAME => 'crontab'
        },
        { ID   => '103',
          NAME => 'fuse'
        },
        { ID   => '104',
          MEMBER => ['saned', 'bkelso'],
          NAME => 'scanner'
        },
        { ID   => '105',
          NAME => 'messagebus'
        },
        { ID   => '106',
          NAME => 'colord'
        },
        { ID   => '107',
          NAME => 'lpadmin'
        },
        { ID   => '108',
          MEMBER => ['postgres'],
          NAME => 'ssl-cert'
        },
        { ID   => '109',
          MEMBER => ['bkelso'],
          NAME => 'bluetooth'
        },
        { ID   => '110',
          MEMBER => ['bkelso'],
          NAME => 'netdev'
        },
        { ID   => '111',
          NAME => 'Debian-exim'
        },
        { ID   => '112',
          NAME => 'mlocate'
        },
        { ID   => '113',
          NAME => 'ssh'
        },
        { ID   => '114',
          NAME => 'avahi'
        },
        { ID   => '115',
          NAME => 'utempter'
        },
        { ID   => '116',
          NAME => 'Debian-gdm'
        },
        { ID   => '117',
          NAME => 'pulse'
        },
        { ID   => '118',
          NAME => 'pulse-access'
        },
        { ID   => '119',
          NAME => 'rtkit'
        },
        { ID   => '120',
          NAME => 'saned'
        },
        { ID   => '1000',
          NAME => 'bkelso'
        },
        { ID   => '1001',
          NAME => 'user'
        },
        { ID   => '121',
          NAME => 'vboxusers'
        },
        { ID   => '122',
          NAME => 'openldap'
        },
        { ID   => '123',
          NAME => 'postgres'
        },
        { ID   => '124',
          NAME => 'libvirt'
        },
        { ID   => '125',
          NAME => 'kvm'
        },
        { ID   => '1002',
          NAME => 'gerrit2'
        },
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/generic/etc/$test";
    my @groups = FusionInventory::Agent::Task::Inventory::Input::Generic::LocalGroups::_getLocalGroups(file => $file);
    is_deeply(\@groups, $tests{$test}, $test);
}
