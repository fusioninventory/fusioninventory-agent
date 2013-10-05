#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Cwd;
use English qw(-no_match_vars);
use UNIVERSAL::require;
use Test::Deep qw(cmp_deeply);
use Test::More;
use Test::MockModule;
use FusionInventory::Test::Utils;

# use mock modules for non-available ones
if ($OSNAME eq 'MSWin32') {
    push @INC, 't/lib/fake/unix';
} else {
    push @INC, 't/lib/fake/windows';
}


FusionInventory::Agent::Task::Collect->require();


plan tests => 5;


my @result;

@result = FusionInventory::Agent::Task::Collect::_findFile(
    dir => getcwd(),
    recursive => 1
);
ok(int(@result) == 50, "_findFile() recursive=1 reach the limit");

@result = FusionInventory::Agent::Task::Collect::_findFile(
    dir   => getcwd(),
    limit => 60,
    recursive => 1
);

ok(int(@result) == 60, "_findFile() limit=60");

my $result = FusionInventory::Agent::Task::Collect::_getFromRegistry(
    path => 'nowhere'
);
ok(!defined($result), "_getFromRegistry ignores wrong registry path");

@result = FusionInventory::Agent::Task::Collect::_getFromWMI(
    class      => 'nowhere',
    properties => [ 'nothing' ]
);
ok(!defined($result), "_getFromWMI ignores missing WMI object");


my %tests = (
    7 => [
        {
            'Description' => 'WAN Miniport (SSTP)',
            'Index' => '0',
            'IPEnabled' => 'FALSE'
        },
        {
            'IPEnabled' => 'FALSE',
            'Index' => '1',
            'Description' => 'WAN Miniport (IKEv2)'
        },
        {
            'IPEnabled' => 'FALSE',
            'Index' => '2',
            'Description' => 'WAN Miniport (L2TP)'
        },
        {
            'IPEnabled' => 'FALSE',
            'Index' => '3',
            'Description' => 'WAN Miniport (PPTP)'
        },
        {
            'Description' => 'WAN Miniport (PPPOE)',
            'IPEnabled' => 'FALSE',
            'Index' => '4'
        },
        {
            'IPEnabled' => 'FALSE',
            'Index' => '5',
            'Description' => 'WAN Miniport (IPv6)'
        },
        {
            'Index' => '6',
            'IPEnabled' => 'FALSE',
            'Description' => 'WAN Miniport (Network Monitor)'
        },
        {
            'IPEnabled' => 'TRUE',
            'Index' => '7',
            'Description' => 'Realtek PCIe GBE Family Controller'
        },
        {
            'IPEnabled' => 'FALSE',
            'Index' => '8',
            'Description' => 'WAN Miniport (IP)'
        },
        {
            'Description' => 'Carte Microsoft ISATAP',
            'Index' => '9',
            'IPEnabled' => 'FALSE'
        },
        {
            'IPEnabled' => 'FALSE',
            'Index' => '10',
            'Description' => 'RAS Async Adapter'
        },
        {
            'IPEnabled' => 'FALSE',
            'Index' => '11',
            'Description' => 'Microsoft Teredo Tunneling Adapter'
        },
        {
            'IPEnabled' => 'FALSE',
            'Index' => '12',
            'Description' => "P\x{e9}riph\x{e9}rique Bluetooth (r\x{e9}seau personnel)"
        },
        {
            'IPEnabled' => 'FALSE',
            'Index' => '13',
            'Description' => 'Carte Microsoft ISATAP'
        }
    ]
);

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Tools::Win32'
);


foreach my $test (keys %tests) {
    $module->mock(
        'getWMIObjects',
        mockGetWMIObjects($test)
    );

    my @wmiResult = FusionInventory::Agent::Task::Collect::_getFromWMI(
        class      => 'Win32_NetworkAdapterConfiguration',
        properties => [ qw/Index Description IPEnabled/  ]
    );
    cmp_deeply(
        \@wmiResult,
        $tests{$test},
        "WMI query"
    );
}

