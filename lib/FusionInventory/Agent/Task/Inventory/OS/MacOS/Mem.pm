package FusionInventory::Agent::Task::Inventory::OS::MacOS::Mem;

use strict;
use warnings;

my %speedMatrice = (
    mhz => 1,
    ghz => 1000,
);
my %sizeMatrice = (
    mb => 1,
    gb => 1000,
    tb => 1000*1000,
);


sub isInventoryEnabled {
    return(undef) unless -r '/usr/sbin/system_profiler'; # check perms
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};


    my $revIndent = '';
    my @memories;
    my $slot;
    foreach (`/usr/sbin/system_profiler SPMemoryDataType`) {
        next if /^\s*$/;
        next unless /^(\s*)/;

        if ($1 ne $revIndent) {
            $revIndent = $1;
            push @memories, $slot if keys %$slot>2;
            $slot = {};
        }
        if (/^\s+(\S+.*?):\s+(\S.*)/) { # we're probably in a memory section
            $slot->{$1}=$2;
        }
    }
    push @memories, $slot if keys %$slot>2;
    my $numSlot=0;
    foreach (@memories) {
        my $speed;
        my $size;

	if ($_->{'Speed'} eq 'PC3200U-30330') {
	    $speed = 400;
        } elsif ($_->{'Speed'} =~ /(\d+)\s+(\S+)/) {
            $speed = $1*$speedMatrice{lc($2)};
        }
        if ($_->{'Size'} =~ /(\d+)\s+(\S+)/) {
            $size = $1*$sizeMatrice{lc($2)};
        }

        my $description = $_->{'Part Number'};

	if ($description) {
	    $description = pack 'H*', $description if $description =~ s/^0x//;

	    $description =~ s/\s*$//;
	}

        $inventory->addMemory({
                'CAPACITY'      => $size,
                'SPEED'         => $speed,
                'TYPE'          => $_->{'Type'},
                'SERIALNUMBER'  => $_->{'Serial Number'},
                'DESCRIPTION'   => $description,
                'NUMSLOTS'      => $numSlot++,
                'CAPTION'       => 'Status: '.$_->{'Status'},
            });
    }
}
1;
