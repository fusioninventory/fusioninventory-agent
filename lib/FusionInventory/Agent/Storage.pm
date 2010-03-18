package FusionInventory::Agent::Storage;
        
use Storable;

use strict;
use warnings;


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

    my $config = $self->{config} = $params->{config};
    my $target = $self->{target} = $params->{target};

    $self->{vardir} = $target->{vardir};

    bless $self;
}

# Internal function, no POD doc
sub getFilePath {
    my ($self, $params ) = @_;

    my $target = $self->{target};
    my $config = $self->{config};

    my $module = $params->{module};
    my $idx = $params->{idx};

    my $fileName = $module || caller(1);
    $fileName =~ s/::/-/g; # Drop the ::
    # They are forbiden on Windows in file path

    my $dirName;
    if ($target) {
        $dirName = $target->{'vardir'};
    } elsif ($config) {
        $dirName = $config->{'basevardir'};
    } else {
        die;
    }


    my $extension = '';
    if ($idx) {
        if ($idx !~ /^\d+$/) {
            print "[fault] idx must be an integer!\n";
            die;
        } 
        $extension = '.'.$idx;
    }


    print $dirName."/".$fileName.$extension.".dump\n";
    return $dirName."/".$fileName.$extension.".dump";

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

    my $filePath = $self->getFilePath({ idx => $idx });
    print "[storage]save data in:". $filePath."\n";

    my $oldMask = umask();
    umask(077) or die "Can't restrict access to $filePath\n";
	store ($data, $filePath) or warn;
    umask($oldMask) or die "Can't restore old mask\n";

}

=item restore({ module => $module, idx => $idx})

Returns a reference to the stored data. If $idx is defined, it will open this
substorage.

=cut
sub restore {
    my ($self, $params ) = @_;

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

Returns the files stored on the filesystem for the module $module or for the caller module.

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

1;
