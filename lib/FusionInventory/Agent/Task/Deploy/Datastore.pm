package FusionInventory::Agent::Task::Deploy::Datastore;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Glob;
use File::Path qw(make_path remove_tree);

use FusionInventory::Agent::Task::Deploy::Datastore::WorkDir;

sub new {
    my ($class, %params) = @_;

    die "no path parameter" unless $params{path};

    my $self = {
        path => $params{path},
    };

    bless $self, $class;

    return $self;
}

sub cleanUp {
    my ($self) = @_;

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

    return FusionInventory::Agent::Task::Deploy::Datastore::WorkDir->new(
        path => $path
    );
}

sub diskIsFull {
    my ( $self ) = @_;

    my $logger = $self->{logger};

    my $spaceFree;
    if ($OSNAME eq 'MSWin32') {

        if (!eval ('
                use Win32::OLE qw(in CP_UTF8);
                use Win32::OLE::Const;

                Win32::OLE->Option(CP => CP_UTF8);

                1')) {
            $logger->error("Failed to load Win32::OLE: $@") if $logger;
        }


        my $letter;
        if ($self->{path} !~ /^(\w):./) {
            $logger->error("Path parse error: ".$self->{path}) if $logger;
            return;
        }
        $letter = $1.':';


        my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

        if (!$WMIServices) {
            $logger->error(Win32::OLE->LastError()) if $logger;
            return;
        }

        foreach my $properties ( Win32::OLE::in(
                $WMIServices->InstancesOf('Win32_LogicalDisk'))) {

            next unless lc($properties->{Caption}) eq lc($letter);
            my $t = $properties->{FreeSpace};
            if ($t && $t =~ /(\d+)\d{6}$/) {
                $spaceFree = $1;
            }
        }
    } elsif ($OSNAME eq 'solaris') {
        my $dfFh;
        return unless -d $self->{path};
        if (open($dfFh, '-|', "df", '-b', $self->{path})) {
            foreach(<$dfFh>) {
                if (/^\S+\s+(\d+)\d{3}[^\d]/) {
                    $spaceFree = $1;
                }
            }
            close $dfFh
        } elsif ($logger) {
            $logger->error("Failed to exec df");
        }
    } else {
        my $dfFh;
        return unless -d $self->{path};
        if (open($dfFh, '-|', "df", '-Pk', $self->{path})) {
            foreach(<$dfFh>) {
                if (/^\S+\s+\S+\s+\S+\s+(\d+)\d{3}[^\d]/) {
                    $spaceFree = $1;
                }
            }
            close $dfFh
        } elsif ($logger) {
            $logger->error("Failed to exec df");
        }
    }

    if(!$spaceFree) {
	$logger->debug('$spaceFree is undef!') if $logger;
	$spaceFree=0;
    }

    print "Freespace on ".$self->{path}." : ".$spaceFree."\n";
    # 400MB Free, should be set by a config option
    return ($spaceFree < 2000);
}


1;
