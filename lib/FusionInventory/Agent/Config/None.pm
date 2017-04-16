package FusionInventory::Agent::Config::None;

use strict;
use warnings;
use base 'FusionInventory::Agent::Config';

use English qw(-no_match_vars);

sub _load {
    my ($self, %params) = @_;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Config::None - Empty configuration backend

=head1 DESCRIPTION

This is the object used by the agent to store its configuration
