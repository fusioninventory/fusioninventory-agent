package FusionInventory::Agent::Tools::Hostname;

use strict;
use warnings;
use parent 'Exporter';

use UNIVERSAL::require();
use Encode;
use English qw(-no_match_vars);

our @EXPORT = qw(
    getHostname
);

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
    my (%params) = @_;

    my $hostname = $OSNAME eq 'MSWin32' ?
        _getHostnameWindows() :
        _getHostnameUnix()    ;
    return $hostname;
}

sub _getHostnameUnix {
    Net::Domain->require();
    return Net::Domain::hostfqdn();
}

sub _getHostnameWindows {
    my $getComputerName = Win32::API->new(
        "kernel32", "GetComputerNameExW", ["I", "P", "P"], "N"
    );
    my $buffer = "\x00" x 1024;
    my $n = 1024; #pack ("c4", 160,0,0,0);

    $getComputerName->Call(3, $buffer, $n);

    # convert from UTF16 to UTF8
    my $hostname = substr(decode("UCS-2le", $buffer), 0, ord $n);

    return $hostname || $ENV{COMPUTERNAME};
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