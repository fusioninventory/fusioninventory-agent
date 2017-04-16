#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;

use FusionInventory::Test::Utils;

plan(skip_all => 'Windows only test') if $OSNAME ne 'MSWin32';

plan tests => 7;

my $settings = FusionInventory::Test::Utils::openWin32Registry();
ok (defined $settings);
my $testValue = time;
$settings->{'TEST_KEY'} = $testValue;

my $settingsRead = FusionInventory::Test::Utils::openWin32Registry();
ok (defined $settingsRead);
ok (defined $settingsRead->{'TEST_KEY'});
ok ($settingsRead->{'TEST_KEY'} eq $testValue);

# reset conf in registry
my $deleted;
if (defined $settings && defined $settings->{'TEST_KEY'}) {
    $deleted = delete $settings->{'TEST_KEY'};
}
ok (!(defined($settings->{'TEST_KEY'})));

$settingsRead = undef;
$settingsRead = FusionInventory::Test::Utils::openWin32Registry();
ok (defined $settingsRead);
ok (!(defined $settingsRead->{'TEST_KEY'}));
