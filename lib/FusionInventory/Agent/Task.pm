package FusionInventory::Agent::Task;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Logger;

sub new {
    my ($class, %params) = @_;

    my $self = {
        logger => $params{logger} || FusionInventory::Agent::Logger->new(),
    };
    bless $self, $class;

    return $self;
}

sub configure {
    my ($self, %params) = @_;

    foreach my $key (keys %params) {
        $self->{config}->{$key} = $params{$key};
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task - Base class for agent task

=head1 DESCRIPTION

This is an abstract class for all task performed by the agent.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=back

=head2 isEnabled()

This is a method to be implemented by each subclass.

=head2 run()

This is a method to be implemented by each subclass.

=head2 getOptionsFromServer($response, $name, $feature)

Get task-specific options in server response to prolog message.
