#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use FusionInventory::Agent::XML::Query::SimpleMessage;

plan tests => 5;

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
        target => { deviceid => 'foo' },
        msg => {
            QUERY => 'PING',
            ID    => 'foo'
        },
    });
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::XML::Query::SimpleMessage');

my $content = <<'EOF';
<?xml version="1.0" encoding="UTF-8"?>
<REQUEST>
  <DEVICEID>foo</DEVICEID>
  <ID>foo</ID>
  <QUERY>PING</QUERY>
</REQUEST>
EOF
is($message->getContent(), $content, 'expected content');
