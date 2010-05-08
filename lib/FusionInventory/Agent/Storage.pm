package FusionInventory::Agent::Storage;
        
use Storable;

use strict;
use warnings;

use Config;

use File::Glob ':glob';

my $lock :shared;

use Data::Dumper;

=head1 NAME

FusionInventory::Agent::Storage - the light data storage API. Data will be
stored in a subdirectory in the 'vardir' directory. This subdirectory depends
on the caller module name.

=head1 SYNOPSIS

  my $storage = new FusionInventory::Agent::Storage({
      target => {
          vardir => $ARGV[0],
      }
  });
  my $data = $storage->restore({
          module => "FusionInventory::Agent"
      });

  $data->{foo} = 'bar';

  $storage->save({ data => $data });

=head1 DESCRIPTION

This module is a wrapper for restore and save.
it called $inventory in general.

=over 4

=item new({ config => $config, target => $target })

Create the object

=cut
sub new {
    my ( undef, $params ) = @_;

    my $self = {};

    if ($Config{usethreads}) {
        if (!(eval "use threads;1;" && eval "use threads::shared;1;")) {
            print "[error]Failed to use threads!\n";
        }
    }

    my $config = $self->{config} = $params->{config};
    my $target = $self->{target} = $params->{target};

    $self->{vardir} = $target->{vardir};

    bless $self;
}

sub getFileName {
    my ($self, $params ) = @_;

    my $module = $params->{module};


    my $callerModule;
    my $i = 0;
    while ($callerModule = caller($i++)) {
        last if $callerModule ne 'FusionInventory::Agent::Storage';
    }

    my $fileName = $module || $callerModule;
    $fileName =~ s/::/-/g; # Drop the ::
    # They are forbiden on Windows in file path


    return $fileName;
}

# Internal function, no POD doc
sub getFilePath {
    my ($self, $params ) = @_;

    my $target = $self->{target};
    my $config = $self->{config};

    my $idx = $params->{idx};
    my $module = $params->{module};

    my $fileName = $self->getFileName({
        module => $module
    });


    my $dirName = $self->getFileDir();

    my $extension = '';
    if ($idx) {
        if ($idx !~ /^\d+$/) {
            print "[fault] idx must be an integer!\n";
            die;
        } 
        $extension = '.'.$idx;
    }


    return $dirName."/".$fileName.$extension.".dump";

}


sub getFileDir {
    my ($self, $params ) = @_;

    my $target = $self->{target};
    my $config = $self->{config};

    my $module = $params->{module};
    my $idx = $params->{idx};

    my $dirName;
    if ($target) {
        $dirName = $target->{'vardir'};
    } elsif ($config) {
        $dirName = $config->{'basevardir'};
    } else {
        die;
    }

    return $dirName;

}



=item save({ data => $date, idx => $ref })

Save the reference.
$idx is an integer. You can use if if you want to save more than one file for the
module. This number will be add at the of the file

=cut
sub save {
    my ($self, $params) = @_;

    my $data = $params->{data};
    my $idx = $params->{idx};

    lock($lock);

    my $filePath = $self->getFilePath({ idx => $idx });
#    print "[storage]save data in:". $filePath."\n";

    my $isWindows = $^O =~ /^MSWin/;
    my $oldMask = umask();

    if (!$isWindows) {
        my $wantedUmask = "077";
        umask(oct($wantedUmask));
        my $currentUmask = sprintf "%lo", umask() & 07777;
        if ($currentUmask != $wantedUmask) {
            die "Failed to set umask $wantedUmask ($currentUmask)";
        }
    } else {
        print "TODO, restrict access to temp file!\n";
}

	store ($data, $filePath) or warn;
    
    if (!$isWindows) {
        umask($oldMask) or die "Can't restore old mask\n";
    }

}

=item restore({ module => $module, idx => $idx})

Returns a reference to the stored data. If $idx is defined, it will open this
substorage.

=cut
sub restore {
    my ($self, $params ) = @_;

    if ($params && ref($params) ne 'HASH') {
        my ($package, $filename, $line) = caller;
        print "[error]$package use a deprecated API for Storage. Please\n";
        print "[error]Please upgrade it or remove $filename\n";
    }
    my $module = $params->{module};
    my $idx = $params->{idx};

    my $filePath = $self->getFilePath({
            module => $module,
            idx => $idx
    });
    #print "[storage]restore data from: $filePath\n";

    if (-f $filePath) {
        return retrieve($filePath);
    }

    return {};
}

=item remove({ module => $module, idx => $idx })

Returns the files stored on the filesystem for the module $module or for the caller module.
If $idx is defined, only the submodule $idx will be removed.

=cut
sub remove {
    my ($self, $params) = @_;

    my $idx = $params->{idx};
    
    my $filePath = $self->getFilePath({ idx => $idx });
    #print "[storage] delete $filePath\n";

    if (!unlink($filePath)) {
        #print "[storage] failed to delete $filePath\n";
    }
}

=item removeAll({ module => $module, idx => $idx })

Deletes the files stored on the filesystem for the module $module or for the caller module.

=cut
sub removeAll {
    my ($self, $params) = @_;
    
    my $idx = $params->{idx};

    my $filePath = $self->getFilePath({ idx => $idx });
    #print "[storage] delete $filePath\n";

    if (!unlink($filePath)) {
        #print "[storage] failed to delete $filePath\n";
    }
}

=item removeSubDumps({ module => $module })

Deletes the sub files stored on the filesystem for the module $module or for the caller module.

=cut
sub removeSubDumps {
    my ($self, $params) = @_;
   
    my $module = $params->{module};

    my $fileDir = $self->getFileDir();
    my $fileName = $self->getFileName({ module => $module });

    foreach my $file (bsd_glob("$fileDir/$fileName.*.dump")) {
        unlink($file) or warn "[error] Can't unlink $file\n";
    }
}


1;
