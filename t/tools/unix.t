#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Tools::Unix;
use FusionInventory::Logger;
use Test::More;

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
    (scalar keys %df_tests) +
    (scalar @dhcp_leases_test);

my $logger = FusionInventory::Logger->new();

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
