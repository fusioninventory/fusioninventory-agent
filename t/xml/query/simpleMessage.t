#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use FusionInventory::Agent::XML::Query::SimpleMessage;

plan tests => 8;

my $message;
throws_ok {
    $message = FusionInventory::Agent::XML::Query::SimpleMessage->new();
} qr/^No msg/, 'no message';

throws_ok {
    $message = FusionInventory::Agent::XML::Query::SimpleMessage->new({
        msg => 'foo'
    });
} qr/^No DEVICEID/, 'no device id';

lives_ok {
    $message = FusionInventory::Agent::XML::Query::SimpleMessage->new({
        target => { deviceid => 'test' },
        msg => {
            QUERY => 'TEST',
            FOO   => 'foo',
            BAR   => 'bar'
        },
    });
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::XML::Query::SimpleMessage');

is($message->getContent(), <<EOF, 'expected content');
<?xml version="1.0" encoding="UTF-8"?>
<REQUEST>
  <BAR>bar</BAR>
  <DEVICEID>test</DEVICEID>
  <FOO>foo</FOO>
  <QUERY>TEST</QUERY>
</REQUEST>
EOF

lives_ok {
    $message = FusionInventory::Agent::XML::Query::SimpleMessage->new({
        target => { deviceid => 'test' },
        msg => {
            QUERY => 'TEST',
            FOO => 'foo',
            BAR => 'bar',
            CASTOR => [
                {
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
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::XML::Query::SimpleMessage');

is($message->getContent(), <<EOF, 'expected content');
<?xml version="1.0" encoding="UTF-8"?>
<REQUEST>
  <BAR>bar</BAR>
  <CASTOR>
    <FFF>GG</FFF>
    <FOO>fu</FOO>
    <GF>
      <FFFF>GG</FFFF>
    </GF>
  </CASTOR>
  <CASTOR>
    <FddF>
      <GG>O</GG>
    </FddF>
  </CASTOR>
  <DEVICEID>test</DEVICEID>
  <FOO>foo</FOO>
  <QUERY>TEST</QUERY>
</REQUEST>
EOF
