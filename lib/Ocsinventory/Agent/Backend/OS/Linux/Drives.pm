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

  my %listVolume = ();
   
  # Get complementary information in hash tab
  if (can_run ("lshal")) {
    my %temp;
    my $in = 0;
    my $value;
    foreach my $line (`lshal`) {
      chomp $line;
      if ( $line =~ s{^udi = '/org/freedesktop/Hal/devices/volume.*}{}) {
        $in = 1;
        %temp = ();
      } elsif ($in == 1 and $line =~ s{^\s+(\S+) = (.*) \s*\((int|string|bool|string list|uint64)\)}{} ) {
        if ($3 ne 'int' and $3 ne 'uint64') {
          chomp($value = $2);
          if ($3 eq 'string') { 
            chop($value); 
            #$value =~ s/^'?(.*)'?$/$1/g;
            $value=substr($value,1,length($value));
            $value=substr($value,0,length($value)-1);
          }
          
          $temp{$1} = $value;
        } else {
          $temp{$1} = (split(/\W/,$2))[0];
        }
      }elsif ($in== 1 and $line eq '') {
        $in = 0 ;
        $listVolume{$temp{'block.device'}} = {%temp};
      }
    }
  }
  
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
      $filesystem = $2;
      $total = sprintf("%i",($3/1024));
      $type = $5;
      $volumn = $1;

# no virtual FS
      next if ($filesystem =~ /^(tmpfs|usbfs|proc|devpts|devshm|udev)$/);
      next if ($type =~ /^(tmpfs)$/);

      if ($filesystem =~ /^ext(2|3|4|4dev)/ && can_run('dumpe2fs')) {
        foreach (`dumpe2fs -h $volumn 2> /dev/null`) {
          if (/Filesystem UUID:\s+(\S+)/) {
            $serial = $1;
          } elsif (/Filesystem created:\s+\w+ (\w+) (\d+) ([\d:]+) (\d{4})$/) {
            $createdate = $4.'/'.$months{$1}.'/'.$2.' '.$3;
          } elsif (/Filesystem volume name:\s*(\S.*)/) {
            $label = $1 unless $1 eq '<none>';
          }
        }
      } elsif ($filesystem =~ /^xfs$/ && can_run('xfs_db')) {
        foreach (`xfs_db -r -c uuid $volumn`) {
          $serial = $1 if /^UUID =\s+(\S+)/;
            ;
          }
        foreach (`xfs_db -r -c label $volumn`) {
          $label = $1 if /^label =\s+"(\S+)"/;
        }
      } elsif ($filesystem =~ /^vfat$/ && can_run('dosfslabel')) {
          chomp ($label = `dosfslabel $volumn`);
      }

      $label =~ s/\s+$//;
      $serial =~ s/\s+$//;

      
      # Check information and improve it
      if (keys %listVolume) {
        if ( defined $listVolume{$volumn} ) {
          if ($filesystem eq '')  { $filesystem = $listVolume{$volumn}->{'volume.fstype'};}
          if ($label eq '')       { $label = $listVolume{$volumn}->{'volume.label'};}
          if ($total eq '')       { $total = int($listVolume{$volumn}->{'volume.size'}/(1024*1024) + 0.5);}
          if ($type eq '')        { $type = $listVolume{$volumn}->{'storage.model'};}
          if ($serial eq '')      { $serial = $listVolume{$volumn}->{'volume.uuid'};}
          delete ($listVolume{$volumn});
        }
      }

      $inventory->addDrive({
      	  CREATEDATE => $createdate,
          FREE => $free,
          FILESYSTEM => $filesystem,
          LABEL => $label,
          TOTAL => $total,
          TYPE => $type,
          VOLUMN => $volumn,
          SERIAL => $serial
        });
    }
  }

  if (can_run ("lshal")) {
    while (my ($k,$v) = each %listVolume ) {
      $inventory->addDrive({
        FILESYSTEM => $v->{'volume.fstype'},
        LABEL => $v->{'volume.label'},
        TOTAL => int ($v->{'volume.size'}/(1024*1024) + 0.5),
        TYPE => $v->{'storage.model'},
        VOLUMN => $k,
        SERIAL => $v->{'volume.uuid'}
      });
    }
  }  
}

1;
