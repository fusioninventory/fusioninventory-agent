package Ocsinventory::Agent::Target;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{'type'} = $params->{'type'};
    $self->{'path'} = $params->{'path'};


    bless $self;
}



1;
