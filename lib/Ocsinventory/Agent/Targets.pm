package Ocsinventory::Agent::Targets;

use Data::Dumper;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    my $config = $self->{config} = $params->{config};
    my $logger = $self->{logger} = $params->{logger};

    $self->{targets} = [];


    print Dumper($config->{server});


    bless $self;
}

sub addTarget {
    my ($self, $params) = @_;

    my $logger = $self->{'logger'};

    $logger->fault("No target?!") unless $params->{'target'};

    push @{$self->{targets}}, $params->{'target'};

}


1;
