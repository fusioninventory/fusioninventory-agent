package Ocsinventory::Agent::Backend::OS::MacOS::Mem;
use strict;

use Mac::SysProfile; # macsysprofile, what a great "almost" module

sub check {
    return(undef) unless -r '/usr/sbin/system_profiler'; # check perms
    return 1;
}

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $PhysicalMemory;

    # create the profile object and return undef unless we get something back
    my $pro = Mac::SysProfile->new();
    my $h = $pro->gettype('SPMemoryDataType');
    return(undef) unless(ref($h) eq 'HASH');

    foreach my $x (keys %$h){
        # tare out the slot number
        my $slot = $x;
        if($slot =~ /^BANK (\d)\/DIMM\d/){
            $slot = $1;
        }

        my $size = $h->{$x}->{'Size'};

        # if system_profiler lables the size in gigs, we need to trim it down to megs so it's displayed properly
        if($size =~ /GB$/){
                $size =~ s/GB$//;
                $size *= 1024;
        }
        $inventory->addMemories({
            'CAPACITY'      => $size,
            'SPEED'         => $h->{$x}->{'Speed'},
            'TYPE'          => $h->{$x}->{'Type'},
            'SERIALNUMBER ' => $h->{$x}->{'Serial Number'},
            'DESCRIPTION'   => $h->{$x}->{'Part Number'},
            'NUMSLOTS'      => $slot,
            'CAPTION'       => 'Status: '.$h->{$x}->{'Status'},
        });
    }
}
1;
