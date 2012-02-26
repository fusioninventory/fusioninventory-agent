#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Input::Win32::Printers;

my %tests = (
    xppro1 => {
        USB001 => [ '6&397bdcac&0', '49R8Ka' ],
        USB002 => [ '6&2ad9257f&0', undef ],
        USB003 => [ '6&1605722f&0', undef ],
    },
    xppro2 => {
        USB001 => [ '6&1086615&0',  'J5J126789' ],
        USB003 => [ '6&159b6df2&0', 'JV40VNJ' ],
        USB004 => [ '7&20bd29b5&0', undef ],
    },
    7 => {
        USB001 => [ '7&17e8a3c3&0',  'MY26K1K34C2L' ],
    }
);

my $plan = 0;
foreach my $test (keys %tests) {
    $plan += 2 * scalar (keys %{$tests{$test}});
}
plan tests => $plan;

foreach my $test (keys %tests) {
    my $printKey = load_registry("resources/win32/registry/$test-USBPRINT.reg");
    my $usbKey   = load_registry("resources/win32/registry/$test-USB.reg");
    foreach my $port (keys %{$tests{$test}}) {
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

    open (my $handle, '<', $file) or die "can't open $file: $ERRNO";

    # this is a windows file
    binmode $handle, ':encoding(UTF-16LE)';
    local $INPUT_RECORD_SEPARATOR="\r\n";

    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /^ \[ ([^]]+) \] $/x) {
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
