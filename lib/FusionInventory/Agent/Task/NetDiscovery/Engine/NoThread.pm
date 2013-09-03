package FusionInventory::Agent::Task::NetDiscovery::Engine::NoThread;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task::NetDiscovery::Engine';

sub scan {
    my ($self, @adresses) = @_;

    my @results;

    foreach my $address (@adresses) {
        my $result = $self->_scanAddress($address);
        push @results, $result if $result;
    }

    return @results;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetDiscovery::Engine::NoThread - Non-threaded network discovery engine
