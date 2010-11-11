package FusionInventory::Agent::Task::Inventory::OS::Linux::Video;

use strict;
use warnings;

sub isInventoryEnabled {
    return 1;
}

sub _getDdcprobeData {
    my ($cmd, $param) = @_;
    my $ddcprobeData;
    if (open my $handle, $param, $cmd) {
	foreach (<$handle>) {
	    s/[[:cntrl:]]//g;
	    s/[^[:ascii:]]//g;
	    $ddcprobeData->{$1} = $2 if /^(\S+):\s+(.*)/;
	}
    }

    return $ddcprobeData;
}

sub _parseXorgFd {
    my ($file) = @_;

    my $xorgData;
    if (open XORG, $file) {
	foreach (<XORG>) {
	    $xorgData->{resolution}=$1 if /Modeline\s"(\S+?)"/;
	}
    }
    return $xorgData;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $ddcprobeData = _getDdcprobeData("ddcprobe", "|-");

    my $xOrgPid;
    foreach (`ps aux`) {
	if ((/\/usr\/bin\/X/ || /Xorg/) && /^\S+\s+(\d+)/) {
	    $xOrgPid = $1;
	    last;
	}
    }

    my $xorgData;
    if ($xOrgPid) {
	$xorgData = _parseXorgFd("</proc/$xOrgPid/fd/0");
    }

    my $memory;
    if ($ddcprobeData->{memory} =~ s/kb$//i) {
	$memory = int($ddcprobeData->{memory} / 1024);
    } elsif ($ddcprobeData->{memory} =~ s/mb$//i) {
	$memory = $ddcprobeData->{memory};
    }

    $inventory->addVideo({
	CHIPSET    => $ddcprobeData->{product},
	MEMORY     => $memory,
	NAME       => $ddcprobeData->{oem},
	RESOLUTION => $ddcprobeData->{dtiming} || $xorgData->{resolution}
	});

}

1;
