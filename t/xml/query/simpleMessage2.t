#!/usr/bin/perl
use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Logger;

eval { require XML::TreePP; };
if ($EVAL_ERROR) {
    my $msg = 'Missing XML::TreePP';
    plan(skip_all => $msg);
}

plan tests => 2;
my $test1 =  {
    'REQUEST' => {
        'QUERY' => 'TEST',
        'BAR' => 'bar',
        'FOO' => 'foo',
        'DEVICEID' => 'test-deviceid'
    }
}; 
my $test2 = {

    'REQUEST' => {
    'QUERY' => 'TEST',
    'BAR' => 'bar',
    'CASTOR' => [
    {
        'GF' => {
            'FFFF' => 'GG'
        },
        'FFF' => 'GG',
        'FOO' => 'fu'
    },
    {
        'FddF' => {
            'GG' => 'O'
        }
    }
    ],
    'FOO' => 'foo',
    'DEVICEID' => 'test-deviceid'
    }
};

my $tpp =  XML::TreePP->new();
#plan tests => scalar keys %tests;
my $logger = FusionInventory::Logger->new ();
my $target = {deviceid => 'test-deviceid'}; 
my $query1 = FusionInventory::Agent::XML::Query::SimpleMessage->new({
    target => $target,
    msg => {
        QUERY => 'TEST',
        FOO => 'foo',
        BAR => 'bar', 
    }
});

my $xml = $query1->getContent();
my $href = $tpp->parse( $xml );

is_deeply($href, $test1, "simpleMessage");

my $query2 = FusionInventory::Agent::XML::Query::SimpleMessage->new({
    target => $target,
    msg => {
        QUERY => 'TEST',
        FOO => 'foo',
        BAR => 'bar',
        CASTOR => [ {
            FOO => 'fu',
            FFF => 'GG',
            GF =>  [ { FFFF => 'GG' } ]
        },
        {

            FddF => [ { GG => 'O' } ]
        }
        ]
    }
});

$xml = $query2->getContent();
$href = $tpp->parse( $xml );

is_deeply($href, $test2, "simpleMessage");


