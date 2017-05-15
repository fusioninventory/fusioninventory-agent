#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;
use Test::Deep;
use UNIVERSAL::require;
use FusionInventory::Test::Utils;
use FusionInventory::Agent::Tools::Constants;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/lib/fake/windows' if $OSNAME ne 'MSWin32';
}

use Config;
# check thread support availability
if (!$Config{usethreads} || $Config{usethreads} ne 'define') {
    plan skip_all => 'thread support required';
}

Test::NoWarnings->use();
FusionInventory::Agent::Task::Inventory::Win32::Firewall->require();

my $expectedFirewallProfiles = {
    '7' => {
        domain   => {
            STATUS  => STATUS_OFF,
            PROFILE => 'DomainProfile'
        },
        public   => {
            STATUS  => STATUS_OFF,
            PROFILE => 'PublicProfile'
        },
        standard => {
            STATUS  => STATUS_OFF,
            PROFILE => 'StandardProfile'
        }
    },
    '10' => {
        domain   => {
            STATUS  => STATUS_ON,
            PROFILE => 'DomainProfile'
        },
        public   => {
            STATUS  => STATUS_ON,
            PROFILE => 'PublicProfile'
        },
        standard => {
            STATUS  => STATUS_ON,
            PROFILE => 'StandardProfile'
        }
    }
};

my $testFiles = {
    '7' => {
        NetworkAdapter => '7-Win32_NetworkAdapter_2.wmi',
        NetworkAdapterConfiguration => '7-Win32_NetworkAdapterConfiguration_2.wmi',
        DNSRegisteredAdapters => '7-DNSRegisteredAdapters.reg'
    },
    '10' => {
        NetworkAdapter => '10-Win32_NetworkAdapter.wmi',
        NetworkAdapterConfiguration => '10-Win32_NetworkAdapterConfiguration.wmi',
        DNSRegisteredAdapters => '10-DNSRegisteredAdapters.reg'
    }
};

my $expectedProfilesForInventory = {
    '7' => [
        {
            STATUS  => STATUS_OFF,
            PROFILE => 'DomainProfile',
            DESCRIPTION => 'Carte Intel(R) PRO/1000 MT pour station de travail',
            IPADDRESS => '0.0.0.1'
        },
        {
            STATUS  => STATUS_OFF,
            PROFILE => 'DomainProfile',
            DESCRIPTION => 'Carte Intel(R) PRO/1000 MT pour station de travail',
            IPADDRESS6 => 'fe81::fe81:fe81:fe81:fe81'
        },
        {
            STATUS  => STATUS_OFF,
            PROFILE => 'PublicProfile'
        },
        {
            STATUS  => STATUS_OFF,
            PROFILE => 'StandardProfile'
        }
    ],
    '10' => [
        {
            STATUS  => STATUS_ON,
            PROFILE => 'DomainProfile'
        },
        {
            STATUS  => STATUS_ON,
            PROFILE => 'PublicProfile'
        },
        {
            STATUS  => STATUS_ON,
            PROFILE => 'StandardProfile',
            DESCRIPTION => 'Intel(R) PRO/1000 MT Desktop Adapter',
            IPADDRESS => '0.0.0.9'
        },
        {
            STATUS  => STATUS_ON,
            PROFILE => 'StandardProfile',
            DESCRIPTION => 'Intel(R) PRO/1000 MT Desktop Adapter',
            IPADDRESS6 => 'fe82::fe82:fe82:fe82:fe82'
        }
    ]
};

plan tests => 1
        + scalar (keys %$expectedFirewallProfiles)
        + scalar (keys %$expectedProfilesForInventory);

