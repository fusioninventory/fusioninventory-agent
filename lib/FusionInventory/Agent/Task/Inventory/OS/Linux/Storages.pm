package FusionInventory::Agent::Task::Inventory::OS::Linux::Storages;

use strict;

sub isInventoryEnabled {1}

######## TODO
# Do not remove, used by other modules
sub getFromUdev {
  my @devs;

  foreach my $file (glob ("/dev/.udev/db/*")) {
    next unless $file =~ /([sh]d[a-z])$/;
    my $device = $1;
    push (@devs, parseUdev($file, $device));
  }

  return @devs;
}


sub getFromSysProc {
  my($dev, $file) = @_;

  my $value;
  foreach ("/sys/block/$dev/device/$file", "/proc/ide/$dev/$file") {
    next unless open PATH, $_;
    chomp(my $value = <PATH>);
    $value =~ s/^(\w+)\W*/$1/;
    return $value;
  }
}


sub getCapacity {
  my ($dev) = @_;
  my $cap;
  if ( `fdisk -v` =~ '^GNU.*') {
    chomp ($cap = `fdisk -p -s /dev/$dev 2>/dev/null`); #requires permissions on /dev/$dev
  } else {
    chomp ($cap = `fdisk -s /dev/$dev 2>/dev/null`); #requires permissions on /dev/$dev
  }
  $cap = int ($cap/1000) if $cap;
  return $cap;
}

sub getDescription {
  my ($name, $manufacturer, $description, $serialnumber) = @_;

# detected as USB by udev
# TODO maybe we should trust udev detection by default?
  return "USB" if (defined ($description) && $description =~ /usb/i);

  if ($name =~ /^s/) { # /dev/sd* are SCSI _OR_ SATA
    if ($manufacturer =~ /ATA/ || $serialnumber =~ /ATA/) {
      return  "SATA";
    } else {
      return "SCSI";
    }
  } else {
    return "IDE";
  }
}

sub getManufacturer {
  my ($model) = @_;
  if($model =~ /(maxtor|western|sony|compaq|hewlett packard|ibm|seagate|toshiba|fujitsu|lg|samsung|nec|transcend)/i) {
    return ucfirst(lc($1));
  } elsif ($model =~ /^HP/) {
    return "Hewlett Packard";
  } elsif ($model =~ /^WDC/) {
    return "Western Digital";
  } elsif ($model =~ /^ST/) {
    return "Seagate";
  } elsif ($model =~ /^HD/ or $model =~ /^IC/ or $model =~ /^HU/) {
    return "Hitachi";
  }
}

# some hdparm release generated kernel error if they are
# run on CDROM device
# http://forums.ocsinventory-ng.org/viewtopic.php?pid=20810
sub correctHdparmAvailable {
  return unless can_run("hdparm");
  my $hdparmVersion = `hdparm -V`;
  if ($hdparmVersion =~ /^hdparm v(\d+)\.(\d+)(\.|$)/) {
    return 1 if $1>9;
    return 1 if $1==9 && $2>=15;
  }
  return;
}


