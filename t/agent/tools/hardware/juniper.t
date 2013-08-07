#!/usr/bin/perl

use strict;

use Test::More;
use Test::Deep;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;

my %tests = (
    'juniper/ex2200.1.walk' => [
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex2200-24t-4g internet router, kernel JUNOS 11.1R3.5 #0: 2011-06-25 00:35:00 UTC     builder@briath.juniper.net:/volume/build/junos/11.1/release/11.1R3.5/obj-arm/bsd/kernels/JUNIPER-EX/kernel Build date: 2011-06-25 00:31:37 UTC Cop',
            SNMPHOSTNAME => 'INTERUFR-219-ex2200-24',
            MAC          => '78:FE:3D:D5:0E:C0',
        },
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex2200-24t-4g internet router, kernel JUNOS 11.1R3.5 #0: 2011-06-25 00:35:00 UTC     builder@briath.juniper.net:/volume/build/junos/11.1/release/11.1R3.5/obj-arm/bsd/kernels/JUNIPER-EX/kernel Build date: 2011-06-25 00:31:37 UTC Cop',
            SNMPHOSTNAME => 'INTERUFR-219-ex2200-24',
            MAC          => '78:FE:3D:D5:0E:C0',
            MODELSNMP    => 'Networking2185',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CW0211513175',
        }
    ],
    'juniper/ex2200.2.walk' => [
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex2200-48t-4g internet router, kernel JUNOS 11.4R5.5 #0: 2012-08-25 05:21:13 UTC     builder@evenath.juniper.net:/volume/build/junos/11.4/release/11.4R5.5/obj-arm/bsd/kernels/JUNIPER-EX-2200/kernel Build date: 2012-08-25 04:48:47 U',
            SNMPHOSTNAME => 'jtc407-01',
            MAC          => '78:FE:3D:36:F7:06',
        },
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex2200-48t-4g internet router, kernel JUNOS 11.4R5.5 #0: 2012-08-25 05:21:13 UTC     builder@evenath.juniper.net:/volume/build/junos/11.4/release/11.4R5.5/obj-arm/bsd/kernels/JUNIPER-EX-2200/kernel Build date: 2012-08-25 04:48:47 U',
            SNMPHOSTNAME => 'jtc407-01',
            MAC          => '78:FE:3D:36:F7:00',
            MODELSNMP    => 'Networking2495',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef,
        }
    ],
    'juniper/ex2200.3.walk' => [
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex2200-c-12p-2g internet router, kernel JUNOS 11.3R1.7 #0: 2011-08-30 11:49:21 UTC     builder@dagmath.juniper.net:/volume/build/junos/11.3/release/11.3R1.7/obj-arm/bsd/kernels/JUNIPER-EX-2200/kernel Build date: 2011-08-30 11:32:01',
            SNMPHOSTNAME => 'AB-B404-23-ex2200',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex2200-c-12p-2g internet router, kernel JUNOS 11.3R1.7 #0: 2011-08-30 11:49:21 UTC     builder@dagmath.juniper.net:/volume/build/junos/11.3/release/11.3R1.7/obj-arm/bsd/kernels/JUNIPER-EX-2200/kernel Build date: 2011-08-30 11:32:01',
            SNMPHOSTNAME => 'AB-B404-23-ex2200',
            MAC          => undef,
            MODELSNMP    => 'Networking2181',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef,
        }
    ],
    'juniper/ex2200.4.walk' => [
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex2200-48t-4g internet router, kernel JUNOS 11.1R3.5 #0: 2011-06-25 00:35:00 UTC     builder@briath.juniper.net:/volume/build/junos/11.1/release/11.1R3.5/obj-arm/bsd/kernels/JUNIPER-EX/kernel Build date: 2011-06-25 00:31:37 UTC Cop',
            SNMPHOSTNAME => 'AB-BU6-132-ex2200-48',
            MAC          => '78:FE:3D:37:5E:C0',
        },
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex2200-48t-4g internet router, kernel JUNOS 11.1R3.5 #0: 2011-06-25 00:35:00 UTC     builder@briath.juniper.net:/volume/build/junos/11.1/release/11.1R3.5/obj-arm/bsd/kernels/JUNIPER-EX/kernel Build date: 2011-06-25 00:31:37 UTC Cop',
            SNMPHOSTNAME => 'AB-BU6-132-ex2200-48',
            MAC          => '78:FE:3D:37:5E:C0',
            MODELSNMP    => 'Networking2190',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CU0211450517',
        }
    ],
    'juniper/ex2200.5.walk' => [
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex2200-c-12p-2g internet router, kernel JUNOS 11.4R1.6 #0: 2011-11-15 10:11:59 UTC     builder@evenath.juniper.net:/volume/build/junos/11.4/release/11.4R1.6/obj-arm/bsd/kernels/JUNIPER-EX-2200/kernel Build date: 2011-11-15 09:57:14',
            SNMPHOSTNAME => 'C005-236b-ex2200',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex2200-c-12p-2g internet router, kernel JUNOS 11.4R1.6 #0: 2011-11-15 10:11:59 UTC     builder@evenath.juniper.net:/volume/build/junos/11.4/release/11.4R1.6/obj-arm/bsd/kernels/JUNIPER-EX-2200/kernel Build date: 2011-11-15 09:57:14',
            SNMPHOSTNAME => 'C005-236b-ex2200',
            MAC          => undef,
            MODELSNMP    => 'Networking2180',
            MODEL        => undef,
            SERIAL       => undef,
            FIRMWARE     => undef,
        }
    ],
    'juniper/ex2200.6.walk' => [
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex2200-48t-4g internet router, kernel JUNOS 11.4R5.5 #0: 2012-08-25 05:21:13 UTC     builder@evenath.juniper.net:/volume/build/junos/11.4/release/11.4R5.5/obj-arm/bsd/kernels/JUNIPER-EX-2200/kernel Build date: 2012-08-25 04:48:47 U',
            SNMPHOSTNAME => 'jtc407-01',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex2200-48t-4g internet router, kernel JUNOS 11.4R5.5 #0: 2012-08-25 05:21:13 UTC     builder@evenath.juniper.net:/volume/build/junos/11.4/release/11.4R5.5/obj-arm/bsd/kernels/JUNIPER-EX-2200/kernel Build date: 2012-08-25 04:48:47 U',
            SNMPHOSTNAME => 'jtc407-01',
            MAC          => '78:FE:3D:36:F7:00',
            MODELSNMP    => 'Networking2495',
            MODEL        => undef,
            SERIAL       => undef,
            FIRMWARE     => undef,
        }
    ],
    'juniper/ex3200.walk' => [
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex3200-48p internet router, kernel JUNOS 10.4R2.6 #0: 2011-02-06 23:48:13 UTC     builder@warth.juniper.net:/volume/build/junos/10.4/release/10.4R2.6/obj-powerpc/bsd/sys/compile/JUNIPER-EX Build date: 2011-02-06 23:17:05 UTC Copyri',
            SNMPHOSTNAME => 'jtc20-03',
            MAC          => '2C:6B:F5:9A:7E:80',
        },
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex3200-48p internet router, kernel JUNOS 10.4R2.6 #0: 2011-02-06 23:48:13 UTC     builder@warth.juniper.net:/volume/build/junos/10.4/release/10.4R2.6/obj-powerpc/bsd/sys/compile/JUNIPER-EX Build date: 2011-02-06 23:17:05 UTC Copyri',
            SNMPHOSTNAME => 'jtc20-03',
            MAC          => '2C:6B:F5:9A:7E:80',
            MODELSNMP    => 'Networking2450',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'BL0210129540',
        }
    ],
    'juniper/ex4200.walk' => [
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex4200-48p internet router, kernel JUNOS 10.4R3.4 #0: 2011-03-19 22:06:32 UTC     builder@warth.juniper.net:/volume/build/junos/10.4/release/10.4R3.4/obj-powerpc/bsd/sys/compile/JUNIPER-EX Build date: 2011-03-19 21:51:24 UTC Copyri',
            SNMPHOSTNAME => 'jte4-01',
            MAC          => '2C:6B:F5:9B:48:80',
        },
        {
            MANUFACTURER => 'Juniper',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Juniper Networks, Inc. ex4200-48p internet router, kernel JUNOS 10.4R3.4 #0: 2011-03-19 22:06:32 UTC     builder@warth.juniper.net:/volume/build/junos/10.4/release/10.4R3.4/obj-powerpc/bsd/sys/compile/JUNIPER-EX Build date: 2011-03-19 21:51:24 UTC Copyri',
            SNMPHOSTNAME => 'jte4-01',
            MAC          => '2C:6B:F5:9B:48:80',
            MODELSNMP    => 'Networking2448',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'BQ0210122093',
        }
    ],
    'juniper/srx3400.1.walk' => [
        {
            DESCRIPTION  => 'Routeur Dauphine Juniper SRX3400',
            SNMPHOSTNAME => 'Dauphine-routeur',
            MAC          => '00:21:59:86:A8:00',
        },
        {
            DESCRIPTION  => 'Routeur Dauphine Juniper SRX3400',
            SNMPHOSTNAME => 'Dauphine-routeur',
            MAC          => '00:21:59:86:A8:00',
        }
    ],
    'juniper/srx3400.2.walk' => [
        {
            DESCRIPTION  => 'Routeur Dauphine Juniper SRX3400',
            SNMPHOSTNAME => 'Dauphine-routeur',
            MAC          => '00:21:59:86:A8:00',
        },
        {
            DESCRIPTION  => 'Routeur Dauphine Juniper SRX3400',
            SNMPHOSTNAME => 'Dauphine-routeur',
            MAC          => '00:21:59:86:A8:00',
        }
    ],
    'juniper/srx3400.3.walk' => [
        {
            DESCRIPTION  => 'Routeur Dauphine Juniper SRX3400',
            SNMPHOSTNAME => 'Dauphine-routeur',
            MAC          => '00:21:59:86:A8:00',
        },
        {
            DESCRIPTION  => 'Routeur Dauphine Juniper SRX3400',
            SNMPHOSTNAME => 'Dauphine-routeur',
            MAC          => '00:21:59:86:A8:00',
        }
    ],
);

if (!$ENV{SNMPWALK_DATABASE}) {
    plan skip_all => 'SNMP walks database required';
} elsif (!$ENV{SNMPMODEL_DATABASE}) {
    plan skip_all => 'SNMP models database required';
} else {
    plan tests => 2 * scalar keys %tests;
}

my $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
    file => "$ENV{SNMPMODEL_DATABASE}/dictionary.xml"
);

foreach my $test (sort keys %tests) {
    my $snmp = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );
    my %device0 = getDeviceInfo($snmp);
    my %device1 = getDeviceInfo($snmp, $dictionary);
    cmp_deeply(\%device0, $tests{$test}->[0], $test);
    cmp_deeply(\%device1, $tests{$test}->[1], $test);
}
