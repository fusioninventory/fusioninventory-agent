package FusionInventory::Test::Hardware;

use strict;
use warnings;
use base 'Exporter';

use Test::More;
use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;

our @EXPORT = qw(
    setPlan
    getDictionnary
    getIndex
    getSNMP
    getModel
);

sub setPlan {
    my ($count) = @_;

    if (!$ENV{SNMPWALK_DATABASE}) {
        plan skip_all => 'SNMP walks database required';
    } elsif (!$ENV{SNMPMODEL_DATABASE}) {
        plan skip_all => 'SNMP models database required';
    } else {
        YAML->require();
        plan(skip_all => 'YAML required') if $EVAL_ERROR;
        YAML->import('LoadFile');
    }

    plan tests => 3 * $count;
}

sub getDictionnary {
    return FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
        file => "$ENV{SNMPMODEL_DATABASE}/dictionary.xml"
    );
}

sub getIndex {
    return LoadFile("$ENV{SNMPMODEL_DATABASE}/index.yaml");
}

sub getSNMP {
    my ($test) = @_;
    return FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );
}

sub getModel {
    my ($index, $model_id) = @_;
    return $model_id ?
        loadModel("$ENV{SNMPMODEL_DATABASE}/$index->{$model_id}") : undef;
}
