package FusionInventory::Agent::Task::Inventory::OS::MacOS;

use strict;

sub isInventoryEnabled {
	my $r;
	# we check far darwin because that's the _real_ underlying OS
	$r = 1 if (uc($^O) =~ /^DARWIN$/);
	return($r);
}

sub doInventory {
        my $params = shift;
        my $inventory = $params->{inventory};

        my $OSName;
        my $OSComment;
        my $OSVersion;
		
		# if we can load the system profiler, gather the information from that
		if(can_load("Mac::SysProfile")){
			my $profile = Mac::SysProfile->new();
			my $h = $profile->gettype('SPSoftwareDataType');
			return(undef) unless(ref($h) eq 'HASH');
			
			$h = $h->{'System Software Overview'};
			
			my $SystemVersion = $h->{'System Version'};
			if ($SystemVersion =~ /^(.*?)\s+(\d+.*)/) {
			    $OSName=$1;
			    $OSVersion=$2;
			} else {
			    # Default values
			    $OSName="Mac OS X";
			    $OSVersion="Unknown";
			}

		} else {
			# we can't load the system profiler, use the basic BSD stype information
			# Operating system informations
			chomp($OSName=`uname -s`);
			chomp($OSVersion=`uname -r`);			
		}
		
		# add the uname -v as the comment, not really needed, but extra info never hurt
		chomp($OSComment=`uname -v`);
        $inventory->setHardware({
                OSNAME		=> $OSName,
                OSCOMMENTS	=> $OSComment,
                OSVERSION	=> $OSVersion,
        });
}


1;
