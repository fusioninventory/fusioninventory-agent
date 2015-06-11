package Win32;

use strict;
use warnings;

my $win2003 = 0 ;

sub GetOSName {
    return $win2003 ? 'Win2003' : 'Win7';
}

sub fakewin2003 {
    $win2003 = shift ;
}

1;
