package FusionInventory::Test::Logger::Fatal;

use strict;
use warnings;
use base 'FusionInventory::Agent::Logger';

use English qw(-no_match_vars);
use Carp;

sub _log {
    my ($self, %params) = @_;

    croak $params{message};
}

1;
