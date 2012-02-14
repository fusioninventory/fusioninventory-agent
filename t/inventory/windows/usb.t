#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use English qw(-no_match_vars);
use Test::More;
use Test::MockModule;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Input::Win32::USB;

my %tests = (
    7 => [
        {
            NAME      => 'Périphérique audio USB',
            SERIAL    => 'MI_02\\7',
            VENDORID  => '046D',
            PRODUCTID => '08C9'
        },
        {
            NAME      => 'Périphérique d’entrée USB',
            SERIAL    => 'MI_01\\7',
            VENDORID  => '046D',
            PRODUCTID => 'C30A'
        },
        {
            NAME      => 'Generic USB Hub',
            SERIAL    => '1C9B8E1E',
            VENDORID  => '8087',
            PRODUCTID => '0024'
        },
        {
            NAME      => 'Generic USB Hub',
            SERIAL    => '355C47BA',
            VENDORID  => '8087',
            PRODUCTID => '0024'
        },
        {
            NAME      => 'ASUS Bluetooth',
            SERIAL    => 'DF2EE03',
            VENDORID  => '0B05',
            PRODUCTID => '179C'
        },
        {
            NAME      => 'Périphérique USB composite',
            SERIAL    => '\\6BE882AB',
            VENDORID  => '046D',
            PRODUCTID => '08C9'
        },
        {
            NAME      => 'Périphérique vidéo USB',
            SERIAL    => 'MI_00\\7',
            VENDORID  => '046D',
            PRODUCTID => '08C9'
        }
    ]
);

plan tests => scalar keys %tests;

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Input::Win32::USB'
);

foreach my $test (keys %tests) {
    # redefine getWmiObjects function
    $module->mock(
        'getWmiObjects',
        sub {
            my (%params) = @_;

            my $file = "resources/win32/wmi/$test-$params{class}";
            open (my $handle, '<', $file) or die "can't open $file: $ERRNO";

            # this is a windows file
            binmode $handle, ':encoding(UTF-16LE)';
            binmode $handle, ':crlf';

            # build a list of desired properties indexes
            my %properties = map { $_ => 1 } @{$params{properties}};

            my @objects;
            my $object;
            while (my $line = <$handle>) {
                if ($line =~ /^ (\w+) = (.+) $/x) {
                    my $key = $1;
                    my $value = $2;
                    next unless $properties{$key};
                    $value =~ s/&amp;/&/g;
                    $object->{$key} = $value;
                    next;
                }
                if ($line =~ /^$/) {
                    push @objects, $object if $object;
                    undef $object;
                    next;
                }
            }
            close $handle;

            return @objects;
        }
    );

    my @devices = FusionInventory::Agent::Task::Inventory::Input::Win32::USB::_getUSBDevices();
    is_deeply(
        \@devices,
        $tests{$test},
        "$test USB devices list"
    );
}
