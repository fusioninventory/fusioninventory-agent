package FusionInventory::Agent::Task::Inventory::OS::BSD::Drives;

use strict;
use warnings;

sub getVfsFromLsvfs {
    my ($handle) = @_;

    my %vfs;
    my $in;
    while (<$handle>) {
	if (/^---/) {
	    $in = 1;
	} elsif ($in && /^(\S+)/) {
	    $vfs{$1} = 1;
	}
    }

    return %vfs;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $free;
    my $filesystem;
    my $total;
    my $type;
    my $volumn;

    my %vfs;
    if (open my $handle, '-|', 'lsvfs') {
	%vfs = getVfsFromLsvfs($handle);
	close $handle;
    }

# Just in case lsvfs fails
    $vfs{ffs} = 1;
    $vfs{ufs} = 1;

    for my $t (keys %vfs) {
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
