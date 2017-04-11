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

use Config;
# check thread support availability
if (!$Config{usethreads} || $Config{usethreads} ne 'define') {
    plan skip_all => 'thread support required';
}

# REG_SZ & REG_DWORD provided by even faked Win32::TieRegistry module
Win32::TieRegistry->require();
Win32::TieRegistry->import('REG_DWORD', 'REG_SZ');

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
            SPEED       => 100,
            PNPDEVICEID => 'PCI\VEN_10EC&DEV_8168&SUBSYS_84321043&REV_06\4&87D54EE&0&00E5',
            PCIID       => '10EC:8168:8432:1043',
        },
        {
            dns         => '192.168.0.254',
            IPMASK6     => 'ffff:ffff:ffff:ffff::',
            MACADDR     => 'F4:6D:04:97:2D:3E',
            STATUS      => 'Up',
            IPADDRESS6  => 'fe80::311a:2127:dded:6618',
            MTU         => undef,
            IPSUBNET6   => 'fe80::',
            DESCRIPTION => 'Realtek PCIe GBE Family Controller',
            VIRTUALDEV  => 0,
            SPEED       => 100,
            PNPDEVICEID => 'PCI\VEN_10EC&DEV_8168&SUBSYS_84321043&REV_06\4&87D54EE&0&00E5',
            PCIID       => '10EC:8168:8432:1043',
        },
        {
            dns         => undef,
            MTU         => undef,
            MACADDR     => '00:26:83:12:FB:0B',
            STATUS      => 'Up',
            DESCRIPTION => "Périphérique Bluetooth (réseau personnel)",
            VIRTUALDEV  => 0,
            PNPDEVICEID => 'BTH\MS_BTHPAN\7&42D85A8&0&2',
            PCIID       => undef,
        },
    ],
    xp => [
        {
            dns         => undef,
            VIRTUALDEV  => 1,
            PNPDEVICEID => 'ROOT\\MS_PPTPMINIPORT\\0000',
            PCIID       => undef,
            MACADDR     => '50:50:54:50:30:30',
            STATUS      => 'Up',
            MTU         => undef,
            DESCRIPTION => 'Minipuerto WAN (PPTP)'
        },
        {
            dns         => undef,
            VIRTUALDEV  => 1,
            PNPDEVICEID => 'ROOT\\MS_PPPOEMINIPORT\\0000',
            PCIID       => undef,
            MACADDR     => '33:50:6F:45:30:30',
            STATUS      => 'Up',
            MTU         => undef,
            DESCRIPTION => 'Minipuerto WAN (PPPOE)'
        },
        {
            dns         => undef,
            VIRTUALDEV  => 1,
            PNPDEVICEID => 'ROOT\\MS_PSCHEDMP\\0000',
            PCIID       => undef,
            MACADDR     => '26:0F:20:52:41:53',
            STATUS      => 'Up',
            MTU         => undef,
            DESCRIPTION => 'Minipuerto del administrador de paquetes'
        },
        {
            dns         => '10.36.6.100',
            IPMASK      => '255.255.254.0',
            IPGATEWAY   => '10.36.6.1',
            VIRTUALDEV  => 0,
            PNPDEVICEID => 'PCI\\VEN_14E4&DEV_1677&SUBSYS_3006103C&REV_01\\4&1886B119&0&00E1',
            PCIID       => '14E4:1677:3006:103C',
            MACADDR     => '00:14:C2:0D:B0:FB',
            STATUS      => 'Up',
            IPDHCP      => '10.36.6.100',
            IPSUBNET    => '10.36.6.0',
            MTU         => undef,
            DESCRIPTION => 'Broadcom NetXtreme Gigabit Ethernet - Teefer2 Miniport',
            IPADDRESS   => '10.36.6.30',
        },
        {
            dns         => undef,
            VIRTUALDEV  => 1,
            PNPDEVICEID => 'ROOT\\MS_PSCHEDMP\\0002',
            PCIID       => undef,
            MACADDR     => '00:14:C2:0D:B0:FB',
            STATUS      => 'Up',
            MTU         => undef,
            DESCRIPTION => 'Minipuerto del administrador de paquetes'
        },
        {
            dns         => undef,
            VIRTUALDEV  => 1,
            PNPDEVICEID => 'ROOT\\SYMC_TEEFER2MP\\0000',
            PCIID       => undef,
            MACADDR     => '00:14:C2:0D:B0:FB',
            STATUS      => 'Up',
            MTU         => undef,
            DESCRIPTION => 'Teefer2 Miniport'
        },
        {
            dns         => undef,
            VIRTUALDEV  => 1,
            PNPDEVICEID => 'ROOT\\SYMC_TEEFER2MP\\0002',
            PCIID       => undef,
            MACADDR     => '26:0F:20:52:41:53',
            STATUS      => 'Up',
            MTU         => undef,
            DESCRIPTION => 'Teefer2 Miniport'
        }
    ]
);

# Emulated registry
my %register = (
    'HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node' => {
        'TeamViewer' => {
            # Values key begins with a slash
            '/ClientID' => '0x12345678',
            '/Version'  => '12.0.72365',
            # Subkey ends with a slash
            'subkey/'   => {
                '/value' => ''
            }
        }
    },
    'HKEY_LOCAL_MACHINE/CurrentControlSet/Control/Session Manager' => {
        'Environment' => {
            '/TEMP' => '%SystemRoot%\\TEMP',
            '/OS'   => 'Windows_NT',
        }
    }
);

