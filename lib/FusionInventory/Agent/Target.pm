package FusionInventory::Agent::Target;

use strict;
use warnings;
use Carp qw(confess);
sub new {
    my ($class, %params) = @_;
confess "deprecated!";
    die 'no id parameter' unless $params{id};

    my $self = {
        id     => $params{id},
        format => $params{format},
        logger => $params{logger} || FusionInventory::Agent::Logger->new(),
    };

    bless $self, $class;

    return $self;
}

sub getId {
    my ($self) = @_;
    return $self->{id};
}

sub getFormat {
    my ($self) = @_;
    return $self->{format};
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
