#!/usr/bin/perl

use warnings;
use strict;

use FusionInventory::Agent::Task::NetDiscovery;
use File::Basename;
use Test::More;
use Data::Dumper;

my %result = (
        '10.0.1.147' => {
          'DNSHOSTNAME' => 'dd-wrt.lan',
          'NETPORTVENDOR' => 'Cisco-Linksys',
          'MAC' => '00:1D:7E:43:96:57'
        },
        '10.0.1.1' => {
          'DNSHOSTNAME' => 'dd-wrt.lan',
          'NETPORTVENDOR' => 'Cisco-Linksys',
          'MAC' => '00:1D:7E:43:96:57'
        },
        '10.0.1.127' => {
          'DNSHOSTNAME' => 'android_aab1c03df5657e26.lan',
          'NETPORTVENDOR' => undef,
          'MAC' => '38:E7:D8:D3:CA:AD'
        },
        '10.0.1.128' => {
          'DNSHOSTNAME' => 'tosh-r630.local',
          'NETPORTVENDOR' => 'Cisco-Linksys',
          'MAC' => '00:1D:7E:43:96:57'
        },
        '88.191.59.1' => {
          'NETPORTVENDOR' => 'Cisco Systems',
          'MAC' => '00:1A:A1:85:9A:BF'
        },
        'google.com' => {
        }
);

my @xmlFiles = glob('resources/nmap-xml/*');
plan tests => 2 * int @xmlFiles;

foreach my $xmlFile (@xmlFiles) {
    my $name = basename($xmlFile);

    my $xml;
    open F, "<$xmlFile" or die;
    {
    $/ = undef;
    $xml = <F>;
    }
    close F;
    my $result = FusionInventory::Agent::Task::NetDiscovery::parseNmap($xml);
    ok ($result);
    is_deeply($result, $result{$name}, $name) or print Dumper($result);
}

