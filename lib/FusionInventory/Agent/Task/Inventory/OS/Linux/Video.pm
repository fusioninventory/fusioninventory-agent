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
# Intel
	    if (/Modeline\s"(\S+?)"/) {
		$xorgData->{resolution}=$1 
	    } elsif (/Integrated Graphics Chipset:\s+(.*)/) {
		$xorgData->{name}=$1;
	    }
# Nvidia
	    elsif (/Virtual screen size determined to be (\d+)\s*x\s*(\d+)/) {
		$xorgData->{resolution}="$1x$2";
	    }
	    elsif (/NVIDIA GPU\s*(.*?)\s*at/) {
		$xorgData->{name}=$1;
	    }
	    elsif (/VESA VBE OEM:\s*(.*)/) {
		$xorgData->{name}=$1;
	    }
	    elsif (/VESA VBE OEM Product:\s*(.*)/) {
		$xorgData->{product}=$1;
	    }
	    elsif (/VESA VBE Total Mem: (\d+)\s*(\w+)/i) {
		$xorgData->{memory}=$1.$2;
	    }
# ATI /Radeon
            elsif (/RADEON\(0\): Chipset: "(.*?)"/i) {
		$xorgData->{name}=$1;
	    }
# VESA / XFree86
            elsif (/Virtual size is (\S+)/i) {
		$xorgData->{resolution}=$1;
	    }
	}
	close(XORG);
    }
    return $xorgData;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $ddcprobeData = _getDdcprobeData('ddcprobe 2>&1', "|-");

    my $xOrgPid;
    foreach (`ps aux`) {
	if ((/\/usr(\/bin|\/X11R6\/bin)\/X/ || /Xorg/) && /^\S+\s+(\d+)/) {
	    $xOrgPid = $1;
	    last;
	}
    }

    my $xorgData;
    if ($xOrgPid) {
	$xorgData = _parseXorgFd("</proc/$xOrgPid/fd/0");
    }

    my $memory = $xorgData->{memory} || $ddcprobeData->{memory};
    if ($memory && $memory =~ s/kb$//i) {
	$memory = int($memory / 1024);
    }

    $inventory->addVideo({
	CHIPSET    => $xorgData->{product} || $ddcprobeData->{product},
	MEMORY     => $memory,
	NAME       => $xorgData->{name} || $ddcprobeData->{oem},
	RESOLUTION => $xorgData->{resolution} || $ddcprobeData->{dtiming}
	});

}

1;
