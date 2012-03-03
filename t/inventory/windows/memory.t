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

use FusionInventory::Agent::Task::Inventory::Input::Win32::Memory;

my %tests = (
    7 => [
        {
            NUMSLOTS     => 0,
            FORMFACTOR   => 'DIMM',
            SERIALNUMBER => '0000000',
            TYPE         => 'Unknown',
            SPEED        => '1600',
            CAPTION      => "Mémoire physique",
            REMOVABLE    => 0,
            DESCRIPTION  => "Mémoire physique",
            CAPACITY     => '2048'
        },
        {
            NUMSLOTS     => 1,
            FORMFACTOR   => 'DIMM',
            SERIALNUMBER => '0000000',
            TYPE         => 'Unknown',
            SPEED        => '1600',
            CAPTION      => "Mémoire physique",
            REMOVABLE    => 0,
            DESCRIPTION  => "Mémoire physique",
            CAPACITY     => '2048'
        }
    ]
);

plan tests => scalar keys %tests;

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Input::Win32::Memory'
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

    my @memories = FusionInventory::Agent::Task::Inventory::Input::Win32::Memory::_getMemories();
    is_deeply(
        \@memories,
        $tests{$test},
        "$test memory"
    );
}
