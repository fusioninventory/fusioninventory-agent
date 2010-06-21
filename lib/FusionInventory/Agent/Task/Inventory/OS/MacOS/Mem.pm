package FusionInventory::Agent::Task::Inventory::OS::MacOS::Mem;

use strict;
use warnings;

sub isInventoryEnabled {
    return(undef) unless -r '/usr/sbin/system_profiler'; # check perms
    return (undef) unless can_load("Mac::SysProfile");
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $PhysicalMemory;

    # create the profile object and return undef unless we get something back
    my $pro = Mac::SysProfile->new();
    my $h = $pro->gettype('SPMemoryDataType');
    return(undef) unless(ref($h) eq 'HASH');

    # Workaround for MacOSX 10.5.7
    if ($h->{'Memory Slots'}) {
      $h = $h->{'Memory Slots'};
    }


    foreach my $x (keys %$h){
        next unless $x =~ /^BANK|SODIMM|DIMM/;
        # tare out the slot number
        my $slot = $x;
	# memory in 10.5
        if($slot =~ /^BANK (\d)\/DIMM\d/){
            $slot = $1;
        }
	# 10.4
	if($slot =~ /^SODIMM(\d)\/.*$/){
		$slot = $1;
	}
	# 10.4 PPC
	if($slot =~ /^DIMM(\d)\/.*$/){
		$slot = $1;
	}

        my $size = $h->{$x}->{'Size'};

        # if system_profiler lables the size in gigs, we need to trim it down to megs so it's displayed properly
        if($size =~ /GB$/){
                $size =~ s/GB$//;
                $size *= 1024;
        }
        $inventory->addMemory({
            'CAPACITY'      => $size,
            'SPEED'         => $h->{$x}->{'Speed'},
            'TYPE'          => $h->{$x}->{'Type'},
            'SERIALNUMBER'  => $h->{$x}->{'Serial Number'},
            'DESCRIPTION'   => $h->{$x}->{'Part Number'} || $x,
            'NUMSLOTS'      => $slot,
            'CAPTION'       => 'Status: '.$h->{$x}->{'Status'},
        });
    }
}
1;
