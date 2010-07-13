package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Slots;

use strict;
use warnings;

use English qw(-no_match_vars);

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my ($slots) = parseDmidecode('/usr/sbin/dmidecode', '-|');

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

        if ($line =~ /DMI type (\d+)/i) {
            $type = $1;
            if ($slot) {
                push @$slots, $slot;
                undef $slot;
            }
            next;
        }

        next unless defined $type;

        if ($type == 9) {
             if ($line =~ /^\s+Type:\s*(.+)/i) {
                $slot->{DESCRIPTION} = $1;
            } elsif ($line =~ /^\s+ID:\s*(.+)/i) {
                $slot->{DESIGNATION} = $1;
            } elsif ($line =~ /^\s+Designation:\s*(.+)/i) {
                $slot->{NAME} = $1;
            } elsif ($line =~ /^\s+Current Usage:\s*(.+)/i) {
                $slot->{STATUS} = $1;
            }
        }
    }
    close $handle;
}

1;
