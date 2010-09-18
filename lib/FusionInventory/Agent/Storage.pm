package FusionInventory::Agent::Storage;
        
use strict;
use warnings;

use threads;
use threads::shared;

use English qw(-no_match_vars);
use File::Glob ':glob';
use Storable;

my $lock :shared;

sub new {
    my ($class, $params) = @_;

    my $self = {
        config => $params->{config},
        target => $params->{target}
    };
    bless $self, $class;

    return $self;
}

sub save {
    my ($self, $params) = @_;

    my $data = $params->{data};
    my $idx = $params->{idx};

    lock($lock);

    my $filePath = $self->_getFilePath({ idx => $idx });
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

    my $module = $params->{module};
    my $idx = $params->{idx};

    my $filePath = $self->_getFilePath({
        module => $module,
        idx => $idx
    });
    #print "[storage]restore data from: $filePath\n";

    if (-f $filePath) {
        return retrieve($filePath);
    }

    return {};
}

sub remove {
    my ($self, $params) = @_;

    my $idx = $params->{idx};
    
    my $filePath = $self->_getFilePath({ idx => $idx });
    #print "[storage] delete $filePath\n";

    if (!unlink($filePath)) {
        #print "[storage] failed to delete $filePath\n";
    }
}

sub removeAll {
    my ($self, $params) = @_;
    
    my $idx = $params->{idx};

    my $filePath = $self->_getFilePath({ idx => $idx });
    #print "[storage] delete $filePath\n";

    if (!unlink($filePath)) {
        #print "[storage] failed to delete $filePath\n";
    }
}

sub removeSubDumps {
    my ($self, $params) = @_;
   
    my $module = $params->{module};

    my $fileDir = $self->_getFileDir();
    my $fileName = $self->_getFileName({ module => $module });

    foreach my $file (bsd_glob("$fileDir/$fileName.*.dump")) {
        unlink($file) or warn "[error] Can't unlink $file\n";
    }
}

sub _getFilePath {
    my ($self, $params) = @_;

    my $target = $self->{target};
    my $config = $self->{config};

    my $idx = $params->{idx};
    if ($idx && $idx !~ /^\d+$/) {
        die "[fault] idx must be an integer!\n";
    } 
    my $module = $params->{module};

    my $path = 
        $self->_getFileDir() . 
        '/' . 
        $self->_getFileName({ module => $module }) .
        ($idx ? ".$idx" : "" ) .
        '.dump';

    return $path;
}

sub _getFileName {
    my ($self, $params) = @_;

    my $name;

    if ($params->{module}) {
        $name = $params->{module};
    } else {
        my $module;
        my $i = 0;
        while ($module = caller($i++)) {
            last if $module ne 'FusionInventory::Agent::Storage';
        }
        $name = $module;
    }

    # Drop colons, they are forbiden in Windows file path
    $name =~ s/::/-/g;

    return $name;
}

sub _getFileDir {
    my ($self, $params) = @_;

    my $dir = 
        $self->{target} ? $self->{target}->{vardir}     : 
        $self->{config} ? $self->{config}->{basevardir} : 
                          undef;

    return $dir;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Storage - A data serializer/deserializer

=head1 Description

This is the object used by the agent to save data in the variable data
directory, to ensure persistancy between invocations.

Each data structure is saved in a different subdirectory, based on invocant
module name. An optional index number can be used to differentiate between
consecutives usages.

=head1 SYNOPSIS

  my $storage = FusionInventory::Agent::Storage->new({
      target => {
          vardir => $ARGV[0],
      }
  });
  my $data = $storage->restore({
          module => "FusionInventory::Agent"
      });

  $data->{foo} = 'bar';

  $storage->save({ data => $data });

=head1 METHODS

=head2 new($params)

The constructor. The following named parameters are allowed:

=over

=item config (mandatory)

=item target (mandatory)

=back

=head2 save

Save given data structure. The following arguments are allowed:

=over

=item data

The data structure to save (mandatory).

=item idx

The index number (optional).

=back

=head2 restore

Restore a saved data structure. The following arguments are allowed:

=over

=item module

The name of the module which saved the data structure (mandatory).

=item idx

The index number (optional).

=back

=head2 remove

Delete the file containing a seralized data structure for a given module. The
following arguments are allowed:

=over

=item module

The name of the module which saved the data structure (mandatory).

=item idx

The index number (optional).

=back

=head2 removeAll

Delete the files containing seralized data structure for all modules. The
following arguments are allowed:

=over

=item idx

The index number (optional).

=back

=head2 removeSubDumps

Delete all files containing seralized data structure for a given module. The
following arguments are allowed:

=over

=item module

The name of the module which saved the data structure (mandatory).

=back
