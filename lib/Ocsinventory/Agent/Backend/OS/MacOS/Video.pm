package Ocsinventory::Agent::Backend::OS::MacOS::Video;
use strict;

use constant DATATYPE => 'SPDisplaysDataType'; # careful this could change when looking at lower versions of OSX

sub check {
    # make sure the user has access, cause that's the command that's gonna be run
    return(undef) unless -r '/usr/sbin/system_profiler';
    return(undef) unless can_load("Mac::SysProfile");
    return 1;
}

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

    # run the profiler to get our datatype
    my $pro = Mac::SysProfile->new();
    my $h = $pro->gettype(DATATYPE());

    # unless we get a valid return, bail out
    return(undef) unless(ref($h) eq 'HASH');

    # add the video information
    foreach my $x (keys %$h){
        $inventory->addVideos({
                'NAME'        => $x,
                'CHIPSET'     => $h->{$x}->{'Chipset Model'},
                'MEMORY'    => $h->{$x}->{'VRAM (Total)'},
        });

        # this doesn't work yet, need to fix the Mac::SysProfile module to not be such a hack (parser only goes down one level)
        # when we do fix it, it will attach the displays that sysprofiler shows in a tree form
        # apple "xml" blows. Hard.
        foreach my $display (keys %{$h->{$x}}){
            my $ref = $h->{$x}->{$display};
            $inventory->addMonitors({
                'CAPTION'       => $ref->{'Resolution'},
                'DESCRIPTION'   => $display,
            })
        }
    }

}
1;
