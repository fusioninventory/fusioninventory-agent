#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::Exception;
use Test::More;

use FusionInventory::Agent::Message::Inbound;

plan tests => 4;

my $message;
throws_ok {
    $message = FusionInventory::Agent::Message::Inbound->new();
} qr/^no content/, 'no content parameter';

throws_ok {
    $message = FusionInventory::Agent::Message::Inbound->new(
        content => 'foo'
    );
} qr/^content is not an XML message/, 'wrong syntax';

throws_ok {
    $message = FusionInventory::Agent::Message::Inbound->new(
        content => '<foo></foo>'
    );
} qr/^content is an invalid XML message/, 'wrong content';

lives_ok {
    $message = FusionInventory::Agent::Message::Inbound->new(
        content => '<REPLY></REPLY>'
    );
} 'everything OK';
