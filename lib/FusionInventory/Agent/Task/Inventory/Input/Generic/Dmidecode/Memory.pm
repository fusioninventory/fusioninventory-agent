package FusionInventory::Agent::Task::Inventory::Input::Generic::Dmidecode::Memory;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $memory (_getMemories(logger => $logger)) {
        $inventory->addEntry(
            section => 'MEMORIES',
            entry   => $memory
        );
    }
}

sub _getMemories {
    my $parser = getDMIDecodeParser(@_);

    my (@memories, $slot);

    my $memoryCorrection;
    my @handles = $parser->get_handles(dmitype => 16);
    if (@handles) {
        $memoryCorrection =
            $handles[0]->keyword('memory-error-correction-type');
    }

    # start with memory devices
    foreach my $handle ($parser->get_handles(dmitype => 17)) {
        my $type = $handle->keyword('memory-type');
        next unless $type;

        $slot++;

        # Flash is 'in general' an unrelated internal BIOS storage
        # See bug #1334
        next if $type =~ /Flash/i;

        my $description = $handle->keyword('memory-form-factor');
        $description .= " ($memoryCorrection)" if $memoryCorrection;

        my $memory = {
            NUMSLOTS         => $slot,
            DESCRIPTION      => $description,
            CAPTION          => getSanitizedValue($handle, 'memory-locator'),
            SPEED            => getSanitizedValue($handle, 'memory-speed'),
            TYPE             => getSanitizedValue($handle, 'memory-type'),
            SERIALNUMBER     => getSanitizedValue(
                                    $handle, 'memory-serial-number'
                                ),
            MEMORYCORRECTION => $memoryCorrection
        };

        my $size = $handle->keyword('memory-size');
        if ($size && $size =~ /^(\d+) \s MB$/x) {
            $memory->{CAPACITY} = $1;
        }

        push @memories, $memory;
    }

    return @memories if @memories;

    # fallback on memory modules
    foreach my $handle ($parser->get_handles(dmitype => 6)) {
        $slot++;

        my $memory = {
            NUMSLOTS => $slot,
            TYPE     => $handle->keyword('memory-type'),
        };

        my $size = $handle->keyword('memory-installed-size');
        if ($size && $size =~ /^(\d+)\s*(MB|Mbyte)/x) {
            $memory->{CAPACITY} = $1;
        }

        push @memories, $memory;
    }

    return @memories;
}

1;
