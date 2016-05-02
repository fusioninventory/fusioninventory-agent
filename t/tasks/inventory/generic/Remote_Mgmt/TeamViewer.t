#!/usr/bin/perl

use strict;
use warnings;
use lib 'lib';

use Test::More;

use FusionInventory::Agent::Task::Inventory::Generic::Remote_Mgmt::TeamViewer;

plan tests => 2;

SKIP: {
    skip "Only if command 'teamviewer' is available", 2 unless FusionInventory::Agent::Task::Inventory::Generic::Remote_Mgmt::TeamViewer::isEnabled();
    my $command = "teamviewer --info";
    my $teamViewerID = FusionInventory::Agent::Task::Inventory::Generic::Remote_Mgmt::TeamViewer::_getID(command => $command);
    ok (defined($teamViewerID));
    ok (length($teamViewerID) > 0);
}
