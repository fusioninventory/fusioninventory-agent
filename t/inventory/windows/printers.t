#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More;
use UNIVERSAL::require;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/fake/windows' if $OSNAME ne 'MSWin32';
}
use FusionInventory::Agent::Task::Inventory::Input::Win32::Printers;

my %tests = (
    xppro1 => {
        USB001 => [ '6&397bdcac&0', '49R8Ka' ],
        USB002 => [ '6&2ad9257f&0', '5&19d1ce61&0&2' ],
        USB003 => [ '6&1605722f&0', '5&2377f6ef&0&2' ],
    },
    xppro2 => {
        USB001 => [ '6&1086615&0',  'J5J126789' ],
        USB003 => [ '6&159b6df2&0', 'JV40VNJ' ],
        USB004 => [ '7&20bd29b5&0', '6&28e27c3d&0&0000' ],
    }
);

my $plan = 0;
foreach my $test (keys %tests) {
    $plan += 2 * scalar (keys $tests{$test});
}
plan tests => $plan;

foreach my $test (keys %tests) {
    my $printKey = load_registry("resources/win32/printer/$test/USBPRINT.reg");
    my $usbKey   = load_registry("resources/win32/printer/$test/USB.reg");
    foreach my $port (keys $tests{$test}) {
        my $prefix = FusionInventory::Agent::Task::Inventory::Input::Win32::Printers::_getUSBPrefix($printKey, $port);
        my $serial = FusionInventory::Agent::Task::Inventory::Input::Win32::Printers::_getUSBSerial($usbKey, $prefix);

        is($prefix, $tests{$test}->{$port}->[0], "prefix for printer $port");
        is($serial, $tests{$test}->{$port}->[1], "serial for printer $port");
    }
}

sub load_registry {
    my ($file) = @_;

    my $root_offset;
    my $root_key = {};
    my $current_key;

    open (my $handle, '<:encoding(UTF-16LE)', $file) or die();
    while (my $line = <$handle>) {

        if ($line =~ /^ \[ ([^]]+) \]/x) {
            my $path = $1;
            my @path = split(/\\/, $path);

            if ($root_offset) {
                splice @path, 0, $root_offset;
                $current_key = $root_key;
                foreach my $element (@path) {
                    my $key_path = $element . '/';

                    if (!defined $current_key->{$key_path}) {
                        my $new_key = {};
                        $current_key->{$key_path} = $new_key;
                    }

                    $current_key = $current_key->{$key_path};
                }
            } else {
                $root_offset = scalar @path;
            }
            next;
        }

        if ($line =~ /^ " ([^"]+) " = dword:(\d+)/x) {
            $current_key->{'/' . $1} = "0x$2";
            next;
        }

        if ($line =~ /^ " ([^"]+) " = " ([^"]+) "/x) {
            $current_key->{'/' . $1} = $2;
            next;
        }

    }
    close $handle;

    return $root_key;
}
