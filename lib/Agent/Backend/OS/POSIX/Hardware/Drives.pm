package Ocsinventory::Agent::Backend::OS::POSIX::Hardware::Drives;
# TODO: move this in Linux if df output is not standard(i think so)
use strict;
sub check {
  my $df = `df -TPl`;
  return 1 if $df =~ /\w+/;
  0
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my @drives = `df -TPl`;
  shift @drives; # don't read the first line
  foreach(@drives) {
    if(/^(\S+)\s+(\S+)\s+(\S+)\s+(?:\S+)\s+(\S+)\s+(?:\S+)\s+(\S+)/){
# no virtual FS
      next if ($1 =~ /^(udev|devshm)$/);
      next if ($2 =~ /^(tmpfs|usbfs|proc|devpts|devshm)$/);

      $inventory->addDrives ({
	  'FILESYSTEM'    => $2,
	  'FREE'          => sprintf("%i",($4/1024)),
	  'TOTAL'         => sprintf("%i",($3/1024)),
	  'TYPE'          => $1,
	  'VOLUMN'        => $5,
	});
    }
  }
}

1;
