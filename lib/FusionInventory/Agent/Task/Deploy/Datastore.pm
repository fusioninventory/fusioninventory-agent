package FusionInventory::Agent::Task::Deploy::Datastore;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Glob;
use File::Spec;
use File::Path qw(mkpath remove_tree);
use UNIVERSAL::require;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Task::Deploy::Datastore::WorkDir;

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

    my $diskFull=$self->diskIsFull();
    if (-d $self->{path}.'/workdir/') {
        remove_tree( $self->{path}.'/workdir/', {error => \my $err} );
    }
    if (-d $self->{path}.'/fileparts/private/') {
        remove_tree( $self->{path}.'/fileparts/private/', {error => \my $err} );
    }
    if (-d $self->{path}.'/fileparts/shared/') {
        foreach my $sharedSubDir (File::Glob::glob($self->{path}.'/fileparts/shared/*')) {
            next unless $sharedSubDir =~ /(\d+)/;
            if (time > $1 || $diskFull) {
                remove_tree( $sharedSubDir, {error => \my $err} );
            }
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

    if (-d $filePath || mkpath($filePath)) {
        return $filePath;
    } else {
        return;
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

    my $freeSpace =
        $OSNAME eq 'MSWin32' ? $self->_getFreeSpaceWindows() :
        $OSNAME eq 'solaris' ? $self->_getFreeSpaceSolaris() :
                               $self->_getFreeSpace()        ;

    if (!$freeSpace) {
	$logger->debug('$spaceFree is undef!');
	$freeSpace = 0;
    }

    $logger->debug("Free space on $self->{path}: $freeSpace");
    # 400MB Free, should be set by a config option
    return ($freeSpace < 2000);
}

sub _getFreeSpaceWindows {
    my ($self) = @_;

    my $logger = $self->{logger};

    FusionInventory::Agent::Tools::Win32->require();
    if ($EVAL_ERROR) {
        $logger->error(
            "Failed to load FusionInventory::Agent::Tools::Win32: $EVAL_ERROR"
        );
        return;
    }

    my $letter;
    if ($self->{path} !~ /^(\w):./) {
        $logger->error("Path parse error: ".$self->{path});
        return;
    }
    $letter = $1.':';

    my $freeSpace;
    foreach my $object (FusionInventory::Agent::Tools::Win32::getWmiObjects(
        moniker    => 'winmgmts:{impersonationLevel=impersonate,(security)}!//./',
        class      => 'Win32_LogicalDisk',
        properties => [ qw/Caption FreeSpace/ ]
    )) {
        next unless lc($object->{Caption}) eq lc($letter);
        my $t = $object->{FreeSpace};
        if ($t && $t =~ /(\d+)\d{6}$/) {
            $freeSpace = $1;
        }
    }

    return $freeSpace;
}

sub _getFreeSpaceSolaris {
    my ($self) = @_;

    return unless -d $self->{path};

    return getFirstMatch(
        command => "df -b $self->{path}",
        pattern => qr/^\S+\s+(\d+)\d{3}[^\d]/,
        logger  => $self->{logger}
    );
}

sub _getFreeSpace {
    my ($self) = @_;

    return unless -d $self->{path};

    return getFirstMatch(
        command => "df -Pk $self->{path}",
        pattern => qr/^\S+\s+\S+\s+\S+\s+(\d+)\d{3}[^\d]/,
        logger  => $self->{logger}
    );
}

1;
