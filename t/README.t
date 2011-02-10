#!/usr/bin/perl -w

use strict;

use Test::More;

if (!$ENV{TEST_AUTHOR}) {
    my $msg = 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan(skip_all => $msg);
}

ok(-f 'README', 'README does not exist, run ./tools/refresh-doc.sh');
ok(-f 'README.html', 'README.html does not exist, run ./tools/refresh-doc.sh');
done_testing();
