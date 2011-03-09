package FusionInventory::Agent::Task::Deploy::File;

use strict;
use warnings;

use Data::Dumper;
use Digest::SHA;
use LWP::Simple;

sub new {
    my (undef, $params) = @_;

    my $self = $params->{data};
    $self->{sha512} = $params->{sha512};
    $self->{datastore} = $params->{datastore};

    die unless $self->{datastore};
    die unless $self->{sha512};

    foreach my $sha512 (keys %{$params->{files}}) {
        print $sha512."\n";
    }

    bless $self;
}

sub download {
    my ($self) = @_;

    die unless $self->{mirror};

    my $datastore = $self->{datastore};

    foreach (@{$self->{mirror}}) {
        print Dumper($_);
    }

    my $basedir = $self->getBaseDir();

MULTIPART: foreach (@{$self->{multipart}}) {
        my ($file, $sha512) =  %$_;

        my $filePath  = $basedir.'/'.$file;

        foreach my $mirror (@{$self->{mirror}}) {
            print("$mirror$file, $filePath\n");
            getstore($mirror.$file, $filePath);
            if (-f $filePath && _getSha512ByFile($filePath) eq $sha512) {
                print $filePath." retrieved\n";
                next MULTIPART;
            }
        }
    }

}

sub exists {
    my ($self) = @_;

    my $datastore = $self->{datastore};
print Dumper($self);
    my $path = $datastore->getPathBySha512($self->{sha512});

    my $isOk = 1;
    foreach (@{$self->{multipart}}) {
        my ($file, $sha512) =  %$_;

        my $filePath  = $path.'/'.$file;

        print $file." → ".$sha512."\n";

        if (!-f $filePath) {
                $isOk = 0;
        } elsif (_getSha512ByFile($filePath) ne $sha512) {
                unlink($filePath);
                $isOk = 0;
        }
    }
    return $isOk;
}

sub _getSha512ByFile {
    my ($filePath) = @_;

    my $sha = Digest::SHA->new('512');

    $sha->addfile($filePath, 'b');

    return $sha->hexdigest;
}

sub getBaseDir {
    my ($self) = @_;

    return $self->{datastore}->getPathBySha512($self->{sha512});
}

sub validateFileByPath {
    my ($self, $filePath) = @_;


    if (-f $filePath) {
        my $t = _getSha512ByFile($filePath);

        if (_getSha512ByFile($filePath) eq $self->{sha512}) {
            return 1;
        }
    }

    return 0;
}


1;
