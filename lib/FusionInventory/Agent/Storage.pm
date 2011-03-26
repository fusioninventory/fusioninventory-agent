package FusionInventory::Agent::Storage;
        
use strict;
use warnings;

use Config;
use English qw(-no_match_vars);
use File::Glob ':glob';
use File::Path qw(make_path);
use Storable;

my $lock :shared;

BEGIN {
    # threads and threads::shared must be loaded before
    # $lock is initialized
    if ($Config{usethreads}) {
        eval {
            require threads;
            require threads::shared;
        };
        if ($EVAL_ERROR) {
            print "[error]Failed to use threads!\n"; 
        }
    }
}

sub new {
    my ($class, $params) = @_;

    if (!-d $params->{directory}) {
        make_path($params->{directory}, {error => \my $err});
        if (@$err) {
            my (undef, $message) = %{$err->[0]};
            die "Can't create $params->{directory}: $message";
        }
    }

    if (! -w $params->{directory}) {
        die "Can't write in $params->{directory}";
    }

    my $self = {
        logger    => $params->{logger},
        directory => $params->{directory}
    };

    bless $self, $class;

    return $self;
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


    my $extension = '';
    if ($idx) {
        if ($idx !~ /^\d+$/) {
            $self->{logger}->fault("[fault] idx must be an integer!\n");
        } 
        $extension = '.'.$idx;
    }


    return $self->{directory}."/".$fileName.$extension.".dump";

}

sub save {
    my ($self, $params) = @_;

    my $data = $params->{data};
    my $idx = $params->{idx};

    lock($lock);

    my $filePath = $self->getFilePath({ idx => $idx });
#    print "[storage]save data in:". $filePath."\n";

    my $oldMask;

    if ($OSNAME ne 'MSWin32') {
        $oldMask = umask();
        umask(oct(77));
    }
    # TODO: restrict access to temp file under windows

    store ($data, $filePath) or warn;
    
    if ($OSNAME ne 'MSWin32') {
        umask $oldMask;
    }

}

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

    my $ret;
    if (-f $filePath) {
        eval {$ret = retrieve($filePath)};
    }
    $ret = {} unless $ret;

    return $ret;
}

sub remove {
    my ($self, $params) = @_;

    my $idx = $params->{idx};
    
    my $filePath = $self->getFilePath({ idx => $idx });
    #print "[storage] delete $filePath\n";

    if (!unlink($filePath)) {
        #print "[storage] failed to delete $filePath\n";
    }
}

sub removeAll {
    my ($self, $params) = @_;
    
    my $idx = $params->{idx};

    my $filePath = $self->getFilePath({ idx => $idx });
    #print "[storage] delete $filePath\n";

    if (!unlink($filePath)) {
        #print "[storage] failed to delete $filePath\n";
    }
}

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
__END__

=head1 NAME

FusionInventory::Agent::Storage - the light data storage API. Data will be
stored in a subdirectory in the 'vardir' directory. This subdirectory depends
on the caller module name.

=head1 SYNOPSIS

  my $storage = FusionInventory::Agent::Storage->new({
      directory => $directory
  });
  my $data = $storage->restore({
          module => "FusionInventory::Agent"
      });

  $data->{foo} = 'bar';

  $storage->save({ data => $data });

=head1 DESCRIPTION

This module is a wrapper for restore and save.
it called $inventory in general.

=head1 METHODS

=head2 new({ config => $config, target => $target })

Create the object

=head2 save({ data => $date, idx => $ref })

Save the reference.
$idx is an integer. You can use it if you want to save more than one file for the
module. This number will be added at the of the file.

=head2 restore({ module => $module, idx => $idx})

Returns a reference to the stored data. If $idx is defined, it will open this
substorage.

=head2 remove({ module => $module, idx => $idx })

Returns the files stored on the filesystem for the module $module or for the caller module.
If $idx is defined, only the submodule $idx will be removed.


=head2 removeAll({ module => $module, idx => $idx })

Deletes the files stored on the filesystem for the module $module or for the caller module.

=head2 removeSubDumps({ module => $module })

Deletes the sub files stored on the filesystem for the module $module or for the caller module.

