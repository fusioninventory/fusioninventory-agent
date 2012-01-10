package FusionInventory::Agent::Tools::Hostname;

use strict;
use warnings;

use UNIVERSAL::require();
use Encode;
use English qw(-no_match_vars);

BEGIN {
    if ($OSNAME eq 'MSWin32') {
        Win32::API->require();
        # Kernel32.dll is used more or less everywhere.
        # Without this, Win32::API will release the DLL even
        # if it's a very bad idea
        *Win32::API::DESTROY = sub {};
    }
}

sub getHostname {

    if ($OSNAME eq 'MSWin32') {
        my $GetComputerName = Win32::API->new("kernel32", "GetComputerNameExW", ["I", "P", "P"], "N");
        my $buffer = "\x00" x 1024;
        my $N=1024;#pack ("c4", 160,0,0,0);

        $GetComputerName->Call(3, $buffer, $N);

        # GetComputerNameExW returns the string in UTF16, we have to change it
        # to UTF8
        return encode("UTF-8", substr(decode("UCS-2le", $buffer),0,ord $N));
    } else {
        Sys::Hostname->require();
        return Sys::Hostname::hostname();
        return
    }

}

1;
