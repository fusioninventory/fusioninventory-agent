#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'extreme/summit300-24.walk' => [
        {
            MANUFACTURER => 'Extreme',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit300-24 - Version 7.4e.2 (Build 6) by Release_Master 09/13/05 12:17:15',
            SNMPHOSTNAME => 'xtb12-2',
            MAC          => '00:04:96:1F:91:50',
            MODEL        => 'Summit 300-24',
        },
        {
            MANUFACTURER => 'Extreme',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit300-24 - Version 7.4e.2 (Build 6) by Release_Master 09/13/05 12:17:15',
            SNMPHOSTNAME => 'xtb12-2',
            MAC          => '00:04:96:1F:91:50',
            MODEL        => 'Summit 300-24',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Extreme',
                TYPE         => 'NETWORKING',
                MODEL        => 'Summit 300-24',
            },
        }
    ],
    'extreme/summit300-48.walk' => [
        {
            MANUFACTURER => 'Extreme',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit300-48 - Version 7.4e.2 (Build 6) by Release_Master 09/13/05 12:44:51',
            SNMPHOSTNAME => 'xtc13',
            MAC          => '00:04:96:1C:71:00',
            MODEL        => 'Summit 300-48',
        },
        {
            MANUFACTURER => 'Extreme',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit300-48 - Version 7.4e.2 (Build 6) by Release_Master 09/13/05 12:44:51',
            SNMPHOSTNAME => 'xtc13',
            MAC          => '00:04:96:1C:71:00',
            MODEL        => 'Summit 300-48',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Extreme',
                TYPE         => 'NETWORKING',
                MODEL        => 'Summit 300-48',
            },
        }
    ],
    'extreme/summit400-48t.walk' => [
        {
            MANUFACTURER => 'Extreme',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit400-48t - Version 7.2e.1 (Build 10) by Release_Master 03/26/04 18:29:56',
            SNMPHOSTNAME => 'xtc6',
            MAC          => '00:04:96:18:5B:61',
            MODEL        => 'Summit 400-48t',
        },
        {
            MANUFACTURER => 'Extreme',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit400-48t - Version 7.2e.1 (Build 10) by Release_Master 03/26/04 18:29:56',
            SNMPHOSTNAME => 'xtc6',
            MAC          => '00:04:96:18:5B:61',
            MODEL        => 'Summit 400-48t',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Extreme',
                TYPE         => 'NETWORKING',
                MODEL        => 'Summit 400-48t',
            },
        }
    ],
    'extreme/summit48si-2.walk' => [
        {
            MANUFACTURER => 'Extreme',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit48si - Version 7.3.2 (Build 3) by Release_Master 02/21/05 16:35:08',
            SNMPHOSTNAME => 'xta6',
            MAC          => '00:01:30:12:A6:C0',
            MODEL        => 'Summit 48si',
        },
        {
            MANUFACTURER => 'Extreme',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit48si - Version 7.3.2 (Build 3) by Release_Master 02/21/05 16:35:08',
            SNMPHOSTNAME => 'xta6',
            MAC          => '00:01:30:12:A6:C0',
            MODEL        => 'Summit 48si',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Extreme',
                TYPE         => 'NETWORKING',
                MODEL        => 'Summit 48si',
            },
        }
    ],
    'extreme/summit48si-3.walk' => [
        {
            MANUFACTURER => 'Extreme',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit48si - Version 7.0.1 (Build 11) by Release_Master 03/28/03 02:09:23',
            SNMPHOSTNAME => 'xtb12-1',
            MAC          => '00:01:30:12:91:80',
            MODEL        => 'Summit 48si',
        },
        {
            MANUFACTURER => 'Extreme',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit48si - Version 7.0.1 (Build 11) by Release_Master 03/28/03 02:09:23',
            SNMPHOSTNAME => 'xtb12-1',
            MAC          => '00:01:30:12:91:80',
            MODEL        => 'Summit 48si',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Extreme',
                TYPE         => 'NETWORKING',
                MODEL        => 'Summit 48si',
            },
        }
    ],
    'extreme/summit48si.walk' => [
        {
            MANUFACTURER => 'Extreme',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit48si - Version 7.0.0 (Build 61) by Release_Master 12/02/04 14:27:36',
            SNMPHOSTNAME => 'xt17t',
            MAC          => '00:01:30:12:A6:D0',
            MODEL        => 'Summit 48si',
        },
        {
            MANUFACTURER => 'Extreme',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit48si - Version 7.0.0 (Build 61) by Release_Master 12/02/04 14:27:36',
            SNMPHOSTNAME => 'xt17t',
            MAC          => '00:01:30:12:A6:D0',
            MODEL        => 'Summit 48si',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Extreme',
                TYPE         => 'NETWORKING',
                MODEL        => 'Summit 48si',
            },
        }
    ],
);

setPlan(scalar keys %tests);

my $dictionary = getDictionnary();
my $index      = getIndex();

foreach my $test (sort keys %tests) {
    my $snmp  = getSNMP($test);
    my $model = getModel($index, $tests{$test}->[1]->{MODELSNMP});

    my %device0 = getDeviceInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(\%device0, $tests{$test}->[0], "$test: base stage");

    my %device1 = getDeviceInfo(
        snmp       => $snmp,
        dictionary => $dictionary,
        datadir    => './share'
    );
    cmp_deeply(\%device1, $tests{$test}->[1], "$test: base + dictionnary stage");

    my $device3 = getDeviceFullInfo(
        snmp    => $snmp,
        model   => $model,
        datadir => './share'
    );
    cmp_deeply($device3, $tests{$test}->[2], "$test: base + model stage");
}
