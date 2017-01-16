package FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Memory;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{memory};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $memories = _getMemories(logger => $logger);

    return unless $memories;

    foreach my $memory (@$memories) {
        $inventory->addEntry(
            section => 'MEMORIES',
            entry   => $memory
        );
    }
}

sub _getMemories {
    my $infos = getDmidecodeInfos(@_);

    my ($memories, $slot);

    if ($infos->{17}) {

        foreach my $info (@{$infos->{17}}) {
            $slot++;

            # Flash is 'in general' an unrelated internal BIOS storage
            # See bug: #1334
            next if $info->{'Type'} && $info->{'Type'} =~ /Flash/i;

            my $manufacturer;
            if (
                $info->{'Manufacturer'}
                    &&
                ( $info->{'Manufacturer'} !~ /
                  Manufacturer
                      |
                  Undefined
                      |
                  None
                      |
                  ^0x
                      |
                  00000
                      |
                  \sDIMM
                  /ix )
            ) {
                $manufacturer = $info->{'Manufacturer'};
            }

            my $memory = {
                NUMSLOTS         => $slot,
                DESCRIPTION      => $info->{'Form Factor'},
                CAPTION          => $info->{'Locator'},
                SPEED            => $info->{'Speed'},
                TYPE             => $info->{'Type'},
                SERIALNUMBER     => $info->{'Serial Number'},
                MEMORYCORRECTION => $infos->{16}[0]{'Error Correction Type'},
                MANUFACTURER     => $manufacturer
            };

            if ($info->{'Size'} && $info->{'Size'} =~ /^(\d+ \s .B)$/x) {
                $memory->{CAPACITY} = getCanonicalSize($1, 1024);
            }

            push @$memories, $memory;
        }
    } elsif ($infos->{6}) {

        foreach my $info (@{$infos->{6}}) {
            $slot++;

            my $memory = {
                NUMSLOTS => $slot,
                TYPE     => $info->{'Type'},
            };

            if ($info->{'Installed Size'} && $info->{'Installed Size'} =~ /^(\d+\s*.B)/i) {
                $memory->{CAPACITY} = getCanonicalSize($1, 1024);
            }

            push @$memories, $memory;
        }
    }

    return $memories;
}

1;
