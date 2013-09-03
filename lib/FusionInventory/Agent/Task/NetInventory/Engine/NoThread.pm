package FusionInventory::Agent::Task::NetInventory::Engine::NoThread;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task::NetInventory::Engine';

sub query {
    my ($self, @devices) = @_;

    my @results;

    foreach my $device (@devices) {
        my $result = $self->_queryDevice($device);
        push @results, $result if $result;
    }

    return @results;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetInventory::Engine::NoThread - Non-threaded remote inventory engine
