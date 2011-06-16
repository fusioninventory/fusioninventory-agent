package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::Gentoo;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    return can_run("equery");
}

sub _equeryNeedsWildcard {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "can't open $file: $ERRNO";
        return;
    }
    chomp(my $line = <$handle>);
    if ($line =~ /^equery \(([\d\.]+)\)/) {
        my @v = split(/\./, $1);
        return 1 if $v[0] > 0;
        return if $v[1] < 3;
        return 1;
    }

    return;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $cmd = "equery list -i";
    if (_equeryNeedsWildcard('equery -V', '-|')) {
        $cmd .= " '*'";
    }
# TODO: This had been rewrite from the Linux agent _WITHOUT_ being checked!
    foreach (`$cmd`){
        if (/^(.*)-([0-9]+.*)/) {
            $inventory->addSoftware({
                'NAME'          => $1,
                'VERSION'       => $2,
            });
        }
    }
}

1;
