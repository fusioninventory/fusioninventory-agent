package Ocsinventory::Agent::Storage;
        
use Storable;

use strict;
use warnings;


use Data::Dumper;

sub new {
    my ( undef, $params ) = @_;

    my $self = {};

    my $config = $self->{config} = $params->{config};
    my $target = $self->{target} = $params->{target};

    $self->{vardir} = $target->{vardir};

    bless $self;
}

sub save {
    my ($self, $data) = @_;

    my $target = $self->{target};

    my $tmp = caller(0);
    $tmp =~ s/::/-/g; # Drop the ::
    # They are forbiden on Windows in file path
    my $file = $target->{'vardir'}."/".$tmp.".dump";
	print "[storage]save data in:". $file."\n";

	store ($data, $file) or die;

}

sub restore {
    my ($self, $module) = @_;

    my $tmp = $module || caller(0);
    $tmp =~ s/::/-/g;

    my $target = $self->{target};

    my $file = $target->{'vardir'}."/$tmp.dump";
	print "[storage]restore data from: $file\n";
    if (-f $file) {
        return retrieve($file);
    }

}

sub remove {
    # TODO

}

1;
