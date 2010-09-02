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

    bless $self, $class;
    
    return $self;
}

1;
