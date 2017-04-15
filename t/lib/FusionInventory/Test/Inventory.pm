package FusionInventory::Test::Inventory;

use strict;
use warnings;
use base qw(FusionInventory::Agent::Inventory);

use FusionInventory::Agent::Logger::Fatal;

sub new {
    my ($class, %params) = @_;

    my $logger = FusionInventory::Agent::Logger::Fatal->new(
        verbosity => 5
    );

    return $class->SUPER::new(logger => $logger);
}

1;
