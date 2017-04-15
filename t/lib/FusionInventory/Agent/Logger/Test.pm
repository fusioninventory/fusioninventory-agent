package FusionInventory::Agent::Logger::Test;

use strict;
use warnings;
use base 'FusionInventory::Agent::Logger';

use English qw(-no_match_vars);

sub _log {
    my ($self, %params) = @_;

    $self->{message} = $params{message};
    $self->{level}   = $params{level};
}

1;
