package FusionInventory::Test::Inventory;

use strict;
use warnings;
use base qw(FusionInventory::Agent::Inventory);

use FusionInventory::Test::Logger::Fatal;

sub new {
    my ($class, %params) = @_;

    my $logger = FusionInventory::Test::Logger::Fatal->new(
        verbosity => 5
    );

    return $class->SUPER::new(logger => $logger);
}

1;
