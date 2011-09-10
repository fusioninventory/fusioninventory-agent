package FusionInventory::Agent::Task::Deploy::Datastore;

use FusionInventory::Agent::Task::Deploy::Datastore::WorkDir;

use strict;
use warnings;

use File::Glob;
use File::Path qw(make_path remove_tree);

sub new {
    my (undef, $params) = @_;

    die unless $params->{path};

    my $self = {
        path => $params->{path},
    };



    bless $self;
}

sub cleanUp {
    my ($self) = @_;

    if (-d $self->{path}.'/workdir/') {
        remove_tree( $self->{path}.'/workdir/', {error => \my $err} );
    }
    if (-d $self->{path}.'/fileparts/private/') {
        remove_tree( $self->{path}.'/fileparts/private/', {error => \my $err} );
    }
    if (-d $self->{path}.'/fileparts/shared/') {
        foreach my $sharedSubDir (File::Glob::glob($self->{path}.'/fileparts/shared/*')) {
            next unless $sharedSubDir =~ /(\d+)/;
            next unless time > $1;
            remove_tree( $sharedSubDir, {error => \my $err} );
        }
    }

}

sub getPathBySha512 {
    my ($self, $sha512) = @_;

    my $shortSha;
    $sha512 =~ /^(.{6})/;
    $shortSha = $1;

    die unless $shortSha;

    my $filePath = $self->{path}.'/files/'.$shortSha;

    if (-d $filePath || make_path($filePath)) {
        return $filePath;
    } else {
        return;
    }
}

sub createWorkDir {
    my ($self, $uuid) = @_;

#    make_path($filePath);

    my $path = $self->{path}.'/workdir/'.$uuid;

    make_path($path);
    return unless -d $path;

    return FusionInventory::Agent::Task::Deploy::Datastore::WorkDir->new({ path => $path});


}
1;
