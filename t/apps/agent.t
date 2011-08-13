#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Temp;
use IPC::Run qw(run);
use XML::TreePP;

use FusionInventory::Agent::Tools;

use Test::More tests => 32;

my ($out, $err, $rc);

($out, $err, $rc) = run_agent('--help');
ok($rc == 2, '--help exit status');
like(
    $err,
    qr/^Usage:/,
    '--help stderr'
);
is($out, '', '--help stdin');

($out, $err, $rc) = run_agent('--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/^FusionInventory unified agent for UNIX, Linux and MacOSX/,
    '--version stdin'
);


($out, $err, $rc) = run_agent();
ok($rc == 1, 'no target exit status');
like(
    $err,
    qr/No target defined/,
    'no target stderr'
);
is($out, '', 'no target stdin');

my $content;
# first inventory
($out, $err, $rc) = run_agent(
    "--stdout --no-ocsdeploy --no-wakeonlan --no-snmpquery --no-netdiscovery --no-printer"
);
ok($rc == 0, 'exit status');

like(
    $out,
    qr/^<\?xml version="1.0" encoding="UTF-8" \?>/,
    'output has correct encoding'
);

$content = XML::TreePP->new()->parse($out);
ok($content, 'output is valid XML');

ok(
    exists $content->{REQUEST}->{CONTENT}->{SOFTWARES},
    'inventory has software'
);

ok(
    exists $content->{REQUEST}->{CONTENT}->{ENVS},
    'inventory has environment variables'
);

# second inventory, without software
($out, $err, $rc) = run_agent(
    "--stdout --no-ocsdeploy --no-wakeonlan --no-snmpquery --no-netdiscovery --no-printer --no-software"
);
ok($rc == 0, 'exit status');

like(
    $out,
    qr/^<\?xml version="1.0" encoding="UTF-8" \?>/,
    'output has correct encoding'
);

$content = XML::TreePP->new()->parse($out);
ok($content, 'output is valid XML');

ok(
    !exists $content->{REQUEST}->{CONTENT}->{SOFTWARES},
    "output doesn't have any software"
);

ok(
    exists $content->{REQUEST}->{CONTENT}->{ENVS},
    'inventory has environment variables'
);

# third inventory, without software, but additional content

my $file = File::Temp->new(UNLINK => $ENV{TEST_DEBUG} ? 0 : 1, SUFFIX => '.xml');
print $file <<EOF;
<?xml version="1.0" encoding="UTF-8" ?>
<REQUEST>
  <CONTENT>
      <SOFTWARES>
          <NAME>foo</NAME>
          <VERSION>bar</VERSION>
      </SOFTWARES>
  </CONTENT>
</REQUEST>
EOF
close($file);
($out, $err, $rc) = run_agent(
    "--stdout --no-ocsdeploy --no-wakeonlan --no-snmpquery --no-netdiscovery --no-printer --no-software --additional-content $file"
);
ok($rc == 0, 'exit status');

like(
    $out,
    qr/^<\?xml version="1.0" encoding="UTF-8" \?>/,
    'output has correct encoding'
);

$content = XML::TreePP->new()->parse($out);
ok($content, 'output is valid XML');

ok(
    exists $content->{REQUEST}->{CONTENT}->{SOFTWARES},
    'inventory has softwares'
);

ok(
    ref $content->{REQUEST}->{CONTENT}->{SOFTWARES} eq 'HASH',
    'software list has only one element'
);

ok(
    $content->{REQUEST}->{CONTENT}->{SOFTWARES}->{NAME} eq 'foo' &&
    $content->{REQUEST}->{CONTENT}->{SOFTWARES}->{VERSION} eq 'bar',
    'expected software'
);

ok(
    exists $content->{REQUEST}->{CONTENT}->{ENVS},
    'inventory has environment variables'
);

# create inventory targets
$ENV{FOO} = 'bar';

($out, $err, $rc) = run_agent(
    "--stdout --no-ocsdeploy --no-wakeonlan --no-snmpquery --no-netdiscovery --no-printer --no-software"
);
ok($rc == 0, 'exit status');

like(
    $out,
    qr/^<\?xml version="1.0" encoding="UTF-8" \?>/,
    'output has correct encoding'
);

$content = XML::TreePP->new()->parse($out);
ok($content, 'output is valid XML');

ok(
    !exists $content->{REQUEST}->{CONTENT}->{SOFTWARES},
    "output doesn't have any software"
);

ok(
    exists $content->{REQUEST}->{CONTENT}->{ENVS},
    'inventory has environment variables'
);

SKIP: {
skip '$ENV not set by IPC::Run on Windows', 1 if $OSNAME eq 'MSWin32';
ok(
    (any
        { $_->{KEY} eq 'FOO' && $_->{VAL} eq 'bar' } 
        @{$content->{REQUEST}->{CONTENT}->{ENVS}}
    ),
    'expected environment variable'
);
}

sub run_agent {
    my ($args) = @_;
    my @args = $args ? split(/\s+/, $args) : ();
    run(
        [ $EXECUTABLE_NAME, 'fusioninventory-agent', @args ],
        \my ($in, $out, $err)
    );
    return ($out, $err, $CHILD_ERROR >> 8);
}
