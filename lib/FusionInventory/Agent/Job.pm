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
    my ($self, $level, $msg) = @_;




    print STDERR "$level: $msg\n";
}



1;
