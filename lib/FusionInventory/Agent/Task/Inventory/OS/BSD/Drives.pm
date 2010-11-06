package FusionInventory::Agent::Task::Inventory::OS::BSD::Drives;

use strict;
use warnings;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $free;
    my $filesystem;
    my $total;
    my $type;
    my $volumn;

    my %fsList = ( ffs => 1, ufs => 1);

    foreach (`mount`) {
	if (/\ \((\S+?)[,\s\)]/) {
	    my $fs = $1;
	    next if $fs eq 'devfs';
	    next if $fs eq 'procfs';
	    next if $fs eq 'linprocfs';
	    next if $fs eq 'linsysfs';
	    next if $fs eq 'tmpfs';
	    next if $fs eq 'fdescfs';

	    $fsList{$fs} = 1;
	}
    }

    for my $t (keys %fsList) {
# OpenBSD has no -m option so use -k to obtain results in kilobytes
        for(`df -P -t $t -k 2>&1`){
            if(/^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\n/){
                $volumn = $1;
                $filesystem = $t;
                $total = sprintf("%i",$2/1024);
                $free = sprintf("%i",$4/1024);
                $type = $6;

                $inventory->addDrive({
                    FREE => $free,
                    FILESYSTEM => $filesystem,
                    TOTAL => $total,
                    TYPE => $type,
                    VOLUMN => $volumn
                })
            }
        }
    }
}
1;
