#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More tests => 7;

use_ok( 'FusionInventory::Agent' ); 
use_ok( 'FusionInventory::Agent::Config' ); 
use_ok( 'FusionInventory::Compress' ); 
use_ok( 'FusionInventory::Agent::RPC' ); 
use_ok( 'FusionInventory::Agent::Storage' ); 
use_ok( 'FusionInventory::Agent::AccountInfo' ); 
use_ok( 'FusionInventory::Agent::Task' ); 

