package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::Gentoo;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run("equery");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my $command = 'equery list -i 2>/dev/null';

    my $packages = _parseEquery($logger, $command, '-|');

    foreach my $package (@$packages) {
        $inventory->addSoftware($package);
    }
}

sub _parseEquery {
    my ($logger, $file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        my $message = $mode eq '-|' ? 
            "Can't run command $file: $ERRNO" :
            "Can't open file $file: $ERRNO"   ;
        $logger->error($message);
        return;
    }

    my $packages;
    
    while (my $line = <$handle>) {
        chomp $line;
        next unless $line =~ /^([a-z]\w+-\w+\/\w+)-([0-9]+.*)/;
        push @$packages, {
            NAME    => $1,
            VERSION => $2,
        };
    }

    close $handle;

    return $packages;
}

1;
