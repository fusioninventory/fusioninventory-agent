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

plan tests => 1
        + scalar (keys %$expectedFirewallProfiles);

my $testFilesPath = 'resources/win32/registry/';
my $testFirewallProfilesFilePattern = 'FirewallPolicy.reg';
for my $testKey (keys %$expectedFirewallProfiles) {
    my $expected = $expectedFirewallProfiles->{$testKey};
    my $loadedKey = loadRegistryDump($testFilesPath . $testKey . '-' . $testFirewallProfilesFilePattern);
    my $firewallProfiles = FusionInventory::Agent::Task::Inventory::Win32::Firewall::_extractFirewallProfilesFromRegistryKey(
        key => $loadedKey
    );
    cmp_deeply (
        $firewallProfiles,
        $expected,
        'extract firewall profiles from registry'
    );
}

