package FusionInventory::Agent::Task::Deploy::Datastore::WorkDir;

use strict;
use warnings;

use Data::Dumper;
use File::Path qw(make_path);
use Archive::Extract;

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

        print "Building finale file: `$finalFilePath'";

        print  "final file: ".$finalFilePath."\n";

        my $fh;
        if (!open($fh, ">$finalFilePath")) {
            print "Failed to open ".$finalFilePath.": $!";
            return;
        }
        binmode($fh);

        foreach my $part (@{$file->{multipart}}) {
            my ($filename, $sha512) = %$part;
            my $partFilePath = $file->getBaseDir().'/'.$filename;
            if (! -f $partFilePath) {
                print "Missing multipart element: `$partFilePath'\n";
            }

            my $part;
            if (!open($part, "<$partFilePath")) {
                print "Failed to open: `$partFilePath'\n";
            } else {
                binmode($part);
                my $buf;
                while(read($part, $buf, 1024)) {
                    print $fh $buf;
                }
                close $part;
            }
        }
        close($fh);

        if (!$file->validateFileByPath($finalFilePath)) {
            print "Failed to construct the final file.\n";
        }

    }


    foreach my $file (@{$self->{files}}) {
        my $finalFilePath = $self->{path}.'/'.$file->{name};

        $Archive::Extract::DEBUG=1;
        if ($file->{uncompress}) {
            print "→".$finalFilePath."\n";
            my $ae = Archive::Extract->new( archive => $finalFilePath );
            $ae->type("tgz");
            if (!$ae->extract( to => $self->{path} )) {
                print "Failed to extract `$finalFilePath'\n";
            }

            unlink($finalFilePath);
        }
    }
    print $self->{path}."\n";

}

1;
