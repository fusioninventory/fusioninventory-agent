#!/usr/bin/perl

use strict;

use Test::More;
use Test::Deep;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Task::NetDiscovery;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;

my %tests = (
    'xerox/DocuPrint_N2125.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox DocuPrint N2125 Network Laser Printer - 2.12-02 ',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox DocuPrint N2125 Network Laser Printer - 2.12-02 ',
            SNMPHOSTNAME  => '',
            MAC           => undef,
            MODELSNMP     => 'Printer0687',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => '3510349171',
        }
    ],
    'xerox/Phaser_5550DT.1.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.03.00',
            SNMPHOSTNAME => 'Phaser 5550DT',
            MAC          => undef
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.03.00',
            SNMPHOSTNAME  => 'Phaser 5550DT',
            MAC           => undef,
            MODELSNMP     => 'Printer0688',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => 'KNB015751',
        },
    ],
    'xerox/Phaser_5550DT.2.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.01.00',
            SNMPHOSTNAME => 'Phaser 5550DT-1',
            MAC          => undef,
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.01.00',
            SNMPHOSTNAME  => 'Phaser 5550DT-1',
            MAC           => undef,
            MODELSNMP     => 'Printer0689',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => 'KNB015753',
        },
    ],
    'xerox/Phaser_6180MFP.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 6180MFP-D; Net 11.74,ESS 200802151717,IOT 05.09.00,Boot 200706151125',
            SNMPHOSTNAME => 'Phaser 6180MFP-D-E360D7',
            MAC          => undef,
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox Phaser 6180MFP-D; Net 11.74,ESS 200802151717,IOT 05.09.00,Boot 200706151125',
            SNMPHOSTNAME  => 'Phaser 6180MFP-D-E360D7',
            MAC           => undef,
            MODELSNMP     => 'Printer0370',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => 'GPX259705',
        },
    ],
    'xerox/WorkCentre_5632.1.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME => 'SO007XN',
            MAC          => '00:00:AA:CF:9E:5A',
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME  => 'SO007XN',
            MAC           => '00:00:AA:CF:9E:5A',
            MODELSNMP     => 'Printer0705',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => '3641509891',
        },
    ],
    'xerox/WorkCentre_5632.2.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME => 'SO011XN',
            MAC          => '00:00:AA:CF:84:10',
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME  => 'SO011XN',
            MAC           => '00:00:AA:CF:84:10',
            MODELSNMP     => 'Printer0705',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => '3641504792',
        },
    ],
    'xerox/WorkCentre_7125.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 7125;System 71.21.21,ESS1.210.4,IOT 5.12.0,FIN A15.2.0,ADF 11.0.1,SJFI3.0.16,SSMI1.14.1',
            SNMPHOSTNAME => 'XEROX WorkCentre 7125',
            MAC          => undef,
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox WorkCentre 7125;System 71.21.21,ESS1.210.4,IOT 5.12.0,FIN A15.2.0,ADF 11.0.1,SJFI3.0.16,SSMI1.14.1',
            SNMPHOSTNAME  => 'XEROX WorkCentre 7125',
            MAC           => undef,
            MODELSNMP     => 'Printer0690',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => '3325295030',
        },
    ],
    'xerox/WorkCentre_7435.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 7435;System 75.3.1,ESS PS1.222.18,IOT 41.1.0,FIN B13.8.0,IIT 22.13.1,ADF 20.0.0,SJFI3.0.12,SSMI1.11.1',
            SNMPHOSTNAME => 'WorkCentre 7435',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 7435;System 75.3.1,ESS PS1.222.18,IOT 41.1.0,FIN B13.8.0,IIT 22.13.1,ADF 20.0.0,SJFI3.0.12,SSMI1.11.1',
            SNMPHOSTNAME => 'WorkCentre 7435',
            MAC          => undef,
        },
    ],
);

if (!$ENV{SNMPWALK_DATABASE}) {
    plan skip_all => 'SNMP walks database required';
} else {
    plan tests => 2 * scalar keys %tests;
}

my $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
    file => 'resources/dictionary.xml'
);

foreach my $test (sort keys %tests) {
    my $snmp = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );
    my $sysdescr = $snmp->get('.1.3.6.1.2.1.1.1.0');
    my %device0 = FusionInventory::Agent::Task::NetDiscovery::_getDeviceBySNMP(
        $sysdescr, $snmp
    );
    my %device1 = FusionInventory::Agent::Task::NetDiscovery::_getDeviceBySNMP(
        $sysdescr, $snmp, $dictionary
    );
    cmp_deeply(\%device0, $tests{$test}->[0], $test);
    cmp_deeply(\%device1, $tests{$test}->[1], $test);
}
