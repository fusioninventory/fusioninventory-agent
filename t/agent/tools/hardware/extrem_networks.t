#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'extreme-networks/summit300-24.walk' => [
        {
            MANUFACTURER => 'Extrem Networks',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit300-24 - Version 7.4e.2 (Build 6) by Release_Master 09/13/05 12:17:15',
            SNMPHOSTNAME => 'xtb12-2',
            MAC          => '00:04:96:1F:91:50',
            MODEL        => 'summit300-24',
        },
        {
            MANUFACTURER => 'Extrem Networks',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit300-24 - Version 7.4e.2 (Build 6) by Release_Master 09/13/05 12:17:15',
            SNMPHOSTNAME => 'xtb12-2',
            MAC          => '00:04:96:1F:91:50',
            MODEL        => 'summit300-24',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Extrem Networks',
                TYPE         => 'NETWORKING',
                MODEL        => 'summit300-24',
            },
        }
    ],
    'extreme-networks/summit300-48.walk' => [
        {
            MANUFACTURER => 'Extrem Networks',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit300-48 - Version 7.4e.2 (Build 6) by Release_Master 09/13/05 12:44:51',
            SNMPHOSTNAME => 'xtc13',
            MAC          => '00:04:96:1C:71:00',
            MODEL        => 'summit300-48',
        },
        {
            MANUFACTURER => 'Extrem Networks',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit300-48 - Version 7.4e.2 (Build 6) by Release_Master 09/13/05 12:44:51',
            SNMPHOSTNAME => 'xtc13',
            MAC          => '00:04:96:1C:71:00',
            MODEL        => 'summit300-48',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Extrem Networks',
                TYPE         => 'NETWORKING',
                MODEL        => 'summit300-48',
            },
        }
    ],
    'extreme-networks/summit400-48t.walk' => [
        {
            MANUFACTURER => 'Extrem Networks',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit400-48t - Version 7.2e.1 (Build 10) by Release_Master 03/26/04 18:29:56',
            SNMPHOSTNAME => 'xtc6',
            MAC          => '00:04:96:18:5B:61',
            MODEL        => 'summit400-48t',
        },
        {
            MANUFACTURER => 'Extrem Networks',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit400-48t - Version 7.2e.1 (Build 10) by Release_Master 03/26/04 18:29:56',
            SNMPHOSTNAME => 'xtc6',
            MAC          => '00:04:96:18:5B:61',
            MODEL        => 'summit400-48t',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Extrem Networks',
                TYPE         => 'NETWORKING',
                MODEL        => 'summit400-48t',
            },
        }
    ],
    'extreme-networks/summit48si-2.walk' => [
        {
            MANUFACTURER => 'Extrem Networks',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit48si - Version 7.3.2 (Build 3) by Release_Master 02/21/05 16:35:08',
            SNMPHOSTNAME => 'xta6',
            MAC          => '00:01:30:12:A6:C0',
            MODEL        => 'summit48si',
        },
        {
            MANUFACTURER => 'Extrem Networks',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit48si - Version 7.3.2 (Build 3) by Release_Master 02/21/05 16:35:08',
            SNMPHOSTNAME => 'xta6',
            MAC          => '00:01:30:12:A6:C0',
            MODEL        => 'summit48si',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Extrem Networks',
                TYPE         => 'NETWORKING',
                MODEL        => 'summit48si',
            },
        }
    ],
    'extreme-networks/summit48si-3.walk' => [
        {
            MANUFACTURER => 'Extrem Networks',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit48si - Version 7.0.1 (Build 11) by Release_Master 03/28/03 02:09:23',
            SNMPHOSTNAME => 'xtb12-1',
            MAC          => '00:01:30:12:91:80',
            MODEL        => 'summit48si',
        },
        {
            MANUFACTURER => 'Extrem Networks',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit48si - Version 7.0.1 (Build 11) by Release_Master 03/28/03 02:09:23',
            SNMPHOSTNAME => 'xtb12-1',
            MAC          => '00:01:30:12:91:80',
            MODEL        => 'summit48si',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Extrem Networks',
                TYPE         => 'NETWORKING',
                MODEL        => 'summit48si',
            },
        }
    ],
    'extreme-networks/summit48si.walk' => [
        {
            MANUFACTURER => 'Extrem Networks',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit48si - Version 7.0.0 (Build 61) by Release_Master 12/02/04 14:27:36',
            SNMPHOSTNAME => 'xt17t',
            MAC          => '00:01:30:12:A6:D0',
            MODEL        => 'summit48si',
        },
        {
            MANUFACTURER => 'Extrem Networks',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Summit48si - Version 7.0.0 (Build 61) by Release_Master 12/02/04 14:27:36',
            SNMPHOSTNAME => 'xt17t',
            MAC          => '00:01:30:12:A6:D0',
            MODEL        => 'summit48si',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Extrem Networks',
                TYPE         => 'NETWORKING',
                MODEL        => 'summit48si',
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
