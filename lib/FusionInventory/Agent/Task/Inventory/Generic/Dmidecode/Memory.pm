package FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Memory;

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

    my $memoryCorrection;
    if ($infos->{16}) {
        $memoryCorrection = $infos->{16}[0]{'Error Correction Type'};
    }
    if ($infos->{17}) {

        foreach my $info (@{$infos->{17}}) {
            $slot++;

            # Flash is 'in general' an unrelated internal BIOS storage, See bug: #1334
            next if $info->{'Type'} =~ /Flash/i;

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


            my $description = $info->{'Form Factor'};
            $description .= " ($memoryCorrection)" if $memoryCorrection;

            my $memory = {
                NUMSLOTS     => $slot,
                DESCRIPTION  => $description,
                CAPTION      => $info->{'Locator'},
                SPEED        => $info->{'Speed'},
                TYPE         => $info->{'Type'},
                SERIALNUMBER => $info->{'Serial Number'},
                MEMORYCORRECTION => $memoryCorrection,
                MANUFACTURER => $manufacturer
            };

            if ($info->{'Size'} && $info->{'Size'} =~ /^(\d+) \s MB$/x) {
                $memory->{CAPACITY} = $1;
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

            if ($info->{'Installed Size'} && $info->{'Installed Size'} =~ /^(\d+)\s*(MB|Mbyte)/x) {
                $memory->{CAPACITY} = $1;
            }

            push @$memories, $memory;
        }
    }

    return $memories;
}

1;
