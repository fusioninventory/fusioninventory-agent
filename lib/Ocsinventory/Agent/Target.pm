package Ocsinventory::Agent::Target;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    my $config = $self->{config} = $params->{config};
    my $logger = $self->{logger} = $params->{logger};

    $self->{targets} = [];


    bless $self;
}



1;
