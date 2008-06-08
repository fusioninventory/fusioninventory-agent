package Ocsinventory::Agent::Backend::OS::MacOS::Sound;
use strict;

use constant DATATYPE   => 'SPAudioDataType'; # may need to fix to work with older versions of osx

sub check {
    return(undef) unless -r '/usr/sbin/system_profiler'; # check perms
    return(undef) unless can_load("Mac::SysProfile"); # check perms
    return 1;
}

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

    # create profiler obj, bail if datatype fails
    my $pro = Mac::SysProfile->new();
    my $h = $pro->gettype(DATATYPE());
    return(undef) unless(ref($h) eq 'HASH');

    # add sound cards
    foreach my $x (keys %$h){
        $inventory->addSounds({
            'NAME'          => $x,
            'MANUFACTURER'  => $x,
            'DESCRIPTION'   => $x,
        });
    }
}
1;
