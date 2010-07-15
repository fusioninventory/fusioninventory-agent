package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Memory;

use strict;
use warnings;

use English qw(-no_match_vars);

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $memories = parseDmidecode('dmidecode', '-|');

    return unless $memories;

    foreach my $memory (@$memories) {
        $inventory->addMemory($memory);
    }
}

sub parseDmidecode {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my ($memories, $memory, $type);
    my $slot = 0;

    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /DMI type (\d+)/) {
            $type = $1;
            if ($memory) {
                $memory->{NUMSLOTS} = ++$slot;
                push @$memories, $memory;
                undef $memory;
            }
            next;
        }

        next unless defined $type;

        if ($type == 17) {
            if ($line =~ /^\s+Size: (\d+)\s+MB$/) {
                $memory->{CAPACITY} = $1;
            } elsif ($line =~ /^\s+Form Factor: (.*\S)/) {
                $memory->{DESCRIPTION} = $1;
            } elsif ($line =~ /^\s+Locator: (.*\S)/) {
                $memory->{CAPTION} = $1;
            } elsif ($line =~ /^\s+Speed: (.*\S)/) {
                $memory->{SPEED} = $1;
            } elsif ($line =~ /^\s+Type: (.*\S)/) {
                $memory->{TYPE} = $1;
            } elsif ($line =~ /^\s+Serial Number: (.*\S)/) {
                $memory->{SERIALNUMBER} = $1;
            }
        }

    }
    close $handle;

    return $memories;
}

1;
