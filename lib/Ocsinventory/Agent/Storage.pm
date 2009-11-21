package Ocsinventory::Agent::Storage;
        
use Storable;

use strict;
use warnings;


use Data::Dumper;

sub new {
    my ( undef, $params ) = @_;

    my $self = {};

    my $config = $self->{config} = $params->{config};

    $self->{vardir} = $config->{vardir};

    bless $self;
}

sub save {
    my ($self, $data) = @_;

	print "SAVE CONFIG IN:". $self->{'vardir'}."/config.dump\n";

	store ($data, $self->{'vardir'}.'/config.dump') or die;

}

sub restore {
    my ($self) = @_;

    my $file = $self->{vardir}."/config.dump";
	print "RESTORE CONFIG FROM: $file\n";
    if (-f $file) {
        return retrieve($file);
    }

}

sub remove {


}

1;
