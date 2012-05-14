package Win32::OLE;

use strict;
use warnings;

use constant CP_UTF8 => 0;

$INC{'Win32/OLE/Const.pm'} = 1;
$INC{'Win32/OLE/Enum.pm'} = 1;
$INC{'Win32/OLE/Variant.pm'} = 1;

sub import {
    my $callpkg = caller();
    no strict 'refs';

    *{"$callpkg\::in"}       = sub {};
    *{"$callpkg\::CP_UTF8"}  = sub {};
    *{"$callpkg\::VT_BYREF"} = sub {};
    *{"$callpkg\::VT_BSTR"}  = sub {};
}

sub Option {
}

1;
