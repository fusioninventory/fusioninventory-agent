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

    bless $self;
}

sub download {
    my ($self) = @_;

    die unless $self->{mirrors};

    my $datastore = $self->{datastore};

    my $basedir = $self->getBaseDir();

MULTIPART: foreach my $sha512 (@{$self->{multiparts}}) {
        my $filePath  = $basedir.'/'.$sha512;

        foreach my $mirror (@{$self->{mirrors}}) {
            print "::".$mirror.$sha512."\n";
            getstore($mirror.$sha512, $filePath);
            if (-f $filePath) {
                if (_getSha512ByFile($filePath) eq $sha512) {
#                print "getstore : $mirror$file, $filePath:  ok\n";
                    next MULTIPART;
                } else {
                    return;
                    #print "getstore : $mirror$file, $filePath: ko (invalide SHA) \n"._getSha512ByFile($filePath)."\n\n$sha512\n";
                    #die;
                }
            } else {
                return;
                #print "getstore : $mirror$file, $filePath:  ko, not found\n";
            }
        }
    }

}

sub exists {
    my ($self) = @_;

    my $datastore = $self->{datastore};

    my $path = $datastore->getPathBySha512($self->{sha512});

    my $isOk = @{$self->{multiparts}}?1:0;
    foreach my $sha512 (@{$self->{multiparts}}) {

        my $filePath  = $path.'/'.$sha512;

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
