package FusionInventory::Agent::Task;

use strict;
use warnings;

use FusionInventory::Agent::Job::Logger;
use FusionInventory::Agent::Job::Config;
use FusionInventory::Agent::Job::Network;
use FusionInventory::Agent::Job::Target;
use FusionInventory::Agent::Job::Prolog;
use FusionInventory::Agent::Storage;

sub new {
    my ($class, $params) = @_;

    my $self = {};

    $self->{prolog} = FusionInventory::Agent::Job::Prolog->new();
    $self->{config} = FusionInventory::Agent::Job::Config->new();
    $self->{logger} = FusionInventory::Agent::Job::Logger->new();
    $self->{network} = FusionInventory::Agent::Job::Network->new();
    $self->{target} = FusionInventory::Agent::Job::Target->new();
    $self->{storage} = FusionInventory::Agent::Storage->new();

    # Transition, please use prolog instead of prologresp
    $self->{prologresp} = $self->{prolog};
#    my $self = {
#        config      => $params->{config},
#        target      => $params->{target},
#        logger      => $params->{logger},
#        storage     => $params->{storage},
#        prologresp  => $params->{prologresp},
#        transmitter => $params->{transmitter}
#    };

    bless $self, $class;

    return $self;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task - Base class for agent task

=head1 DESCRIPTION

This is an abstract class for all task performed by the agent.

=head1 METHODS

=head2 new($params)

The constructor. The following named parameters are allowed:

=over

=item config (mandatory)

=item target (mandatory)

=item logger (mandatory)

=item storage (mandatory)

=item prologresp (mandatory)

=back

=head2 run()

This is the method expected to be implemented by each subclass.
