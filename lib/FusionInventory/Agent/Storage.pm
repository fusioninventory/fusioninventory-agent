package FusionInventory::Agent::Storage;
        
use Storable;

use strict;
use warnings;


use Data::Dumper;

sub new {
    my ( undef, $params ) = @_;

    my $self = {};

    my $config = $self->{config} = $params->{config};
    my $target = $self->{target} = $params->{target};

    $self->{vardir} = $target->{vardir};

    bless $self;
}

sub getFilePath {
    my ($self, $module) = @_;

    my $target = $self->{target};
    my $config = $self->{config};

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
    return $dirName."/".$fileName.".dump";

}


sub save {
    my ($self, $data) = @_;

    my $filePath = $self->getFilePath();
    #print "[storage]save data in:". $filePath."\n";

	store ($data, $filePath) or warn;

}

sub restore {
    my ($self, $module) = @_;

    my $filePath = $self->getFilePath($module);
    #print "[storage]restore data from: $filePath\n";

    if (-f $filePath) {
        return retrieve($filePath);
    }

    return {};
}

sub remove {
    my ($self, $module) = @_;
    
    my $filePath = $self->getFilePath();
    #print "[storage] delete $filePath\n";

    if (!unlink($filePath)) {
        #print "[storage] failed to delete $filePath\n";
    }
}

1;
