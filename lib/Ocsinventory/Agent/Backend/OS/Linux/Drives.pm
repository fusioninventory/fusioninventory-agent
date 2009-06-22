package Ocsinventory::Agent::Backend::OS::Linux::Drives;

use strict;
sub check {
  return unless can_run ("df");
  my $df = `df -TP`;
  return 1 if $df =~ /\w+/;
  0
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my %months = (
    Jan => 1,
    Fev => 2,
    Mar => 3,
    Apr => 4,
    May => 5,
    Jun => 6,
    Aug => 7,
    Sep => 8,
    Nov => 9,
    Dec => 12,
  );

  foreach(`df -TP`) { # TODO retrive error
    my $createdate;
    my $free;
    my $filesystem;
    my $label;
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
          } elsif (/Filesystem created:\s+\w+ (\w+) (\d+) ([\d:]+) (\d{4})$/) {
            $createdate = $4.'/'.$months{$1}.'/'.$2.' '.$3;
          } elsif (/Filesystem volume name:\s*(\S.*)/) {
            $label = $1 unless $1 eq '<none>';
          }
        }
      } elsif ($type =~ /^xfs$/ && can_run('xfs_db')) {
        foreach (`xfs_db -r -c uuid $volumn`) {
          $serial = $1 if /^UUID =\s+(\S+)/;
            ;
          }
        foreach (`xfs_db -r -c label $volumn`) {
          $label = $1 if /^label =\s+"(\S+)"/;
        }
      } elsif ($type =~ /^vfat$/ && can_run('dosfslabel')) {
          chomp ($label = `dosfslabel /dev/sdb1`);
      }

      $label =~ s/\s+$//;
      $serial =~ s/\s+$//;



      $inventory->addDrives({
          CREATEDATE => $createdate,
          FREE => $free,
          FILESYSTEM => $filesystem,
          LABEL => $label,
          TOTAL => $total,
          TYPE => $type,
          VOLUMN => $volumn,
          SERIAL => $serial
        })
    }
  }
}

1;
