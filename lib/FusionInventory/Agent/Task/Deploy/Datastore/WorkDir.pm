package FusionInventory::Agent::Task::Deploy::Datastore::WorkDir;

use strict;
use warnings;

use Data::Dumper;
use File::Path qw(make_path);

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{path} = $params->{path};
    $self->{files} = [];

    bless $self;
}

sub addFile {
    my ($self, $file) = @_;

    push @{$self->{files}}, $file;

    

}

sub prepare {
    my ($self) = @_;

    foreach my $file (@{$self->{files}}) {
        my $finalFilePath = $self->{path}.'/'.$file;

        if (!open(FILE, $finalFilePath)) {
            print "Failed to open ".$finalFilePath.": $!"; 
            return;
        }

        foreach my $part (@{$file->{multipart}}) {
            my ($filename, $sha512) = %$part;
            print Dumper($filename);
        }

        close FILE;
    }

}

1;
