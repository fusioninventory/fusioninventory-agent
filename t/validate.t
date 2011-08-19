#!/usr/bin/perl -w


use strict;
use warnings;

use FusionInventory::Agent::Task::Deploy;
use JSON;


use Test::More tests => 6;
use Data::Dumper;

my @tests = (
        {
            json => '{"jobs":[[],{"checks":[{"path":"\/etc\/fstab","type":"filePresent","return":"error"}],"associatedFiles":{"6b620ce663ba13061b480e9897bfa0ef98d039a7747c8286b37a967fb505b12e6e83f10bd0ac1b89a78d4c713a3251fb77ccf0a5cfc890cba43a3627e26ff9b3":{"uncompress":1,"name":"fusioninventory-for-glpi.tar.gz","is_p2p":0,"multiparts":[{"fusioninventory-for-glpi.tar.gz":"04c1ba7f890df17966725eb600fca1a28fb7bdc7573a30869ac2cc78796f6b72ee522276509e7e9350ef2fc9685df0cfc90b5e3546bb0437e661ccec7da97a49"}],"p2p-retention-duration":0}},"actions":{"move":[{"*":"\/tmp\/input"}]}}]}',
            ret => undef,
            msg => "missing associatedFiles key",
        },
        {
            json => '[]',
            ret => undef,
            msg => "Bad answer from server. Not a hash reference.",
        },
        {
            json => '',
            ret => undef,
            msg => "No answer from server.",
        },
        {
            json => '{"jobs":[{"uuid":"4e4e3bfd87e3b"},{"check":[{"path":"\/etc\/fstab","type":"filePresent","return":"error"}],"associatedFiles":["6b620ce663ba13061b480e9897bfa0ef98d039a7747c8286b37a967fb505b12e6e83f10bd0ac1b89a78d4c713a3251fb77ccf0a5cfc890cba43a3627e26ff9b3"],"actions":{"move":[{"*":"\/tmp\/input"}]},"uuid":"4e4e3bfd90cc5"}],"associatedFiles":{"6b620ce663ba13061b480e9897bfa0ef98d039a7747c8286b37a967fb505b12e6e83f10bd0ac1b89a78d4c713a3251fb77ccf0a5cfc890cba43a3627e26ff9b3":{"uncompress":1,"name":"fusioninventory-for-glpi.tar.gz","is_p2p":0,"multiparts":[{"fusioninventory-for-glpi.tar.gz":"04c1ba7f890df17966725eb600fca1a28fb7bdc7573a30869ac2cc78796f6b72ee522276509e7e9350ef2fc9685df0cfc90b5e3546bb0437e661ccec7da97a49"},{"fusioninventory-for-glpi.tar.gz":"04c1ba7f890df17966725eb600fca1a28fb7bdc7573a30869ac2cc78796f6b72ee522276509e7e9350ef2fc9685df0cfc90b5e3546bb0437e661ccec7da97a49"}],"p2p-retention-duration":0}}}',
            ret => undef,
            msg => "Missing key `mirrors' in associatedFiles"
       },
        {
            json => '{"jobs":[{"checks":[{"path":"\/etc\/fstab","type":"filePresent","return":"error"}],"associatedFiles":[],"actions":{"move":[{"*":"\/tmp\/input"}]},"uuid":"4e4e3bfd90cc5"}],"associatedFiles":{}}',
            ret => 1,
            msg => ""
       },
        {
            json => '{"jobs":[{"checks":[{"path":"\/etc\/fstab","type":"filePresent","return":"error"}],"associatedFiles":[],"actions":{"move":[{"*":"\/tmp\/input"}]}}],"associatedFiles":{}}',
            ret => undef,
            msg => "Missing key `uuid' in jobs"
       }
);

foreach (@tests) {
    my $msg;
    my $ret = FusionInventory::Agent::Task::Deploy::_validateAnswer(\$msg, eval {decode_json($_->{json})});
    ok(($ret?0:1) == ($_->{ret}?0:1), "returned code");
    ok($msg eq $_->{msg}, "returned msg") or print "'".$msg."`\n";
}

