package FusionInventory::Agent::Storage;
        
use strict;
use warnings;

use English qw(-no_match_vars);
use File::Glob ':glob';
use File::Path qw(make_path);
use Storable;

use FusionInventory::Logger;

sub new {
    my ($class, $params) = @_;

    if (!-d $params->{directory}) {
        make_path($params->{directory}, {error => \my $err});
        if (@$err) {
            die "Can't create $params->{directory}";
        }
    }

    if (! -w $params->{directory}) {
        die "Can't write in $params->{directory}";
    }

    my $self = {
        logger    => $params->{logger} || FusionInventory::Logger->new(),
        directory => $params->{directory}
    };
    bless $self, $class;

    return $self;
}

sub save {
    my ($self, $params) = @_;

    my $data = $params->{data};

    my $filePath = $self->_getFilePath();

    store ($data, $filePath) or warn;
}

sub restore {
    my ($self, $params ) = @_;

    my $module = $params->{module};

    my $filePath = $self->_getFilePath({
        module => $module,
    });

    if (-f $filePath) {
        return retrieve($filePath);
    }

    return {};
}

sub getDirectory {
    my ($self) = @_;

    return $self->{directory};
}

sub _getFilePath {
    my ($self, $params) = @_;

    my $module = $params->{module};

    my $path = 
        $self->{directory} .
        '/' . 
        $self->_getFileName({ module => $module }) .
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

1;
__END__

=head1 NAME

FusionInventory::Agent::Storage - A data serializer/deserializer

=head1 Description

This is the object used by the agent to ensure data persistancy between
invocations. Each data structure is saved in a file, whose name is automatically
determined according to object class name.

=head1 SYNOPSIS

  my $storage = FusionInventory::Agent::Storage->new({
      directory => '/tmp'
  });
  my $data = $storage->restore({
      module => "FusionInventory::Agent"
  });

  $data->{foo} = 'bar';

  $storage->save({ data => $data });

=head1 METHODS

=head2 new($params)

The constructor. The following parameters are allowed, as keys of the $params
hashref:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<directory>

The directory to use for storing data (mandatory)

=back

The directory will be automatically created if it doesn't already exist. The
constructor will die if the directory can't be created, or if it isn't writable.

=head2 save

Save given data structure. The following arguments are allowed:

=over

=item data

The data structure to save (mandatory).

=back

=head2 restore

Restore a saved data structure. The following arguments are allowed:

=over

=item module

The name of the module which saved the data structure (mandatory).

=back

=head2 getDirectory

Returns the underlying directory for this storage.
