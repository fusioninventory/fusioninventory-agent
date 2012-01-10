package FusionInventory::Test::Utils;

use strict;
use warnings;
use base 'Exporter';

use Socket;

our @EXPORT = qw(
    test_port
);

sub test_port {
    my ($port) = @_;

    my $iaddr = inet_aton('localhost');
    my $paddr = sockaddr_in($port, $iaddr);
    my $proto = getprotobyname('tcp');
    if (socket(my $socket, PF_INET, SOCK_STREAM, $proto)) {
        if (connect($socket, $paddr)) {
            close $socket;
            return 1;
        } 
    }

    return 0;
}
