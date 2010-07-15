package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Slots;

use strict;
use warnings;

use English qw(-no_match_vars);

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $slots = parseDmidecode('/usr/sbin/dmidecode', '-|');

    return unless $slots;

    foreach my $slot (@$slots) {
        $inventory->addSlots($slot);
    }
}

sub parseDmidecode {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my ($slots, $slot, $type);

    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /DMI type (\d+)/) {
            $type = $1;
            if ($slot) {
                push @$slots, $slot;
                undef $slot;
            }
            next;
        }

        next unless defined $type;

        if ($type == 9) {
             if ($line =~ /^\s+Type: (.*\S)/) {
                $slot->{DESCRIPTION} = $1;
            } elsif ($line =~ /^\s+ID: (.*\S)/) {
                $slot->{DESIGNATION} = $1;
            } elsif ($line =~ /^\s+Designation: (.*\S)/) {
                $slot->{NAME} = $1;
            } elsif ($line =~ /^\s+Current Usage: (.*\S)/) {
                $slot->{STATUS} = $1;
            }
        }
    }
    close $handle;

    return $slots;
}

1;
