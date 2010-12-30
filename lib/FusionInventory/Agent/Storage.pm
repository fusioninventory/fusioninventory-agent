package FusionInventory::Agent::Storage;
        
use strict;
use warnings;

use English qw(-no_match_vars);
use File::Glob ':glob';
use File::Path qw(make_path);
use Storable;

use FusionInventory::Agent::Logger;

sub new {
    my ($class, %params) = @_;

    my $self = {
        logger    => $params{logger} || FusionInventory::Agent::Logger->new(),
        directory => $params{directory}
    };

    if (!-d $params{directory}) {
        make_path($params{directory}, {error => \my $err});
        if (@$err) {
            my (undef, $message) = %{$err->[0]};
            $self->{logger}->error(
                "Can't create $params{directory}: $message"
            );
            die;
        }
    }

    if (! -w $params{directory}) {
        $self->{logger}->error(
            "Can't write in $params{directory}"
        );
        die;
    }

    bless $self, $class;

    return $self;
}

sub save {
    my ($self, %params) = @_;

    my $data = $params{data};
    my $idx = $params{idx};

    my $filePath = $self->_getFilePath(idx => $idx);

    store ($data, $filePath) or warn;
}

sub restore {
    my ($self, %params) = @_;

    my $module = $params{module};
    my $idx = $params{idx};

    my $filePath = $self->_getFilePath(
        module => $module,
        idx => $idx
    );

    return unless -f $filePath;

    return retrieve($filePath);
}

sub exists {
    my ($self, %params) = @_;

    my $module = $params{module};
    my $idx = $params{idx};

    my $filePath = $self->_getFilePath(
        module => $module,
        idx => $idx
    );

    return -f $filePath;
}

sub getDirectory {
    my ($self) = @_;

    return $self->{directory};
}

sub _getFilePath {
    my ($self, %params) = @_;

    my $idx = $params{idx};
    if ($idx && $idx !~ /^\d+$/) {
        die "[fault] idx must be an integer!\n";
    } 
    my $module = $params{module};

    my $path = 
        $self->{directory} .
        '/' . 
        $self->_getFileName(module => $module) .
        ($idx ? ".$idx" : "" ) .
        '.dump';

    return $path;
}

sub _getFileName {
    my ($self, %params) = @_;

    my $name;

    if ($params{module}) {
        $name = $params{module};
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
determined according to object class name. An optional index number can be used
to differentiate between usages.

=head1 SYNOPSIS

  my $storage = FusionInventory::Agent::Storage->new(
      directory => '/tmp'
  );
  my $data = $storage->restore({
      module => "FusionInventory::Agent"
  });

  $data->{foo} = 'bar';

  $storage->save({ data => $data });

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the $params
hash:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<directory>

The directory to use for storing data (mandatory)

=back

The directory will be automatically created if it doesn't already exist. The
constructor will die if the directory can't be created, or if it isn't writable.

=head2 save(%params)

Save given data structure. The following arguments are allowed:

=over

=item data

The data structure to save (mandatory).

=item idx

The index number (optional).

=back

=head2 restore(%params)

Restore a saved data structure. The following arguments are allowed:

=over

=item module

The name of the module which saved the data structure (mandatory).

=item idx

The index number (optional).

=back

=head2 exists(%params)

Returns true if a saved data structure exists. The following arguments are
allowed:

=over

=item module

The name of the module which saved the data structure (mandatory).

=item idx

The index number (optional).

=back

=head2 getDirectory

Returns the underlying directory for this storage.
