package FusionInventory::Agent::Tools::Hostname;

use strict;
use warnings;

use UNIVERSAL::require();
use Encode;
use English qw(-no_match_vars);

BEGIN {
    if ($OSNAME eq 'MSWin32') {
        no warnings 'redefine'; ## no critic (ProhibitNoWarnings)
        Win32::API->require();
        # Kernel32.dll is used more or less everywhere.
        # Without this, Win32::API will release the DLL even
        # if it's a very bad idea
        *Win32::API::DESTROY = sub {};
    }
}

sub getHostname {

    if ($OSNAME ne 'MSWin32') {
        Sys::Hostname->require();
        return Sys::Hostname::hostname();
    }

    my $getComputerName = Win32::API->new(
        "kernel32", "GetComputerNameExW", ["I", "P", "P"], "N"
    );
    my $buffer = "\x00" x 1024;
    my $n = 1024; #pack ("c4", 160,0,0,0);

    $getComputerName->Call(3, $buffer, $n);

    # GetComputerNameExW returns the string in UTF16, we have to change it
    # to UTF8
    return substr(decode("UCS-2le", $buffer), 0, ord $n);
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Hostname - OS-independent hostname computing

=head1 DESCRIPTION

This module provides a generic function to retrieve host name

=head1 FUNCTIONS

=head2 getHostname()

Returns the host name.