my %regkey_tests = (
    'nopath' => {
        _expected => undef
    },
    'undef-path' => {
        path      => undef,
        _expected => undef
    },
    'emptypath' => {
        path      => '',
        _expected => undef
    },
    'badroot' => {
        path      => 'HKEY_NOT_A_ROOT/Not_existing_Key_path',
        _expected => undef
    },
    'teamviewer' => {
        path      => 'HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/TeamViewer',
        _expected => bless({
            '/ClientID' => '0x12345678',
            '/Version'  => '12.0.72365',
            'subkey/'    => bless({
                '/value' => ''
            }, 'Win32::TieRegistry')
        }, 'Win32::TieRegistry')
    },
    'environment' => {
        path      => 'HKEY_LOCAL_MACHINE/CurrentControlSet/Control/Session Manager/Environment',
        _expected => bless({
            '/TEMP' => '%SystemRoot%\\TEMP',
            '/OS'   => 'Windows_NT'
        }, 'Win32::TieRegistry')
    }
);

my %regval_tests = (
    'nopath' => {
        _expected => undef
    },
    'undef-path' => {
        path      => undef,
        _expected => undef
    },
    'emptypath' => {
        path      => '',
        _expected => undef
    },
    'badroot' => {
        path      => 'HKEY_NOT_A_ROOT/Not_existing_Key_path',
        _expected => undef
    },
    'teamviewerid' => {
        path      => 'HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/TeamViewer/ClientID',
        _expected => '0x12345678'
    },
    'teamviewer-all' => {
        path      => 'HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/TeamViewer/*',
        _expected => {
            'ClientID' => '0x12345678',
            'Version'  => '12.0.72365',
            'subkey/'   => undef
        }
    },
    'teamviewerid-withtype' => {
        path      => 'HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/TeamViewer/ClientID',
        withtype  => 1,
        _expected => [ '0x12345678', REG_DWORD() ]
    },
    'teamviewer-all-withtype' => {
        path      => 'HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/TeamViewer/*',
        withtype  => 1,
        _expected => {
            'ClientID' => [ '0x12345678', REG_DWORD() ],
            'Version'  => [ '12.0.72365', REG_SZ() ],
            'subkey/'   => []
        }
    },
    'temp-env' => {
        path      => 'HKEY_LOCAL_MACHINE/CurrentControlSet/Control/Session Manager/Environment/TEMP',
        _expected => '%SystemRoot%\\TEMP'
    }
);

my $win32_only_test_count = 7;

plan tests =>
    (scalar keys %tests) + $win32_only_test_count +
    (scalar keys %regkey_tests) + (scalar keys %regval_tests);

FusionInventory::Agent::Tools::Win32->require();
FusionInventory::Agent::Tools::Win32->use('getInterfaces');

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

SKIP: {
    skip 'Avoid windows-emulation based tests on win32',
        (scalar keys %regkey_tests) + (scalar keys %regval_tests)
            if $OSNAME eq 'MSWin32';

    $module->mock(
        '_getRegistryKey',
        sub {
            my (%params) = @_;
            return unless ($params{root} && $params{keyName});
            return unless exists($register{$params{root}});
            my $root = $register{$params{root}};
            return unless exists($root->{$params{keyName}});
            my $key = { %{$root->{$params{keyName}}} };
            # Bless leaf as expected
            map { bless $key->{$_}, 'Win32::TieRegistry' }
                grep { ref($key->{$_}) eq 'HASH' } keys %{$key};
            bless $key, 'Win32::TieRegistry';
            return $key;
        }
    );

    FusionInventory::Agent::Tools::Win32->use('getRegistryKey');
    foreach my $test (keys %regkey_tests) {

        my $regkey = getRegistryKey( %{$regkey_tests{$test}} );
        cmp_deeply(
            $regkey,
            $regkey_tests{$test}->{_expected},
            "$test regkey"
        );
    }

    FusionInventory::Agent::Tools::Win32->use('getRegistryValue');
    foreach my $test (keys %regval_tests) {

        my $regval = getRegistryValue( %{$regval_tests{$test}} );
        cmp_deeply(
            $regval,
            $regval_tests{$test}->{_expected},
            "$test regval"
        );
    }
}

SKIP: {
    skip 'Windows-specific test', $win32_only_test_count
        unless $OSNAME eq 'MSWin32';

    FusionInventory::Agent::Tools::Win32->use('runCommand');

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

    # From here we need to avoid crashes due to not thread-safe Win32::OLE
    FusionInventory::Agent::Tools::Win32::start_Win32_OLE_Worker();

    FusionInventory::Agent::Tools::Win32->use('is64bit');
    ok(defined(is64bit()), "is64bit api call");

    FusionInventory::Agent::Tools::Win32->use('getLocalCodepage');
    ok(defined(getLocalCodepage()), "getLocalCodepage api call");
    ok(getLocalCodepage() =~ /^cp.+/, "local codepage check");

    # If we crash after that, this means Win32::OLE is not used in a
    # dedicated thread
    my $pid = fork;
    if (defined($pid)) {
        waitpid $pid, 0;
    } else {
        exit(0);
    }
}
