package FusionInventory::Agent::Logger::Fatal;

use strict;
use warnings;
use base 'FusionInventory::Agent::Logger::Backend';

use English qw(-no_match_vars);
use Carp;

sub new {
    my ($class, $params) = @_;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub addMessage {
    my ($self, %params) = @_;

    croak $params{message};
}

1;
