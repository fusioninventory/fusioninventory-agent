package FusionInventory::Agent::Task::Deploy::Datastore;

use FusionInventory::Agent::Task::Deploy::Datastore::WorkDir;

use strict;
use warnings;

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

    remove_tree( $self->{path}.'/sessions/', {error => \my $err} );
    if (@$err) {
        for my $diag (@$err) {
            my ($file, $message) = %$diag;
            if ($file eq '') {
                print "general error: $message\n";
            }
            else {
                print "problem unlinking $file: $message\n";
            }
        }
    }

}

sub getPathBySha512 {
    my ($self, $sha512) = @_;

    my $filePath = $self->{path}.'/files/'.$sha512;

    if (-d $filePath || make_path($filePath)) {
        return $filePath;
    } else {
        return;
    }
}

sub createWorkDir {
    my ($self, $uuid) = @_;

#    make_path($filePath);

    my $path = $self->{path}.'/sessions/'.$uuid;

    return unless make_path($path);

    return FusionInventory::Agent::Task::Deploy::Datastore::WorkDir->new({ path => $path});


}
1;
