package Ocsinventory::Agent::Backend::OS::Linux::Storages;

use strict;
#use vars qw($runAfter);
#$runAfter = ["Ocsinventory::Agent::Backend::OS::Generic::Domains"];

sub check {1}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $partitions;
  my @values;


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
    my $manufacturer;
    my $model;
    my $description;
    my $media;
    my $type;
    my $capacity;
    my $firmware;
    my $serialnumber;

# Parse info from /sys
    if (open VENDOR, "/sys/block/$device/device/vendor") {
      chomp($manufacturer = <VENDOR>);
      $manufacturer =~ s/^(\w+)\W*/$1/;# remove spaces
      close VENDOR;
    }
    if (open MODEL, "/sys/block/$device/device/model") {
      chomp($model = <MODEL>);
      $model =~ s/^(\w+)\W*/$1/;
      close MODEL;
    }
    if (open REMOVABLE, "/sys/block/$device/removable") {
      chomp(my $removable = <REMOVABLE>);
# i guess it's an hard drive if the media is not removable
      $media = $removable?"removable":"disk";
      close REMOVABLE;
    }


# Old style, fetch data from /proc
    if(!$model) {
      if (open MODEL, "/proc/ide/$device/model") {
	chomp($model = <MODEL>);
	close MODEL;
      }
    }
    if (!$media) {
      if (open MEDIA, "/proc/ide/$device/media") {
	chomp($media = <MEDIA>);
	close MEDIA;
      }
    }

    if (!$manufacturer) {
      if($model =~ /(maxtor|western|sony|compaq|hewlett packard|ibm|seagate|toshiba|fujitsu|lg|samsung|nec)/i) {
	$manufacturer=$1;
      } elsif ($model =~ /^ST/) {
	$manufacturer="seagate";
      }
    }

    if ($device =~ /^s/) { # /dev/sd* are SCSI _OR_ SATA
      if ($manufacturer =~ /ATA/) {
	$description = "SATA";
      } else {
	$description = "SCSI";
      }
    } else {
      $description = "IDE";
    }
    chomp ($capacity = `fdisk -s /dev/$device 2>/dev/null`);
    $capacity = int ($capacity/1000) if $capacity;

    #Serial & Firmware
    `which hdparm 2>&1`;
    if (($? >> 8) == 0 ) {
      foreach (`hdparm -I /dev/$device`) {
         $serialnumber = $1 if /^\s+Serial Number\s*:\s*(.+)/i;
          $firmware = $1 if /^\s+Firmware Revision\s*:\s*(.+)/i;
      }
    }

    $inventory->addStorages({
	NAME => $device,
	MANUFACTURER => $manufacturer,
	MODEL => $model,
	DESCRIPTION => $description,
	TYPE => $media,
	DISKSIZE => $capacity,
	SERIALNUMBER => $serialnumber,
	FIRMWARE => $firmware,
      });

  }




}

1;
