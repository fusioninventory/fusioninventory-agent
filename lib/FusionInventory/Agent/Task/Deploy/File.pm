package FusionInventory::Agent::Task::Deploy::File;

use strict;
use warnings;

use Digest::SHA;
use File::Basename;
use File::Path qw(mkpath);
use File::Glob;
use HTTP::Request;

sub new {
    my ($class, %params) = @_;

    die "no datastore parameter" unless $params{datastore};
    die "no sha512 parameter" unless $params{sha512};

    my $self = {
        p2p                => $params{data}->{p2p},
        retention_duration => $params{data}->{'p2p-retention-duration'} || 60 * 24 * 3,
        uncompress         => $params{data}->{uncompress},
        mirrors            => $params{data}->{mirrors},
        multiparts         => $params{data}->{multiparts},
        name               => $params{data}->{name},
        sha512             => $params{sha512},
        datastore          => $params{datastore},
        client             => $params{client},
        logger             => $params{logger}
    };

    bless $self, $class;

    return $self;
}

sub getPartFilePath {
    my ($self, $sha512) = @_;

    return unless $sha512 =~ /^(.)(.)(.{6})/;
    my $subFilePath = $1.'/'.$2.'/'.$3;

    my @storageDirs =
        File::Glob::glob($self->{datastore}->{path}.'/fileparts/shared/*'),
        File::Glob::glob($self->{datastore}->{path}.'/fileparts/private/*');

    foreach my $dir (@storageDirs) {
        if (-f $dir.'/'.$subFilePath) {
            return $dir.'/'.$subFilePath;
        }
    }

    my $filePath = $self->{datastore}->{path}.'/fileparts/';
# filepart not found
    if ($self->{p2p}) {
        $filePath .= 'shared/';
    } else {
        $filePath .= 'private/';
    }

# Compute a directory name that will be used to know
# if the file must be purge. We don't want a new directory
# everytime, so we use a 10h frame
    $filePath .= int(time/10000)*10000 + ($self->{retention_duration} * 60);
    $filePath .= '/'.$subFilePath;

    return $filePath;
}

sub download {
    my ($self) = @_;

    die unless $self->{mirrors};

    my $mirrorList =  $self->{mirrors};


    my $p2pHostList;

MULTIPART: foreach my $sha512 (@{$self->{multiparts}}) {
        my $partFilePath = $self->getPartFilePath($sha512);
        File::Path::mkpath(dirname($partFilePath));
        if (-f $partFilePath) {
                next MULTIPART if $self->_getSha512ByFile($partFilePath) eq $sha512;
        }

        eval {
            if ($self->{p2p} && (ref($p2pHostList) ne 'ARRAY') && FusionInventory::Agent::Task::Deploy::P2P->require) {
                $p2pHostList = FusionInventory::Agent::Task::Deploy::P2P::findPeer(62354, $self->{logger});
            }
        };
        $self->{logger}->debug("failed to enable P2P: $@") if $@;


        my $lastGood;
        my %remote = (p2p => $p2pHostList, mirror => $mirrorList);
        foreach my $remoteType (qw/p2p mirror/)  {
            foreach my $mirror ($lastGood, @{$remote{$remoteType}}) {
                next unless $mirror;

                next unless $sha512 =~ /^(.)(.)/;
                my $sha512dir = $1.'/'.$1.$2.'/';

                $self->{logger}->debug($mirror.$sha512dir.$sha512);

                my $request = HTTP::Request->new(GET => $mirror.$sha512dir.$sha512);
                my $response = $self->{client}->request($request, $partFilePath);

                if ($response && ($response->code == 200) && -f $partFilePath) {
                    if ($self->_getSha512ByFile($partFilePath) eq $sha512) {
                        $lastGood = $mirror if $remoteType eq 'p2p';
                        next MULTIPART;
                    }
                    $self->{logger}->debug("sha512 failure: $sha512");
                }
    # bad file, drop it
                unlink($partFilePath);
            }
        }
    }

}

sub filePartsExists {
    my ($self) = @_;

    foreach my $sha512 (@{$self->{multiparts}}) {

        my $filePath  = $self->getPartFilePath($sha512);
        return 0 unless -f $filePath;

    }
    return 1;
}

sub _getSha512ByFile {
    my ($self, $filePath) = @_;

    my $sha = Digest::SHA->new('512');

    my $sha512;
    eval {
        $sha->addfile($filePath, 'b');
        $sha512 = $sha->hexdigest;
    };
    $self->{logger}->debug("SHA512 failure: $@") if $@;

    return $sha512;
}

sub validateFileByPath {
    my ($self, $filePath) = @_;


    if (-f $filePath) {
        if ($self->_getSha512ByFile($filePath) eq $self->{sha512}) {
            return 1;
        }
    }

    return 0;
}


1;
