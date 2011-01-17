package FusionInventory::Agent::Target;

use strict;
use warnings;

sub new {
    my ($class, %params) = @_;

    die 'no id parameter' unless $params{id};

    my $self = {
        id     => $params{id},
        logger => $params{logger} || FusionInventory::Agent::Logger->new(),
    };

    bless $self, $class;

    return $self;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Target - Abstract target

=head1 DESCRIPTION

A target is the recipient of a task execution.

=head1 METHODS

=head2 new(%params)

The constructor. See subclass documentation for parameters.
