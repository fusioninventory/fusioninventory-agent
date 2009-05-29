package Ocsinventory::Agent::Backend::OS::Linux::Drives;

use strict;
sub check {
  return unless can_run ("df");
  my $df = `df -TP`;
  return 1 if $df =~ /\w+/;
  0
}

sub getSerial {
  my ($type, $volume) = @_;

  my $serial;

  return $serial;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  foreach(`df -TP`) { # TODO retrive error
    my $createdate;
    my $free;
    my $filesystem;
    my $total;
    my $type;
    my $volumn;
    my $serial;

    if(/^(\S+)\s+(\S+)\s+(\S+)\s+(?:\S+)\s+(\S+)\s+(?:\S+)\s+(\S+)\n/){
      $free = sprintf("%i",($4/1024));
      $filesystem = $5;
      $total = sprintf("%i",($3/1024));
      $type = $2;
      $volumn = $1;

# no virtual FS
      next if ($type =~ /^(tmpfs|usbfs|proc|devpts|devshm|udev)$/);
      next if ($filesystem =~ /^(tmpfs)$/);

      if ($type =~ /^ext(2|3|4)/ && can_run('dumpe2fs')) {
        foreach (`dumpe2fs -h $volumn 2> /dev/null`) {
          if (/Filesystem UUID:\s+(\S+)/) {
            $serial = $1;
          } elsif (/Filesystem created:\s+(\S+.*)/) {
            $createdate = $1;
	  }
        }
      } elsif ($type =~ /^xfs$/ && can_run('xfs_db')) {
        foreach (`xfs_db -r -c uuid $volumn`) {
          if (/^UUID =\s+(\S+)/) {
            $serial = $1;
            last;
          }
        }
      }


      $inventory->addDrives({
          CREATEDATE => $createdate,
	  FREE => $free,
	  FILESYSTEM => $filesystem,
	  TOTAL => $total,
	  TYPE => $type,
	  VOLUMN => $volumn,
	  SERIAL => $serial
	})
    }
  }
}

1;
