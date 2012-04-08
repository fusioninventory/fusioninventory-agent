package FusionInventory::Agent::Task::Deploy::Datastore::WorkDir;

use strict;
use warnings;

use Archive::Extract;
use Compress::Zlib;
use English qw(-no_match_vars);
use File::Path qw(mkpath);

sub new {
    my ($class, %params) = @_;

    my $self = {
        path  => $params{path},
        logger => $params{logger},
        files => []
    };

    if (! -d $self->{path}) {
        die "path `".$self->{path}."' doesn't exit.";
    }


    bless $self, $class;
}

sub addFile {
    my ($self, $file) = @_;

    push @{$self->{files}}, $file;



}

sub prepare {
    my ($self) = @_;

    my $logger = $self->{logger};

    foreach my $file (@{$self->{files}}) {
        my $finalFilePath = $self->{path}.'/'.$file->{name};

        my $fh;
        if (!open($fh, '>', $finalFilePath)) {
            $logger->debug("Failed to open '$finalFilePath': $ERRNO");
            return;
        }
        binmode($fh);
        foreach my $sha512 (@{$file->{multiparts}}) {
            my $partFilePath = $file->getPartFilePath($sha512);
            if (! -f $partFilePath) {
                $logger->debug("Missing multipart element '$partFilePath'");
            }

            my $part;
            my $buf;
            if ($part = gzopen($partFilePath, 'rb')) {

                $logger->debug("reading $sha512");
                while ($part->gzread($buf, 1024) > 0) {
                    print $fh $buf;
                }
                $part->gzclose;
            } else {
                $logger->info("Failed to open '$partFilePath'");
            }
        }
        close($fh);

        if (!$file->validateFileByPath($finalFilePath)) {
            $logger->info("Failed to construct the final file.: $finalFilePath");
            return;
        }

    }


    foreach my $file (@{$self->{files}}) {
        my $finalFilePath = $self->{path}.'/'.$file->{name};

        $Archive::Extract::DEBUG=1;
        if ($file->{uncompress}) {
            my $ae = Archive::Extract->new( archive => $finalFilePath );
            if (!$ae) {
                $logger->info("Failed to create Archive::Extract object");
            } elsif (!$ae->extract( to => $self->{path} )) {
                $logger->debug("Failed to extract '$finalFilePath'");
            }
            # We ignore failure here because one my have activated the
            # extract flag on common file and this should be harmless
        }
    }

    return 1;
}

1;
