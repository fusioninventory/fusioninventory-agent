package Ocsinventory::Compress;
# TODO I want to be able to send to the server uncompressed stream

use File::Temp qw/ tempdir tempfile /;

sub new {
  my (undef, $params) = @_;

  my $self = {};

  my $logger = $self->{logger} = $params->{logger};

  # TODO: If Compress::Zlib is not avalaible
  # I'll emulate it by calling gzip
  # directly 
  eval{require Compress::Zlib};
  $self->{natif} = ($@)?0:1;

  if ($self->{natif}) {
    $logger->log ({
	level => 'debug',
	message => 'Compress::Zlib is avalaible.'
      });
  } else {
    $logger->log ({
	level => 'fault', # Today the sever only understands Zlib compressed data 
	message => 'Compress::Zlib is not avalaible! The data won\'t be accepted
	by the server. Please install the Compress-Zlib package and restard
	the agent.'
      });
  }

  bless $self;
}

sub compress {
  my $self = shift;

  if ($self->{natif}) {
    return Compress::Zlib::compress(@_);
  }
#
#  my $dir = tempdir( CLEANUP => 1 );
#  my ($fh, $filename) = tempfile( DIR => $dir );
#
#  print $filename."\n";
#  print $fh "toto";
#
#  close $fh;
#
#  open FILE, "<$filename";
#  print foreach (<FILE>);
#  close FILE;
#
#  system ("gzip $filename");
#
#  print "filename ".$filename."\n"; 
#
#  my $ret;
#  open FILE, "<$filename.gz";
#  $ret .= $_ foreach (<FILE>);
#  close FILE;
#
#  $ret;
}

sub uncompress {
  my ($self,$data) = @_;

  if ($self->{natif}) {
    return Compress::Zlib::uncompress($data);
  }
#
#  my $dir = tempdir( CLEANUP => 1 );
#  my ($fh, $filename) = tempfile( DIR => $dir, SUFFIX => '.gz' );
#
#  print $filename."\n";
#  print $fh $data;
#  close $fh;
#
#  open FILE, "<$filename";
#  print foreach (<FILE>);
#  close FILE;
#
#  print "filename ".$filename."\n"; 
#  my ($uncompressed_filename) = $filename =~ /(.*)\.gz$/;
#
#  print "uncompressed_filename ".$uncompressed_filename."\n"; 
#
#  system ("gzip -d $uncompressed_filename");
#
#  my $ret;
#  open FILE, "<$filename.gz";
#  $ret .= $_ foreach (<FILE>);
#  close FILE;
#
#  $ret;
}
1;