sub doInventory {
  my $params = shift;
  my $logger = $params->{logger};
  my $inventory = $params->{inventory};

  my $devices = {};

  # Get complementary information in hash tab
  if (can_run ("lshal")) {


    my %temp;
    my $in = 0;
    my $value;
    foreach my $line (`lshal`) {
      chomp $line;
      if ( $line =~ s{^udi = '/org/freedesktop/Hal/devices/(storage|legacy_floppy|block).*}{}) {
        $in = 1;
        %temp = ();
      } elsif ($in == 1 and $line =~ s{^\s+(\S+) = (.*) \s*\((int|string|bool|string list|uint64)\)}{} ) {
        my $key = $1;
        my $value = $2;
        $value =~ s/^'(.*)'\s*$/$1/; # Drop the quote
        $value =~ s/\s+$//; # Drop the trailing white space

        if ($key eq 'storage.serial') {
          $temp{SERIALNUMBER} = $value;
        } elsif ($key eq 'storage.firmware_version') {
          $temp{FIRMWARE} = $value;
        } elsif ($key eq 'block.device') {
          $value =~ s/\/dev\/(\S+)/$1/;
          $temp{NAME} = $value;
        } elsif ($key eq 'info.vendor') {
          $temp{MANUFACTURER} = $value;
        } elsif ($key eq 'storage.model') {
          $temp{MODEL} = $value;
        } elsif ($key eq 'storage.drive_type') {
          $temp{TYPE} = $value;
        } elsif ($key eq 'storage.size') {
          $temp{DISKSIZE} = int($value/(1024*1024) + 0.5);
        }


      }elsif ($in== 1 and $line eq '' and $temp{NAME}) {
        $in = 0 ;
        $devices->{$temp{NAME}} = {%temp};
      }
    }
  }



  foreach (glob ("/dev/.udev/db/*")) {
    if (/^(\/dev\/.udev\/db\/.*)([sh]d[a-z])$/) {
      my $path = $1;
      my $device = $2;
      my $serial_short;

      open (PATH, $1 . $2);
      while (<PATH>) {
        if (/^S:.*-scsi-(\d+):(\d+):(\d+):(\d+)/) {

          # Not accepted yet in the final XML
          $devices->{$device}->{SCSI_COID} = $1;
          $devices->{$device}->{SCSI_CHID} = $2;
          $devices->{$device}->{SCSI_UNID} = $3;
          $devices->{$device}->{SCSI_LUN} = $4;

        }

        if (!$devices->{$device}->{MANUFACTURER} && /^E:ID_VENDOR=(.*)/) {
          $devices->{$device}->{MANUFACTURER} = $1;
        }
        if (!$devices->{$device}->{SERIALNUMBER} && /^E:ID_SERIAL=(.*)/) {
          $devices->{$device}->{SERIALNUMBER} = $1;
        }
        if (!$devices->{$device}->{TYPE} && /^E:ID_TYPE=(.*)/) {
          $devices->{$device}->{TYPE} = $1;
        }
        if (!$devices->{$device}->{DESCRIPTION} && /^E:ID_BUS=(.*)/) {
          $devices->{$device}->{DESCRIPTION} = $1;
        }

      }

      if (!$devices->{$device}->{SERIALNUMBER}) {
        $devices->{$device}->{SERIALNUMBER} = $serial_short;
      }
      if (!$devices->{$device}->{DISKSIZE}) {
        $devices->{$device}->{DISKSIZE} = getCapacity($device)
            if $devices->{$device}->{TYPE} ne 'cd';
      }
      close (PATH);
    }
  }




#Get hard drives values from sys or proc in case getting them throught udev doesn't work
  if (!%$devices) {
    my ($manufacturer, $model, $media, $firmware, $serialnumber, $capacity, $partitions, $description);
    foreach (glob ("/sys/block/*")) {# /sys fs style
      $partitions->{$1} = undef
        if (/^\/sys\/block\/([sh]d[a-z]|fd\d)$/)
    }
    
    if ( `fdisk -v` =~ '^GNU.*') {
      foreach (`fdisk -p -l`) {# call fdisk to list partitions
        chomp;
        next unless (/^\//);
        $partitions->{$1} = undef
          if (/^\/dev\/([sh]d[a-z])/);
      }
    } else {
      foreach (`fdisk -l`) {# call fdisk to list partitions
        chomp;
        next unless (/^\//);
        $partitions->{$1} = undef
          if (/^\/dev\/([sh]d[a-z])/);
      }
    }

    foreach my $device (keys %$partitions) {

      if (!$devices->{$device}->{MANUFACTURER}) {
        $devices->{$device}->{MANUFACTURER} = getFromSysProc($device, "vendor");
      }
      if (!$devices->{$device}->{MODEL}) {
        $devices->{$device}->{MODEL} = getFromSysProc($device, "model");
      }
      if (!$devices->{$device}->{TYPE}) {
        $devices->{$device}->{TYPE} = getFromSysProc($device, "removable")?"removable":"disk";
      }
      if (!$devices->{$device}->{FIRMWARE}) {
        $devices->{$device}->{FIRMWARE} = getFromSysProc($device, "rev");
      }
      if (!$devices->{$device}->{SERIALNUMBER}) {
        $devices->{$device}->{SERIALNUMBER} = getFromSysProc($device, "serial");
      }




#      $logger->debug("Sys: $device, $manufacturer, $model, $description, $media, $capacity, $serialnumber, $firmware");


    }
  }


  if (correctHdparmAvailable()) {
    foreach my $device (keys %$devices) {
#Serial & Firmware
      if (!$devices->{$device}->{SERIALNUMBER} || !$devices->{$device}->{FIRMWARE}) {
        my $cmd = "hdparm -I /dev/".$devices->{$device}->{NAME}." 2> /dev/null";
        foreach (`$cmd`) {
          if (/^\s+Serial Number\s*:\s*(.+)/ && !$devices->{$device}->{SERIALNUMBER}) {
            my $serialnumber = $1;
            $serialnumber =~ s/\s+$//;
            $devices->{$device}->{SERIALNUMBER} = $serialnumber;
          }
          if (/^\s+Firmware Revision\s*:\s*(.+)/i && !$devices->{$device}->{FIRMWARE}) {
            my $firmware = $1;
            $firmware =~ s/\s+$//;
            $devices->{$device}->{FIRMWARE} = $firmware;
          }
        }
      }
    }
  }

  foreach my $device (keys %$devices) {

    $devices->{$device}->{DESCRIPTION} = getDescription(
      $devices->{$device}->{NAME},
      $devices->{$device}->{MANUFACTURER},
      $devices->{$device}->{DESCRIPTION},
      $devices->{$device}->{SERIALNUMBER}
    );

    if (!$devices->{$device}->{MANUFACTURER} or $devices->{$device}->{MANUFACTURER} eq 'ATA') {
      $devices->{$device}->{MANUFACTURER} = getManufacturer($devices->{$device}->{MODEL});
    }

    if ($devices->{$device}->{CAPACITY} =~ /^cd/) {
      $devices->{$device}->{CAPACITY} = getCapacity($devices->{$device}->{NAME});
    }

    $inventory->addStorages($devices->{$device});
  }

}

sub parseUdev {
  my ($file, $device) = @_;

  my ($result, $serial);

  open (my $handle, '<', $file);
  while (my $line = <$handle>) {
    if ($line =~ /^S:.*-scsi-(\d+):(\d+):(\d+):(\d+)/) {
      $result->{SCSI_COID} = $1;
      $result->{SCSI_CHID} = $2;
      $result->{SCSI_UNID} = $3;
      $result->{SCSI_LUN} = $4;
    } elsif ($line =~ /^E:ID_VENDOR=(.*)/) {
      $result->{MANUFACTURER} = $1;
    } elsif ($line =~ /^E:ID_MODEL=(.*)/) {
      $result->{MODEL} = $1;
    } elsif ($line =~ /^E:ID_REVISION=(.*)/) {
      $result->{FIRMWARE} = $1;
    } elsif ($line =~ /^E:ID_SERIAL=(.*)/) {
      $serial = $1;
    } elsif ($line =~ /^E:ID_SERIAL_SHORT=(.*)/) {
      $result->{SERIALNUMBER} = $1;
    } elsif ($line =~ /^E:ID_TYPE=(.*)/) {
      $result->{TYPE} = $1;
    } elsif ($line =~ /^E:ID_BUS=(.*)/) {
      $result->{DESCRIPTION} = $1;
    }
  }
  close ($handle);

  $result->{SERIALNUMBER} = $serial
    unless $result->{SERIALNUMBER} =~ /\S/;

  $result->{DISKSIZE} = getCapacity($device)
    if $result->{TYPE} ne 'cd';

  $result->{NAME} = $device;

  return $result;
}

1;
