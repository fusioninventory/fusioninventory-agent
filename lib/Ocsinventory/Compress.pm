package Ocsinventory::Compress;
use strict;

use File::Temp qw/ tempdir tempfile /;

sub new {
  my (undef, $params) = @_;

  my $self = {};

  my $logger = $self->{logger} = $params->{logger};


  eval{require Compress::Zlib;};
  $self->{mode} = 'natif' unless $@;

  chomp(my $gzippath=`which gzip 2>/dev/null`);
  if ($self->{mode} eq 'natif') {
    $logger->debug ('Compress::Zlib is available.');
  } elsif (-x $gzippath) {
    $logger->debug (
	'Compress::Zlib is not available! The data will be compressed with
	gzip instead but won\'t be accepted by server prior 1.02');
      $self->{mode} = 'gzip';
      $self->{tmpdir} = tempdir( CLEANUP => 1 );
      mkdir $self->{tmpdir};
      if ( ! -d $self->{tmpdir} ) {
	$logger->fault("Failed to create the temp dir `$self->{tmpdir}'");
      }
  } else {
    $self->{mode} = 'deflated';
    $logger->debug ('I need the Compress::Zlib library or the gzip'.
    ' command to compress the data - The data will be sent uncompressed
    but won\'t be accepted by server prior 1.02');
  }

  bless $self;
}

sub compress {
  my ($self, $content) = @_;
  my $logger = $self->{logger};

# native mode (zlib)
  if ($self->{mode} eq 'natif') {
    return Compress::Zlib::compress($content);
  }
# gzip mode
  elsif($self->{mode} eq 'gzip'){
    my ($fh, $filename) = tempfile( DIR => $self->{tmpdir} );
    print $fh $content;
    close $fh;

    system ("gzip --best $filename > /dev/null");

#  print "filename ".$filename."\n"; 

    my $ret;
    open FILE, "<$filename.gz";
    $ret .= $_ foreach (<FILE>);
    close FILE;
    if ( ! unlink "$filename.gz" ) {
      $logger->debug("Failed to remove `$filename.gz'");
    }
    return $ret;
  }
# No compression available
  elsif($self->{mode} eq 'deflated'){
    return $content;
  }
}

sub uncompress {
  my ($self,$data) = @_;
  my $logger = $self->{logger};
# Native mode
  if ($self->{mode} eq 'natif') {
    return Compress::Zlib::uncompress($data);
  }
  elsif($self->{mode} eq 'gzip'){
# Gzip mode
    my ($fh, $filename) = tempfile( DIR => $self->{tmpdir}, SUFFIX => '.gz' );
    
    print $fh $data;
    close $fh;
  
    system ("gzip -d $filename");
    my ($uncompressed_filename) = $filename =~ /(.*)\.gz$/;
  
    my $ret;
    open FILE, "<$uncompressed_filename";
    $ret .= $_ foreach (<FILE>);
    close FILE;
    if ( ! unlink "$uncompressed_filename" ) {
      $logger->debug("Failed to remove `$uncompressed_filename'");
    }
    return $ret;
  }
# No compression available
  elsif($self->{mode} eq 'deflated'){
  	return $data;
  }
}
1;
