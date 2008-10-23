package Ocsinventory::Agent::Backend::OS::Linux::Storages;

use strict;

sub check {1}

sub getFromSysProc {
  my($dev, $file) = @_;
  my (@files, my $value);
  @files = ("/sys/block/$dev/device/$file", "/proc/ide/$dev/$file");
  foreach (@files) {
    next unless open PATH, $_;
    chomp(my $value = <PATH>);
    $value =~ s/^(\w+)\W*/$1/;
    return $value;    
  }
}

sub getFromUdev {
  my @devs;
  foreach (glob ("/dev/.udev/db/*")) {
    my ($scsi_coid, $scsi_chid, $scsi_unid, $scsi_lun, $path, $device, $vendor, $model, $revision, $serial, $serial_short, $type, $bus, $capacity);
    if (/^(\/dev\/.udev\/db\/.*)([sh]d[a-z])$/) {
      $path = $1;
      $device = $2;
      open (PATH, $1 . $2);
      while (<PATH>) {
        if (/^S:.*-scsi-(\d+):(\d+):(\d+):(\d+)/) {
          $scsi_coid = $1;
          $scsi_chid = $2;
          $scsi_unid = $3;
          $scsi_lun = $4;
        }
        $vendor = $1 if /^E:ID_VENDOR=(.*)/; 
        $model = $1 if /^E:ID_MODEL=(.*)/; 
        $revision = $1 if /^E:ID_REVISION=(.*)/;
        $serial = $1 if /^E:ID_SERIAL=(.*)/;
        $serial_short = $1 if /^E:ID_SERIAL_SHORT=(.*)/;
        $type = $1 if /^E:ID_TYPE=(.*)/;
        $bus = $1 if /^E:ID_BUS=(.*)/;
      }
      $capacity = getCapacity($device);
      push (@devs, {NAME => $device, MANUFACTURER => $vendor, MODEL => $model, DESCRIPTION => $bus, TYPE => $type, DISKSIZE => $capacity, SERIALNUMBER => $serial_short, FIRMWARE => $revision, SCSI_COID => $scsi_coid, SCSI_CHID => $scsi_chid, SCSI_UNID => $scsi_unid, SCSI_LUN => $scsi_lun});
      close (PATH);
    }
  }
  return @devs;
}

sub getCapacity {
  my ($dev) = @_;
  my $cap;
  chomp ($cap = `fdisk -s /dev/$dev 2>/dev/null`); #requires permissions on /dev/$dev
  $cap = int ($cap/1000) if $cap;
  return $cap;
}

sub getDescription {
  my ($name, $manufacturer, $description) = @_;

# detected as USB by udev
# TODO maybe we should trust udev detection by default?
  return "USB" if (defined ($description) && $description =~ /usb/i);

  if ($name =~ /^s/) { # /dev/sd* are SCSI _OR_ SATA
    if ($manufacturer =~ /ATA/) {
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
  }
  elsif ($model =~ /^HP/) {
    return "Hewlett Packard";
  }
  elsif ($model =~ /^WDC/) {
    return "Western Digital";
  }
  elsif ($model =~ /^ST/) {
    return "Seagate";
  }
  elsif ($model =~ /^HD/ or $model =~ /^IC/ or $model =~ /^HU/) {
    return "Hitachi";
  }
}

sub run {
  my $params = shift;
  my $logger = $params->{logger};
  my $inventory = $params->{inventory};

#Get hard drives values from udev, should work with any 2.6* kernel
  my @devices = getFromUdev();

#  foreach my $hd (@devices) {
#    $logger->debug("Udev: $hd->{NAME}, $hd->{MANUFACTURER}, $hd->{MODEL}, $hd->{DESCRIPTION}, $hd->{TYPE}, $hd->{DISKSIZE}, $hd->{SERIALNUMBER}, $hd->{FIRMWARE}");
#  }

#Get hard drives values from sys or proc in case getting them throught udev doesn't work
  if (!@devices) {
    my ($manufacturer, $model, $media, $firmware, $serialnumber, $capacity, $partitions, $description);
    foreach (glob ("/sys/block/*")) {# /sys fs style
      $partitions->{$1} = undef
        if (/^\/sys\/block\/([sh]d[a-z])$/)
    }
    foreach (`fdisk -l`) {# call fdisk to list partitions
      chomp;
      next unless (/^\//);
      $partitions->{$1} = undef
        if (/^\/dev\/([sh]d[a-z])/);
    }
    foreach my $device (keys %$partitions) {

      $manufacturer = getFromSysProc($device, "vendor");
      $model = getFromSysProc($device, "model");
      $media = getFromSysProc($device, "removable")?"removable":"disk";
      $firmware = getFromSysProc($device, "rev");
      $serialnumber = getFromSysProc($device, "serial");



#      $logger->debug("Sys: $device, $manufacturer, $model, $description, $media, $capacity, $serialnumber, $firmware");

      push (@devices, {NAME => $device, MANUFACTURER => $manufacturer, MODEL => $model, DESCRIPTION => $description, TYPE => $media, DISKSIZE => $capacity, SERIALNUMBER => $serialnumber, FIRMWARE => $firmware});

    }

  }


  if (can_run("hdparm")) {
    foreach my $hd (@devices) {
#Serial & Firmware
      if (!$hd->{SERIALNUMBER} || !$hd->{FIRMWARE}) {
        my $cmd = "hdparm -I /dev/".$hd->{NAME}." 2> /dev/null";
        foreach (`$cmd`) {
          if (/^\s+Serial Number\s*:\s*(.+)/ && !$hd->{SERIALNUMBER}) {
            $hd->{SERIALNUMBER} = $1;
          }
          if (/^\s+Firmware Revision\s*:\s*(.+)/i && !$hd->{FIRMWARE}) {
            $hd->{FIRMWARE} = $1;
          }
        }
      }
    }
  }


  foreach my $hd (@devices) {
    if (($hd->{MANUFACTURER} ne 'AMCC') and ($hd->{MANUFACTURER} ne '3ware') and ($hd->{MODEL} ne '') and ($hd->{MANUFACTURER} ne 'LSILOGIC') and ($hd->{MANUFACTURER} ne 'Adaptec')) {
      $hd->{DESCRIPTION} = getDescription($hd->{NAME}, $hd->{MANUFACTURER}, $hd->{DESCRIPTION});

      if (!$hd->{MANUFACTURER} or $hd->{MANUFACTURER} eq 'ATA') {
        $hd->{MANUFACTURER} = getManufacturer($hd->{MODEL});
      }

      $hd->{CAPACITY} = getCapacity($hd->{NAME});
      $hd->{MANUFACTURER} = getManufacturer($hd->{MODEL});

#      $logger->debug("Add: $hd->{NAME}, $hd->{MANUFACTURER}, $hd->{MODEL}, $hd->{DESCRIPTION}, $hd->{TYPE}, $hd->{DISKSIZE}, $hd->{SERIALNUMBER}, $hd->{FIRMWARE}");

      $inventory->addStorages({
          NAME => %$hd->{NAME},
          MANUFACTURER => %$hd->{MANUFACTURER},
          MODEL => %$hd->{MODEL},
          DESCRIPTION => %$hd->{DESCRIPTION},
          TYPE => %$hd->{TYPE},
          DISKSIZE => %$hd->{DISKSIZE},
          SERIALNUMBER => %$hd->{SERIALNUMBER},
          FIRMWARE => %$hd->{FIRMWARE}
          });  

    }

  }  

}

1;
