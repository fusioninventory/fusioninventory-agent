#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Linux::Video;
use Test::More;
use FindBin;


my %ddcprobe = (
	'98LMTF053166' => {

	'eisa' => 'ACI22ab',
	'input' => 'sync on green, analog signal.',
	'mode' => '640x480x64k',
	'monitorserial' => '98LMTF053166',
	'edid' => '1 3',
	'monitorrange' => '30-85, 55-75',
	'id' => '22ab',
	'dtiming' => '1920x1080@67',
	'serial' => '0000cfae',
	'oem' => 'Intel(r) 82945GM Chipset Family Graphics Chip Accelerated VGA BIOS',
	'ctiming' => '1920x1200@60',
	'gamma' => '2.200000',
	'memory' => '7872kb',
	'timing' => '1280x1024@75 (VESA)',
	'monitorname' => 'ASUS VH222',
	'screensize' => '47 26',
	'manufacture' => '32 2009',
	'dpms' => 'RGB, active off, no suspend, no standby',
	'product' => 'Intel(r) 82945GM Chipset Family Graphics Controller Hardware Version 0.0',
	'vendor' => 'Intel Corporation',
	'vbe' => 'VESA 3.0 detected.'
	},

	'B101AW03' => {
	    'eisa' => 'AUO30d2',
	    'input' => 'analog signal.',
	    'mode' => '640x480x64k',
	    'edid' => '1 3',
	    'id' => '30d2',
	    'dtiming' => '1024x600@74',
	    'serial' => '00000000',
	    'oem' => 'Intel(r) 82945GM Chipset Family Graphics Chip Accelerated VGA BIOS',
	    'gamma' => '2.200000',
	    'memory' => '7872kb',
	    'monitorid' => 'B101AW03 V0',
	    'screensize' => '22 13',
	    'manufacture' => '1 2008',
	    'dpms' => 'RGB, no active off, no suspend, no standby',
	    'product' => 'Intel(r) 82945GM Chipset Family Graphics Controller Hardware Version 0.0',
	    'vendor' => 'Intel Corporation',
	    'vbe' => 'VESA 3.0 detected.'
	},

	'HT009154WU2' => {
	    'eisa' => 'LGD018f',
	    'input' => 'analog signal.',
	    'mode' => '640x480x64k',
	    'edid' => '1 3',
	    'id' => '018f',
	    'dtiming' => '1920x1200@54',
	    'serial' => '00000000',
	    'oem' => 'Intel(r)Cantiga Graphics Chip Accelerated VGA BIOS',
	    'gamma' => '2.200000',
	    'memory' => '32704kb',
	    'monitorid' => 'HT009154WU2',
	    'screensize' => '33 21',
	    'manufacture' => '0 2008',
	    'dpms' => 'RGB, no active off, no suspend, no standby',
	    'product' => 'Intel(r)Cantiga Graphics Controller Hardware Version 0.0',
	    'vendor' => 'Intel Corporation',
	    'vbe' => 'VESA 3.0 detected.'
	}

);


my %xorg = (
	'intel-1' => {
	'resolution' => '1024x600',
	'name' => 'Intel(R) 945GME'
	},
	'intel-2' => {
	'resolution' => '1024x600',
	'name' => 'Intel(R) 945GME'
	}

	);
plan tests => scalar keys (%ddcprobe) + scalar keys (%xorg);

foreach my $test (keys %ddcprobe) {
    my $file = "$FindBin::Bin/../resources/ddcprobe/$test";
    my $ret = FusionInventory::Agent::Task::Inventory::OS::Linux::Video::_getDdcprobeData($file, '<');
    is_deeply($ret, $ddcprobe{$test}, $test);
}

foreach my $test (keys %xorg) {
    my $file = "$FindBin::Bin/../resources/xorg-fd0/$test";
    my $ret = FusionInventory::Agent::Task::Inventory::OS::Linux::Video::_parseXorgFd($file);
    is_deeply($ret, $xorg{$test}, $test);
}
