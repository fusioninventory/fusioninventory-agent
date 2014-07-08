#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::Deep qw(cmp_deeply);
use Test::MockModule;
use Test::More;

use FusionInventory::Test::Utils;
use FusionInventory::Agent::Tools;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/lib/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Tools::Win32;

my %tests = (
    7 => [
        {
            dns         => '192.168.0.254',
            IPMASK      => '255.255.255.0',
            IPGATEWAY   => '192.168.0.254',
            MACADDR     => 'F4:6D:04:97:2D:3E',
            STATUS      => 'Up',
            IPDHCP      => '192.168.0.254',
            IPSUBNET    => '192.168.0.0',
            MTU         => undef,
            DESCRIPTION => 'Realtek PCIe GBE Family Controller',
            IPADDRESS   => '192.168.0.1',
            VIRTUALDEV  => 0,
            SPEED       => 100000000,
            PNPDEVICEID => 'PCI\VEN_10EC&DEV_8168&SUBSYS_84321043&REV_06\4&87D54EE&0&00E5',
            TYPE        => 'ethernet'
        },
        {
            dns         => '192.168.0.254',
            IPMASK6     => 'ffff:ffff:ffff:ffff::',
            IPGATEWAY   => '192.168.0.254',
            MACADDR     => 'F4:6D:04:97:2D:3E',
            STATUS      => 'Up',
            IPADDRESS6  => 'fe80::311a:2127:dded:6618',
            IPDHCP      => '192.168.0.254',
            MTU         => undef,
            IPSUBNET6   => 'fe80::',
            DESCRIPTION => 'Realtek PCIe GBE Family Controller',
            VIRTUALDEV  => 0,
            SPEED       => 100000000,
            PNPDEVICEID => 'PCI\VEN_10EC&DEV_8168&SUBSYS_84321043&REV_06\4&87D54EE&0&00E5',
            TYPE        => 'ethernet'
        },
        {
            dns         => undef,
            IPGATEWAY   => undef,
            MTU         => undef,
            MACADDR     => '00:26:83:12:FB:0B',
            STATUS      => 'Up',
            DESCRIPTION => "Périphérique Bluetooth (réseau personnel)",
            IPDHCP      => undef,
            VIRTUALDEV  => 0,
            PNPDEVICEID => 'BTH\MS_BTHPAN\7&42D85A8&0&2',
            TYPE        => 'ethernet',
            SPEED       => 0
        },
    ],
    xp => [
        {
            dns         => undef,
            IPGATEWAY   => undef,
            VIRTUALDEV  => 1,
            PNPDEVICEID => 'ROOT\\MS_PPTPMINIPORT\\0000',
            MACADDR     => '50:50:54:50:30:30',
            STATUS      => 'Up',
            TYPE        => undef,
            SPEED       => undef,
            IPDHCP      => undef,
            MTU         => undef,
            DESCRIPTION => 'Minipuerto WAN (PPTP)'
        },
        {
            dns         => undef,
            IPGATEWAY   => undef,
            VIRTUALDEV  => 1,
            PNPDEVICEID => 'ROOT\\MS_PPPOEMINIPORT\\0000',
            MACADDR     => '33:50:6F:45:30:30',
            STATUS      => 'Up',
            TYPE        => undef,
            SPEED       => undef,
            IPDHCP      => undef,
            MTU         => undef,
            DESCRIPTION => 'Minipuerto WAN (PPPOE)'
        },
        {
            dns         => undef,
            IPGATEWAY   => undef,
            VIRTUALDEV  => 1,
            PNPDEVICEID => 'ROOT\\MS_PSCHEDMP\\0000',
            MACADDR     => '26:0F:20:52:41:53',
            STATUS      => 'Up',
            TYPE        => 'ethernet',
            SPEED       => undef,
            IPDHCP      => undef,
            MTU         => undef,
            DESCRIPTION => 'Minipuerto del administrador de paquetes'
        },
        {
            dns         => '10.36.6.100',
            IPMASK      => '255.255.254.0',
            IPGATEWAY   => '10.36.6.1',
            VIRTUALDEV  => 0,
            PNPDEVICEID => 'PCI\\VEN_14E4&DEV_1677&SUBSYS_3006103C&REV_01\\4&1886B119&0&00E1',
            MACADDR     => '00:14:C2:0D:B0:FB',
            STATUS      => 'Up',
            TYPE        => 'ethernet',
            SPEED       => undef,
            IPDHCP      => '10.36.6.100',
            IPSUBNET    => '10.36.6.0',
            MTU         => undef,
            DESCRIPTION => 'Broadcom NetXtreme Gigabit Ethernet - Teefer2 Miniport',
            IPADDRESS   => '10.36.6.30',
        },
        {
            dns         => undef,
            IPGATEWAY   => undef,
            VIRTUALDEV  => 1,
            PNPDEVICEID => 'ROOT\\MS_PSCHEDMP\\0002',
            MACADDR     => '00:14:C2:0D:B0:FB',
            STATUS      => 'Up',
            TYPE        => 'ethernet',
            SPEED       => undef,
            IPDHCP      => undef,
            MTU         => undef,
            DESCRIPTION => 'Minipuerto del administrador de paquetes'
        },
        {
            dns         => undef,
            IPGATEWAY   => undef,
            VIRTUALDEV  => 1,
            PNPDEVICEID => 'ROOT\\SYMC_TEEFER2MP\\0000',
            MACADDR     => '00:14:C2:0D:B0:FB',
            STATUS      => 'Up',
            TYPE        => 'ethernet',
            SPEED       => undef,
            IPDHCP      => undef,
            MTU         => undef,
            DESCRIPTION => 'Teefer2 Miniport'
        },
        {
            dns         => undef,
            IPGATEWAY   => undef,
            VIRTUALDEV  => 1,
            PNPDEVICEID => 'ROOT\\SYMC_TEEFER2MP\\0002',
            MACADDR     => '26:0F:20:52:41:53',
            STATUS      => 'Up',
            TYPE        => 'ethernet',
            SPEED       => undef,
            IPDHCP      => undef,
            MTU         => undef,
            DESCRIPTION => 'Teefer2 Miniport'
        }
    ]
);