my $testFilesPathRegistry = 'resources/win32/registry/';
my $testFirewallProfilesFilePattern = 'FirewallPolicy.reg';
for my $testKey (keys %$expectedFirewallProfiles) {
    my $expected = $expectedFirewallProfiles->{$testKey};
    my $loadedKey = loadRegistryDump($testFilesPathRegistry . $testKey . '-' . $testFirewallProfilesFilePattern);
    my $firewallProfiles = FusionInventory::Agent::Task::Inventory::Win32::Firewall::_extractFirewallProfilesFromRegistryKey(
        key => $loadedKey
    );
    cmp_deeply (
        $firewallProfiles,
        $expected,
        'test windows ' . $testKey . ' ' . $testFirewallProfilesFilePattern . ' extract firewall profiles from registry'
    );
}

my $testFilesPathWmi = 'resources/win32/wmi/';
my $networkListDumpFilePattern = 'NetworkList.reg';
for my $testKey (keys %$expectedProfilesForInventory) {
    my $loadedKey = loadRegistryDump($testFilesPathRegistry . $testKey . '-' . $testFirewallProfilesFilePattern);
    my $firewallProfiles = FusionInventory::Agent::Task::Inventory::Win32::Firewall::_extractFirewallProfilesFromRegistryKey(
        key => $loadedKey
    );

    my $networkAdapterConfigurationFile = $testFilesPathWmi . $testFiles->{$testKey}->{NetworkAdapterConfiguration};
    my @networkAdapterConfigurationObjects = loadWMIDump(
        $networkAdapterConfigurationFile,
        [ qw/Index Description IPEnabled DHCPServer MACAddress
            MTU DefaultIPGateway DNSServerSearchOrder IPAddress
            IPSubnet DNSDomain/ ]
    );
    fail("can't load WMI objects from file " . $networkAdapterConfigurationFile . ' : ' . $!) unless @networkAdapterConfigurationObjects;

    my $networkAdapterFile = $testFilesPathWmi . $testFiles->{$testKey}->{NetworkAdapter};
    my @networkAdapterObjects = loadWMIDump(
        $networkAdapterFile,
        [ qw/Index PNPDeviceID Speed PhysicalAdapter AdapterTypeId GUID/ ]
    );
    fail("can't load WMI objects from file " . $networkAdapterFile . ' : ' . $!) unless @networkAdapterObjects;

    my $networkListFile = $testFilesPathRegistry . $testKey . '-' . $networkListDumpFilePattern;
    my $loadedKeyNetworkList = loadRegistryDump($networkListFile);
    fail("can't load registry key from file " . $networkListFile . ' : ' . $!)
        unless $loadedKeyNetworkList && $loadedKeyNetworkList->{'Profiles/'} && $loadedKeyNetworkList->{'Signatures/'};

    my $dnsRegisteredAdaptersFile = $testFilesPathRegistry . $testFiles->{$testKey}->{DNSRegisteredAdapters};
    my $dnsRegisteredAdaptersKey = loadRegistryDump($dnsRegisteredAdaptersFile);

    my @profiles = FusionInventory::Agent::Task::Inventory::Win32::Firewall::_makeProfileAndConnectionsAssociation(
        firewallProfiles => $firewallProfiles,
        list => {
            Win32_NetworkAdapterConfiguration => \@networkAdapterConfigurationObjects,
            Win32_NetworkAdapter => \@networkAdapterObjects
        },
        profilesKey => $loadedKeyNetworkList->{'Profiles/'},
        signaturesKey => $loadedKeyNetworkList->{'Signatures/'},
        dnsRegisteredAdaptersKey => $dnsRegisteredAdaptersKey
    );

    # we must sort values before compare it
    my $sortingSub = sub {
        my $list = shift;
        return sort { $a->{PROFILE} lt $b->{PROFILE} || (($a->{PROFILE} eq $b->{PROFILE}) && defined ($a->{IPADDRESS})) } @$list;
    };
    @profiles = &$sortingSub(\@profiles);
    my @expectedProfiles = &$sortingSub($expectedProfilesForInventory->{$testKey});
    sleep 1;
    cmp_deeply (
        \@profiles,
        \@expectedProfiles,
        'test windows ' . $testKey . ' _extractFirewallProfilesFromRegistryKey()'
    );
}

