package FusionInventory::Agent::Logger::Test;

use strict;
use warnings;
use base 'FusionInventory::Agent::Logger::Backend';

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub addMsg {
    my ($self, $args) = @_;

    $self->{message} = $args->{message};
    $self->{level}   = $args->{level};
}

1;
