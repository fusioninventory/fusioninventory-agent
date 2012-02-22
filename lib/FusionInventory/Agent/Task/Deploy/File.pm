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
        p2p                    => $params{data}->{p2p},
        p2p_retention_duration => $params{data}->{'p2p-retention-duration'},
        uncompress             => $params{data}->{'uncompress'},
        mirrors                => $params{data}->{mirrors},
        multiparts             => $params{data}->{multiparts},
        name                   => $params{data}->{name},
        sha512                 => $params{sha512},
        datastore              => $params{datastore},
        client                 => $params{client},
        logger                 => $params{logger}
    };

    bless $self, $class;

    return $self;
}

sub getPartFilePath {
    my ($self, $sha512, ) = @_;


    return unless $sha512 =~ /^(.)(.)(.{6})/;
    my $subFilePath = $1.'/'.$2.'/'.$3;

    my $filename = $1;
 
    my @locToCheck = File::Glob::glob($self->{datastore}->{path}.'/fileparts/shared/*');
    push @locToCheck, $self->{datastore}->{path}.'/fileparts/private';

    foreach my $loc (@locToCheck) {
        if (-f $loc.'/'.$subFilePath) {
            return $loc.'/'.$subFilePath;
        }
    }

    my $filePath = $self->{datastore}->{path}.'/fileparts/';
# filepart not found
    if ($self->{p2p}) {
        $filePath .= 'shared/';
# Compute a directory name that will be used to know
# if the file must be purge. We don't want a new directory
# everytime, so we use a 10h frame
        $filePath .= int(time/10000)*10000 + ($self->{p2p_retention_duration} * 60);
        $filePath .= '/'.$subFilePath;
    } else {
        $filePath .= 'private';
        $filePath .= '/'.$subFilePath;
    }

    return $filePath;
}

sub download {
    my ($self) = @_;

    die unless $self->{mirrors};

    my $datastore = $self->{datastore};

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

        MIRROR: foreach my $mirror (@$p2pHostList, @$mirrorList) {
            next unless $sha512 =~ /^(.)(.)/;
            my $sha512dir = $1.'/'.$1.$2.'/';

            $self->{logger}->debug($mirror.$sha512dir.$sha512);

            my $request;
            my $response;

            eval {
                alarm 1800;
                $request = HTTP::Request->new(GET => $mirror.$sha512dir.$sha512);
                $response = $self->{client}->request($request, $partFilePath);
                alarm 0;
            };

            if ($response && ($response->code == 200) && -f $partFilePath) {
                if ($self->_getSha512ByFile($partFilePath) eq $sha512) {
                    next MULTIPART;
                }
            }
# bad file, drop it
            unlink($partFilePath);
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
