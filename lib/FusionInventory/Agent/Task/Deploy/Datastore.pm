package FusionInventory::Agent::Task::Deploy::Datastore;

use FusionInventory::Agent::Task::Deploy::Datastore::Session;

use strict;
use warnings;

use File::Path qw(make_path);

sub new {
    my (undef, $params) = @_;

    my $self = {
        path => $params->{path},
    };

    bless $self;
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

sub createSession {
    my ($self, $job) = @_;

#    make_path($filePath);


    return FusionInventory::Agent::Task::Deploy::Datastore::Session->new({ path => $self->{path}.'/sessions/'.$job->{uuid} });


}
1;
