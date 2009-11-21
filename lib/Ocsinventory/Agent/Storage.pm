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

    my $tmp = caller(0);
    $tmp =~ s/::/-/g; # Drop the ::
    # They are forbiden on Windows in file path
    my $file = $self->{'vardir'}."/".$tmp.".dump";
	print "SAVE CONFIG IN:". $file."\n";

	store ($data, $file) or die;

}

sub restore {
    my ($self, $module) = @_;

    my $tmp = $module || caller(0);
    $tmp =~ s/::/-/g;

    my $file = $self->{vardir}."/$tmp.dump";
	print "RESTORE CONFIG FROM: $file\n";
    if (-f $file) {
        return retrieve($file);
    }

}

sub remove {


}

1;
