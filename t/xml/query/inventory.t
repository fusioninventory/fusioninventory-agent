#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Config;
use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Logger;

plan tests => 4;

my $message;
throws_ok {
    $message = FusionInventory::Agent::XML::Query::Inventory->new({
        token => 'foo'
    });
} qr/^No DEVICEID/, 'no device id';

lives_ok {
    $message = FusionInventory::Agent::XML::Query::Inventory->new({
        target => {
            deviceid => 'foo',
            vardir   => 'bar',
        },
        logger => FusionInventory::Logger->new()
    });
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::XML::Query::Inventory');

my $content = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<REQUEST>
  <CONTENT>
    <ACCESSLOG></ACCESSLOG>
    <BIOS>
    </BIOS>
    <HARDWARE>
      <ARCHNAME>$Config{archname}</ARCHNAME>
      <CHECKSUM>262143</CHECKSUM>
      <VMSYSTEM>Physical</VMSYSTEM>
    </HARDWARE>
    <NETWORKS>
    </NETWORKS>
    <VERSIONCLIENT></VERSIONCLIENT>
  </CONTENT>
  <DEVICEID>foo</DEVICEID>
  <QUERY>INVENTORY</QUERY>
</REQUEST>
EOF
is($message->getContent(), $content, 'expected content');
