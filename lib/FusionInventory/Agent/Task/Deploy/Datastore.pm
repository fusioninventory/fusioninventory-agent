package FusionInventory::Agent::Task::Deploy::Datastore;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Glob;
use File::Spec;
use File::Path qw(mkpath rmtree);
use UNIVERSAL::require;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Task::Deploy::Datastore::WorkDir;
use FusionInventory::Agent::Task::Deploy::DiskFree;

sub new {
    my ($class, %params) = @_;

    die "no path parameter" unless $params{path};

    my $self = {
        path   => File::Spec->rel2abs($params{path}),
        logger => $params{logger} ||
                  FusionInventory::Agent::Logger->new(),
    };

    if (!$self->{path}) {
      die("No datastore path");
    }

    bless $self, $class;

    return $self;
}

sub cleanUp {
    my ($self) = @_;

    return unless -d $self->{path};

    my @storageDirs;
    push @storageDirs, File::Glob::glob($self->{path}.'/fileparts/private/*');
    push @storageDirs, File::Glob::glob($self->{path}.'/fileparts/shared/*');

    my $diskFull=$self->diskIsFull();
    if (-d $self->{path}.'/workdir/') {
        remove_tree( $self->{path}.'/workdir/', {error => \my $err} );
    }

    foreach my $dir (@storageDirs) {

        if (!-d $dir) {
            unlink $dir;
            next;
        }

        next unless $dir =~ /(\d+)$/;

        if (time > $1 || $diskFull) {
            remove_tree( $dir, {error => \my $err} );
        }
    }

}

sub createWorkDir {
    my ($self, $uuid) = @_;

#    mkpath($filePath);

    my $path = $self->{path}.'/workdir/'.$uuid;

    mkpath($path);
    return unless -d $path;

    return FusionInventory::Agent::Task::Deploy::Datastore::WorkDir->new(
        path => $path,
        logger => $self->{logger}
    );
}

sub diskIsFull {
    my ($self) = @_;

    my $logger = $self->{logger};

    my $freeSpace = getFreeSpace(
        path => $self->{path},
        logger => $logger
    );

    if (!$freeSpace) {
        $logger->debug('$spaceFree is undef!');
        $freeSpace = 0;
    }

    $logger->debug("Free space on $self->{path}: $freeSpace");
    # 400MB Free, should be set by a config option
    return ($freeSpace < 2000);
}

# imported from File-Path-2.09
sub remove_tree {
    push @_, {} unless @_ and UNIVERSAL::isa($_[-1],'HASH');
    goto &rmtree;
}

1;
