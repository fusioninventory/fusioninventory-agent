package Ocsinventory::Compress;
# TODO I want to be able to send to the server uncompressed stream
use strict;

use File::Temp qw/ tempdir tempfile /;

sub new {
  my (undef, $params) = @_;

  my $self = {};

  my $logger = $self->{logger} = $params->{logger};


  eval{require Compress::Zlib};
  $self->{natif} = ($@)?0:1;

  my @tmpgzip;
  if ($self->{natif}) {
    $logger->debug ('Compress::Zlib is avalaible.');
  } elsif (@tmpgzip = `gzip -h>>/dev/null` && @tmpgzip) {
    $logger->debug ( # Today the sever only understands Zlib compressed data 
	'Compress::Zlib is not avalaible! The data will be compressed with
	gzip instead but won\'t be accepted by server prior 1.1'); # TODO is 1.1
	# the correct release for this feature?
      $self->{tmpdir} = tempdir( CLEANUP => 1 );
      mkdir $self->{tmpdir};
      if ( ! -d $self->{tmpdir} ) {
	$logger->fault("Failed to create the temp dir `$self->{tmpdir}'");
      }
  } else {
    $logger->fault ('I need the Compress::Zlib library or the gzip'.
    ' command to compress the data');
  }

  bless $self;
}

sub compress {
  my ($self, $content) = @_;

  if ($self->{natif}) {
    return Compress::Zlib::compress($content);
  }
# Else I use gzip directly

  my ($fh, $filename) = tempfile( DIR => $self->{tmpdir} );

  print $fh $content;
  close $fh;

  system ("gzip --best $filename");

#  print "filename ".$filename."\n"; 

  my $ret;
  open FILE, "<$filename.gz";
  $ret .= $_ foreach (<FILE>);
  close FILE;
  if ( ! unlink "$filename.gz" ) {
    $self->logger("Failed to remove `$filename.gz'");
  }
  $ret;
}

sub uncompress {
  my ($self,$data) = @_;

  if ($self->{natif}) {
    return Compress::Zlib::uncompress($data);
  }
# Else I use gzip directly
  my ($fh, $filename) = tempfile( DIR => $self->{tmpdir}, SUFFIX => '.gz' );

  print $filename."\n";
  print $fh $data;
  close $fh;

  open FILE, "<$filename";
  print foreach (<FILE>);
  close FILE;

  system ("gzip -d $filename");
  my ($uncompressed_filename) = $filename =~ /(.*)\.gz$/;

  my $ret;
  open FILE, "<$uncompressed_filename";
  $ret .= $_ foreach (<FILE>);
  close FILE;
  if ( ! unlink "$uncompressed_filename" ) {
    $self->logger("Failed to remove `$uncompressed_filename'");
  }
  $ret;
}
1;
