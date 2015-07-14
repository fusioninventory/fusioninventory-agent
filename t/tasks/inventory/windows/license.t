#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';
use utf8;

use English qw(-no_match_vars);
use Test::More;
use Test::NoWarnings;

use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/lib/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Win32::License;

my %tests = (
    office_2010_1 => {
       NAME       => 'Microsoft Office',
       FULLNAME   => 'Microsoft Office Professional 2010',
       PRODUCTID  => '82503-242-8447354-11013',
       KEY        => 'WMB2Y-C82XF-CY7MJ-TVXGD-DVXGV',
       OEM        => 1,
       UPDATE     => 'SP2',
       TRIAL      => '0',
       COMPONENTS => 'Access/AccessRuntime/Excel/ExcelConsumer/Groove/InfoPath/OneNote/Outlook/OutlookStandard/PowerPoint/Project/Publisher/SharePointDesigner/Visio/VisioSDK/Word/WordConsumer'
    },
    office_2010_2 => {
       NAME       => 'Microsoft Office',
       FULLNAME   => 'Microsoft Office 2010 dla Użytkowników Domowych i Małych Firm',
       PRODUCTID  => '82503-OEM-1170032-70636',
       KEY        => 'WMB2Y-C82XF-CY7MJ-TV2CB-7MBC7',
       OEM        => 1,
       UPDATE     => 'SP2',
       TRIAL      => '0',
       COMPONENTS => 'Access/AccessRuntime/Excel/ExcelConsumer/Groove/InfoPath/OneNote/Outlook/OutlookStandard/PowerPoint/Project/Publisher/SharePointDesigner/Visio/VisioSDK/Word/WordConsumer'
    },
);

plan tests => scalar (keys %tests) + 1;

foreach my $test (keys %tests) {
    my $key = loadRegistryDump("resources/win32/registry/$test.reg");
    my $license =
        FusionInventory::Agent::Task::Inventory::Win32::License::_getOfficeLicense($key);

    is_deeply(
        $license,
        $tests{$test},
        "$test sample"
    );
}
