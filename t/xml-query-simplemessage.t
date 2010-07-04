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
use XML::TreePP; 
plan tests => 1;
my $test =  {
    'REQUEST' => {
        'QUERY' => 'TEST',
        'BAR' => 'bar',
        'FOO' => 'foo',
        'DEVICEID' => 'test-deviceid'
    }
}; 

#plan tests => scalar keys %tests;
my $logger = Logger->new ();
my $target = {deviceid => 'test-deviceid'}; 
my $query = FusionInventory::Agent::XML::Query::SimpleMessage->new({
    target => $target,
    msg => {
        QUERY => 'TEST',
        FOO => 'foo',
        BAR => 'bar', 
    }
});

my $xml = $query->getContent();
my $tpp =  XML::TreePP->new();
my $href = $tpp->parse( $xml );

is_deeply($href, $test, "simpleMessage");