my @key_tests = (
    [
        'a4,00,00,00,03,00,00,00,35,35,30,34,31,2d,30,32,39,2d,30,30,34,37,38,39,37,2d,38,36,36,32,34,00,ac,00,00,00,58,31,35,2d,33,39,30,38,31,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,39,69,0a,52,80,bd,80,2c,03,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,5d,8a,cd,c9',
        'BBBBB-BBBBB-BBBBB-BBBBB-BBBBB',
        'win7 serial key decoding'
    ],
    [
        'a4,00,00,00,03,00,00,00,30,30,31,38,30,2d,31,30,35,33,39,2d,35,32,38,34,30,2d,41,41,4f,45,4d,00,09,07,00,00,58,31,38,2d,31,35,35,38,30,00,00,00,00,00,00,00,09,07,80,14,74,33,14,aa,32,e4,d5,11,25,15,08,00,00,00,00,00,3a,05,bb,51,2f,01,29,97,02,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,b6,7d,17,ed',
        'NK2HF-3VG6G-X3YMF-JFT99-HCBRC',
        'win8 serial key decoding'
    ]
);

plan tests =>
    (scalar keys %tests) +
    (scalar keys @key_tests) +
    4;

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Tools::Win32'
);

foreach my $test (keys %tests) {
    $module->mock(
        'getWMIObjects',
        mockGetWMIObjects($test)
    );

    my @interfaces = getInterfaces();
    cmp_deeply(
        \@interfaces,
        $tests{$test},
        "$test sample"
    );
}

foreach my $test (@key_tests) {
    is(parseProductKey(binary($test->[0])), $test->[1], $test->[2]);
}

SKIP: {
skip 'Windows-specific test', 4 unless $OSNAME eq 'MSWin32';

my ($code, $fd) = runCommand(command => "perl -V");
ok($code eq 0, "perl -V returns 0");

ok(any { /Summary of my perl5/ } <$fd>, "perl -V output looks good");

($code, $fd) = runCommand(
    timeout => 1,
    command => "perl -e\"sleep 10\""
);
ok($code eq 293, "timeout=1: timeout catched");
my $command = "perl -BAD";
($code, $fd) = runCommand(
    command => $command,
    no_stderr => 1
);
ok(defined(<$fd>), "no_stderr=0: catch STDERR output");

}

sub binary {
    my ($string) = @_;
    return pack("C*", map { hex($_) } split (/,/, $string));
}
