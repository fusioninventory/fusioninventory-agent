#!/usr/bin/perl
package Logger;

sub new {
    my $self = {};
    bless $self;
}
sub debug {}
1;
use strict;
use warnings;

use Test::More;
use FindBin;
use FusionInventory::Agent::XML::Query::SimpleMessage;

if (!eval "use XML::TreePP;1") {
    eval "use Test::More skip_all => 'Missing XML::TreePP';";
    exit 0
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
my $logger = Logger->new ();
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


