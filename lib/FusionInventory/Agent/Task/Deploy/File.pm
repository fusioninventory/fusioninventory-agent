package FusionInventory::Agent::Task::Deploy::File;

use strict;
use warnings;

use File::Find;
use Data::Dumper;
use Digest::SHA;
use LWP::Simple;
use File::Basename;
use File::Path qw(make_path);

sub new {
    my (undef, $params) = @_;

    my $self = $params->{data};
    $self->{sha512} = $params->{sha512};
    $self->{datastore} = $params->{datastore};

    die unless $self->{datastore};
    die unless $self->{sha512};

    bless $self;
}

sub getPartFilePath {
    my ($self, $sha512, ) = @_;

    my $filePath  = $self->{datastore}->{path}.'/fileparts/';
    if (-d $filePath) {
        find({
            wanted => sub {
                return unless -f;
                return unless basename($_) eq $sha512;
                $filePath = $File::Find::name;
                return;
            },
            no_chdir => 1
        }, $filePath);
    }

    return $filePath if -f $filePath;

    if ($self->{p2p}) {
        $filePath .= 'shared/';
        $filePath .= time + ($self->{'p2p-retention-duration'} * 60);
        $filePath .= '/';
    } else {
        $filePath .= 'private/';
    }

    return unless $sha512 =~ /^(.)(.)/;

    $filePath .= $1.'/'.$1.$2.'/';

    $filePath .= $sha512;

    return $filePath;
}

sub download {
    my ($self) = @_;

    die unless $self->{mirrors};

    my $datastore = $self->{datastore};

    my $mirrorList =  $self->{mirrors};


use Data::Dumper;
print Dumper($self->{mirrors});
print "p2p: "."\n";

   my $p2pHostList;
   use Data::Dumper;

MULTIPART: foreach my $sha512 (@{$self->{multiparts}}) {
        my $partFilePath = $self->getPartFilePath($sha512);
        File::Path::make_path(dirname($partFilePath));
        if (-f $partFilePath) {
                next MULTIPART if _getSha512ByFile($partFilePath) eq $sha512;
        }

        if ($self->{p2p} && (ref($p2pHostList) ne 'ARRAY') && FusionInventory::Agent::Task::Deploy::P2P->require) {
            $p2pHostList = FusionInventory::Agent::Task::Deploy::P2P::findPeer(62354);
        }

        MIRROR: foreach my $mirror (@$p2pHostList, @$mirrorList) {
            next unless $sha512 =~ /^(.)(.)/;
            my $sha512dir = $1.'/'.$1.$2.'/';

            print $mirror.$sha512dir.$sha512."\n";
            my $rc = getstore($mirror.$sha512dir.$sha512, $partFilePath);

            if (is_success($rc) && -f $partFilePath) {
                if (_getSha512ByFile($partFilePath) eq $sha512) {
                print "getstore : $partFilePath:  ok\n";
                    next MULTIPART;
                }
            }
        }
    }

}

sub filePartsExists {
    my ($self) = @_;

    my $datastore = $self->{datastore};

    my $isOk = 1;
    foreach my $sha512 (@{$self->{multiparts}}) {

        my $filePath  = $self->getPartFilePath($sha512);

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
