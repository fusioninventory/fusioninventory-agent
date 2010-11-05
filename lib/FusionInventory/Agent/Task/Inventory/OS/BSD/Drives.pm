package FusionInventory::Agent::Task::Inventory::OS::BSD::Drives;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return can_run("df");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my @drives;


    my %fsList = ( ffs => 1, ufs => 1);

    foreach (`mount`) {
	if (/\ \((\S+?)[,\s\)]/) {
	    my $fs = $1;
	    next if $fs eq 'devfs';
	    next if $fs eq 'procfs';
	    next if $fs eq 'linprocfs';
	    next if $fs eq 'linsysfs';
	    $fsList{$fs} = 1;
	}
    }

    foreach my $fs (keys %fsList) {
        # other BSD flavours don't support this flag, forcing to use 
        # successives calls
        my @ffs_drives = getFilesystemsFromDf(
            logger => $logger,
            command => "df -P -k -t $fs"
        );
        foreach my $drive (@ffs_drives) {
            $drive->{FILESYSTEM} = $fs;

	    $inventory->addDrive($drive);
        }
    }
}

1;
