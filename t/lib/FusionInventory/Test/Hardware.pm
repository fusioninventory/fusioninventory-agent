package FusionInventory::Test::Hardware;

use strict;
use warnings;
use base 'Exporter';

use Test::More;
use Test::Deep qw(cmp_deeply);
use YAML qw(LoadFile);

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;

our @EXPORT = qw(
    runDiscoveryTests
    runInventoryTests
);

sub runDiscoveryTests {
    my %tests = @_;

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
        cmp_deeply(\%device0, $tests{$test}->[0], "$test: base stage");

        my %device1 = getDeviceInfo($snmp, $dictionary);
        cmp_deeply(\%device1, $tests{$test}->[1], "$test: base + dictionnary stage");
    }
}

sub runInventoryTests {
    my %tests = @_;

    if (!$ENV{SNMPWALK_DATABASE}) {
        plan skip_all => 'SNMP walks database required';
    } elsif (!$ENV{SNMPMODEL_DATABASE}) {
        plan skip_all => 'SNMP models database required';
    } else {
        plan tests => 3 * scalar keys %tests;
    }

    my $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
        file => "$ENV{SNMPMODEL_DATABASE}/dictionary.xml"
    );

    my $index = LoadFile("$ENV{SNMPMODEL_DATABASE}/index.yaml");

    foreach my $test (sort keys %tests) {
        my $snmp = FusionInventory::Agent::SNMP::Mock->new(
            file => "$ENV{SNMPWALK_DATABASE}/$test"
        );

        my %device0 = getDeviceInfo($snmp);
        cmp_deeply(\%device0, $tests{$test}->[0], "$test: base stage");

        my %device1 = getDeviceInfo($snmp, $dictionary);
        cmp_deeply(\%device1, $tests{$test}->[1], "$test: base + dictionnary stage");

        my $model_id = $tests{$test}->[1]->{MODELSNMP};
        my $model = $model_id ?
            _loadModel("$ENV{SNMPMODEL_DATABASE}/$index->{$model_id}") : undef;

        my $device3 = FusionInventory::Agent::Tools::Hardware::getDeviceFullInfo(
            snmp  => $snmp,
            model => $model,
        );
        cmp_deeply($device3, $tests{$test}->[2], "$test: base + model stage");
       
    }
}

sub _loadModel {
    my ($file) = @_;

    my $model = XML::TreePP->new()->parsefile($file)->{model};

    my @get = map {
        {
            OID    => $_->{oid},
            OBJECT => $_->{mapping_name},
            VLAN   => $_->{vlan},
        }
    } grep {
        $_->{dynamicport} == 0
    } grep {
        $_->{mapping_name}
    } @{$model->{oidlist}->{oidobject}};

    my @walk = map {
        {
            OID    => $_->{oid},
            OBJECT => $_->{mapping_name},
            VLAN   => $_->{vlan},
        }
    } grep {
        $_->{dynamicport} == 1
    } grep {
        $_->{mapping_name}
    } @{$model->{oidlist}->{oidobject}};

    return {
        ID   => 1,
        NAME => $model->{name},
        TYPE => $model->{type},
        GET  => { map { $_->{OBJECT} => $_ } @get  },
        WALK => { map { $_->{OBJECT} => $_ } @walk }
    }
}
