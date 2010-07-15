#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use FusionInventory::Agent::XML::Query::Prolog;

plan tests => 5;

my $message;
throws_ok {
    $message = FusionInventory::Agent::XML::Query::Prolog->new({
    });
} qr/^No token/, 'no token';

throws_ok {
    $message = FusionInventory::Agent::XML::Query::Prolog->new({
        token => 'foo'
    });
} qr/^No DEVICEID/, 'no device id';

lives_ok {
    $message = FusionInventory::Agent::XML::Query::Prolog->new({
        target => { deviceid => 'foo' },
        token => 'foo',
    });
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::XML::Query::Prolog');

my $content = <<'EOF';
<?xml version="1.0" encoding="UTF-8"?>
<REQUEST>
  <DEVICEID>foo</DEVICEID>
  <QUERY>PROLOG</QUERY>
  <TOKEN>foo</TOKEN>
</REQUEST>
EOF
is($message->getContent(), $content, 'expected content');
