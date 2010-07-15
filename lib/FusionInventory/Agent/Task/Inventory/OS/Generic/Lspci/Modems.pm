package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Modems;

use strict;
use warnings;

use English qw(-no_match_vars);

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $modems = parseLspci('/usr/bin/lspci', '-|');

    return unless $modems;

    foreach my $modem (@$modems) {
        $inventory->addModems($modem);
    }
}

sub parseLspci {
    my ($file, $mode) = @_;

     my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my $modems;

    while (my $line = <$handle>) {
        chomp $line;

        next unless $line =~ /modem/i;
        next unless $line =~ /^\S+ \s ([^:]+): \s (.+)$/x;
        push(@$modems, {
            DESCRIPTION => $1,
            NAME        => $2
        });
    }

    return $modems;
}

1;
