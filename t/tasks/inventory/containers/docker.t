#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::Containers::Docker;

plan tests => 3;

my @expectedList = (
    'str1',
    'str2',
    'str3',
    '',
    'str5',
    'str6'
);

my @inputList = (
    'str1',
    'str2',
    'str3',
    'str5',
    'str6',
    ''
);

my @resultList = FusionInventory::Agent::Task::Inventory::Containers::Docker::_rightTranslation(\@inputList, 3);
cmp_deeply(\@expectedList, \@resultList, 'test _rightTranslation');


my $test = [
        {
            ID => '7938ef110db9',
            IMAGE=> 'driket54/glpi',
            COMMAND=> "/bin/sh -c /opt/star",
            CREATED=> '3 months ago',
            STATUS=> 'Exited (137) 3 months ago',
            PORTS => '',
            NAME=> 'suspicious_dubinsky',
            TYPE     => 'docker',
        },
        {
            ID => '216ff5c60d3e',
            IMAGE=> 'driket54/glpi',
            COMMAND=> "/bin/sh -c /opt/star",
            CREATED=> '3 months ago',
            STATUS=> 'Created',
            NAME=> 'jolly_jepsen',
            PORTS => '',
            TYPE     => 'docker',
        },
        {
            ID => '22b330476769',
            IMAGE=> 'driket54/glpi',
            COMMAND=> "/bin/sh -c /opt/star",
            CREATED=> '3 months ago',
            STATUS=> 'Exited (137) 3 months ago',
            NAME=> 'lonely_archimedes',
            PORTS => '',
            TYPE     => 'docker',
        },
        {
            ID => '2473dae7d24d',
            IMAGE=> 'driket54/glpi',
            COMMAND=> "/bin/sh -c /opt/star",
            CREATED=> '3 months ago',
            STATUS=> 'Created',
            NAME=> 'loving_noyce',
            PORTS => '',
            TYPE     => 'docker',
        },
        {
            ID => '982fe8008bbf',
            IMAGE=> 'mariadb:5.5',
            COMMAND=> "docker-entrypoint.sh",
            CREATED=> '3 months ago',
            STATUS=> 'Exited (0) 3 months ago',
            NAME=> 'maraidb-5.5-glpi',
            PORTS => '',
            TYPE     => 'docker',
        },
        {
            ID => '5cc66341f6bc',
            IMAGE=> 'driket54/glpi',
            COMMAND=> "/bin/sh -c /opt/star",
            CREATED=> '3 months ago',
            STATUS=> 'Exited (137) 3 months ago',
            NAME=> 'glpiall_glpi_1',
            PORTS => '',
            TYPE     => 'docker',
        },
        {
            ID => 'cdd54d47e939',
            IMAGE=> 'mariadb',
            COMMAND=> "docker-entrypoint.sh",
            CREATED=> '3 months ago',
            STATUS=> 'Exited (0) 3 months ago',
            NAME=> 'glpiall_mysql_1',
            PORTS => '',
            TYPE     => 'docker',
        },
        {
            ID => '7756c1009954',
            IMAGE=> 'ef32c3db3aed',
            COMMAND=> "/opt/karaf/bin/karaf",
            CREATED=> '6 months ago',
            STATUS=> 'Exited (137) 6 months ago',
            NAME=> 'karaf',
            PORTS => '',
            TYPE     => 'docker',
        },
        {
            ID => '9a7afffcf153',
            IMAGE=> 'postgres:9.4',
            COMMAND=> "/docker-entrypoint.s",
            CREATED=> '6 months ago',
            STATUS=> 'Exited (137) 6 months ago',
            NAME=> 'postgresql_karaf',
            PORTS => '',
            TYPE     => 'docker',
        },
        {
            ID => '58bef002b42c',
            IMAGE=> 'jenkins',
            COMMAND=> "/bin/tini -- /usr/lo",
            CREATED=> '7 months ago',
            STATUS=> 'Exited (143) 7 months ago',
            NAME=> 'happy_ritchie',
            PORTS => '',
            TYPE     => 'docker',
        },
        {
            ID => 'a0e36958b03c',
            IMAGE=> 'postgres',
            COMMAND=> "/docker-entrypoint.s",
            CREATED=> '7 months ago',
            STATUS=> 'Exited (0) 7 months ago',
            NAME=> 'kimios-postgres',
            PORTS => '',
            TYPE     => 'docker',
        },
        {
            ID => 'b98829235592',
            IMAGE=> 'driket54/glpi',
            COMMAND=> "/bin/sh -c /opt/star",
            CREATED=> '8 months ago',
            STATUS=> 'Up 6 minutes',
            PORTS=> '0.0.0.0:8090->80/tcp',
            NAME=> 'glpi_http',
            TYPE     => 'docker',
        },
        {
            ID => 'f8700da0f53c',
            IMAGE=> 'mariadb:5.5',
            COMMAND=> "docker-entrypoint.sh",
            CREATED=> '8 months ago',
            STATUS=> 'Exited (137) 7 months ago',
            PORTS=> '0.0.0.0:3306->3306/tcp',
            NAME=> 'mariadb-glpi',
            TYPE     => 'docker',
        }
];


my @containers = FusionInventory::Agent::Task::Inventory::Containers::Docker::_getContainers(
    file => 'resources/containers/docker/docker.sample'
);
cmp_deeply(\@containers, $test, 'test _getContainers()');
