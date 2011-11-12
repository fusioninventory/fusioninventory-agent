package FusionInventory::Test::Utils;

use strict;
use warnings;
use base 'Exporter';

use Socket;

our @EXPORT = qw(
    test_port
    filter
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

# blacklist additional tasks that may be installed
sub filter {
    if ($_ =~ m{FusionInventory/VMware}) {
        return 0;
    }
    if ($_ =~ m{FusionInventory/Agent/Tools}) {
        return 1;
    }
    if ($_ !~ m{FusionInventory/Agent/Task/(Inventory|WakeOnLan)}) {
        return 0;
    }
    return 1;
}



