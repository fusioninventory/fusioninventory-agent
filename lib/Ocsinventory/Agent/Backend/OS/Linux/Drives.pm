package Ocsinventory::Agent::Backend::OS::Linux::Drives;



use strict;
sub check {
  `which df 2>&1`;
  return if ($? >> 8)!=0;
  `df 2>&1`;
  return if ($? >> 8)!=0;
  1;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $free;
  my $filesystem;
  my $total;
  my $type;
  my $volumn;  

#Looking for mount points and disk space 
  for(`df -k`){
    if (/^Filesystem\s*/){next};
    if (!(/^\/.*/) && !(/^swap.*/)){next};

    if(/^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\n/){	
      $filesystem = $1;
      $total = sprintf("%i",($2/1024));	
      $free = sprintf("%i",($4/1024));
      $volumn = $6;

      $inventory->addDrives({
	  FREE => $free,
	  FILESYSTEM => $filesystem,
	  TOTAL => $total,
	  TYPE => $type,
	  VOLUMN => $volumn
	  })

    }


  }
}

1;
