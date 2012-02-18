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
            NAME      => 'Generic USB Hub',
            VENDORID  => '8087',
            PRODUCTID => '0024'
        },
        {
            NAME      => 'Generic USB Hub',
            VENDORID  => '8087',
            PRODUCTID => '0024'
        },
        {
            NAME      => 'ASUS Bluetooth',
            VENDORID  => '0B05',
            PRODUCTID => '179C'
        },
        {
            NAME      => 'Périphérique USB composite',
            SERIAL    => '6BE882AB',
            VENDORID  => '046D',
            PRODUCTID => '08C9'
        },
        {
            NAME      => 'Périphérique d’entrée USB',
            VENDORID  => '046D',
            PRODUCTID => 'C03E'
        },
        {
            NAME      => 'Périphérique USB composite',
            VENDORID  => '046D',
            PRODUCTID => 'C30A'
        },
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

            my $file = "resources/win32/wmi/$test-$params{class}.wmi";
            open (my $handle, '<', $file) or die "can't open $file: $ERRNO";

            # this is a windows file
            #binmode $handle, ':crlf';
            binmode $handle, ':encoding(UTF-16LE)';
            local $INPUT_RECORD_SEPARATOR="\r\n";

            # build a list of desired properties indexes
            my %properties = map { $_ => 1 } @{$params{properties}};

            my @objects;
            my $object;
            while (my $line = <$handle>) {
                chomp $line;
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
