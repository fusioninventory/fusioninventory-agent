package FusionInventory::Agent::Task::Deploy::Datastore::WorkDir;

use strict;
use warnings;

use Data::Dumper;
use File::Path qw(make_path);
use Archive::Extract;
use Compress::Zlib;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{path} = $params->{path};
    $self->{files} = [];

    bless $self;
}

sub addFile {
    my ($self, $file) = @_;

    push @{$self->{files}}, $file;



}

sub prepare {
    my ($self) = @_;

    foreach my $file (@{$self->{files}}) {
        my $finalFilePath = $self->{path}.'/'.$file->{name};

        my $fh;
        if (!open($fh, ">$finalFilePath")) {
            print "Failed to open ".$finalFilePath.": $!\n";
            return;
        }
        binmode($fh);
        foreach my $sha512 (@{$file->{multiparts}}) {
            my $partFilePath = $file->getPartFilePath($sha512);
            if (! -f $partFilePath) {
                print "Missing multipart element: `$partFilePath'\n";
            }

            my $part;
            my $buf;
            if ($part = gzopen($partFilePath, 'rb')) {

                print "reading ".$sha512."\n";
                while ($part->gzread($buf, 1024)) {
                    print $fh $buf;
                }
                $part->gzclose;
            } else {
                print "Failed to open: `$partFilePath'\n";
            }
        }
        close($fh);

        if (!$file->validateFileByPath($finalFilePath)) {
            print "Failed to construct the final file.: $finalFilePath\n";
            return;
        }

    }


    foreach my $file (@{$self->{files}}) {
        my $finalFilePath = $self->{path}.'/'.$file->{name};

        $Archive::Extract::DEBUG=1;
        if ($file->{uncompress}) {
            my $ae = Archive::Extract->new( archive => $finalFilePath );
            if (!$ae->extract( to => $self->{path} )) {
                print "Failed to extract `$finalFilePath'\n";
                return;
            }

            unlink($finalFilePath);
        }
    }

    return 1;
}

1;
