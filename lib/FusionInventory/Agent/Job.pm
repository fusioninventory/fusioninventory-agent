package FusionInventory::Agent::Job;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use Memoize;

our @EXPORT = qw(
    sendError
);


sub sendError {
    my ($level, $msg) = @_;




    print STDERR "$level: $msg\n";
}

sub sendToMaster {
    my ($module, @args) = @_;

    print STDOUT "=BEGIN=$module: ".join('--', @args);
    print STDOUT "=END=";

    my $fromStdin;
    while (<STDIN> ne 'OK') {
        sleep 1;
    }
    
    return;
}



1;
