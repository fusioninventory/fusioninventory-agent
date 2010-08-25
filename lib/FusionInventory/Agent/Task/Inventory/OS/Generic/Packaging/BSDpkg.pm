package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::BSDpkg;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run("pkg_info");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my $command = 'pkg_info';

    my $packages = _parsePkgInfo($logger, $command, '-|');

    foreach my $package (@$packages) {
        $inventory->addSoftware($package);
    }
}

sub _parsePkgInfo {
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
        next unless $line =~ /^(\S+)-(\d+\S*)\s+(.*)/;
        push @$packages, {
            NAME    => $1,
            VERSION => $2,
            VERSION => $3
        };
    }

    close $handle;

    return $packages;
}

1;
