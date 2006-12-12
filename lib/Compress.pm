package Ocsinventory::Compress;

sub new {
  my (undef, $params) = @_;

  my $self = {};

  my $logger = $self->{logger} = $params->{logger};

  # If Compress::Zlib is not avalaible
  # I'll emulate it by calling gzip
  # directly
  eval{require Compress::Zlibb};
  $self->{natif} = ($@)?0:1;

  $logger->log ({
      level => 'debug',
      message => 'Compress::Zlib avalaible: '.$self->{natif}
    }); 

  bless $self;
}

sub compress {
  my $self = shift;

  if ($self->{natif}) {
    return Compress::Zlib::compress(@_);
  }

  if(!open F, "gzip -c $filename |") {
    $logger->log ({
	level => 'fault',
	message => 'Failed to launch gzip: '.$self->{natif}
      }); 
  }

  close F;
}

sub uncompress {
  my $self = shift;

  if ($self->{natif}) {
    return Compress::Zlib::uncompress(@_);
  }

  if(!open F, "gunzip -c $filename |") {
    $logger->log ({
	level => 'fault',
	message => 'Failed to launch gunzip: '.$self->{natif}
      }); 
  }


  close F;
}
1;
