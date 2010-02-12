package FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::3ware;

use FusionInventory::Agent::Task::Inventory::OS::Linux::Storages;
# Tested on 2.6.* kernels
#
# Cards tested :
#
# 8006-2LP
# 9500S-4LP
# 9550SXU-4LP
# 9550SXU-8LP
# 9650SE-2LP
# 9650SE-4LPML
# 9650SE-8LPML
#
# AMCC/3ware CLI (version 2.00.0X.XXX)

use strict;

sub isInventoryEnabled {

  my ($card, $res);
# Do we have tw_cli ?
  if (can_run("tw_cli")) {
    foreach (`tw_cli info`) {
      $card = $1 if /^(c\d+).*/;
      if ($card) {
        $res = `tw_cli info $card numdrives`;
        $card = undef;
        $res =~ s/^.*=\s(\d+)/$1/;
# Do we have drives on the card ?   
        ($res == 0)?return 0:return 1;
      }
    }
  }

}

sub doInventory {


  my $params = shift;
  my $inventory = $params->{inventory};
  my $logger = $params->{logger};

  my ($tw_cli, $hd);

  my ($card, $card_model, $unit, $unit_id, $port, $serialnumber, $serial, $model, $capacity, $firmware, $description, $media, $device, $manufacturer, $sn);

  my @devices = FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::getFromUdev();

# First, getting the cards : c0, c1... etc.
  foreach (`tw_cli info`) {

# Should output something like this :
#
# Ctl   Model        Ports   Drives   Units   NotOpt   RRate   VRate   BBU
# ------------------------------------------------------------------------
# c0    9650SE-2LP   2       2        1       0        1       1       -        

    if (/^(c\d)+\s+([\w|-]+)/) {
      $card = $1;
      $card_model = $2;
      $logger->debug("Card : $card - Model : $card_model");

    }
    if ($card) {

# Second, getting the units : u0, u1... etc.
      foreach (`tw_cli info $card`) {

# Example output :
#
# Unit  UnitType  Status         %RCmpl  %V/I/M  Stripe  Size(GB)  Cache  AVrfy
# ------------------------------------------------------------------------------
# u0    RAID-1    OK             -       -       -       65.1826   ON     OFF    
#
# Port   Status           Unit   Size        Blocks        Serial
# ---------------------------------------------------------------
# p0     OK               u0     69.25 GB    145226112     WD-WMANS1648590     
# p1     OK               u0     69.25 GB    145226112     WD-WMANS1344790     

        if (/^(u)(\d+).*/) {
          $unit = $1 . $2;
          $unit_id = $2;
        }
        if ($unit) {

# Try do get unit's serial in order to compare it to what was found in udev db.
# Works only on newer cards.
# Allow us to associate a node to a drive : sda -> WD-WMANS1648590
          $sn = `tw_cli info $card $unit serial 2> /dev/null`;
          $sn =~ s/^.*serial number\s=\s(\w*)\s*/$1/;

# Third, getting the ports : p0, p1... etc.
          foreach(`tw_cli info $card $unit`) {
            $port =  $1 if /^.*(p\d+).*/;
            if ($port) {

# Finally, getting drives' values.
              foreach (`tw_cli info $card $port model serial capacity firmware`) {

# Example output :      
#
# /c0/p0 Model = WDC WD740ADFD-00NLR4
# /c0/p0 Serial = WD-WMANS1648590
# /c0/p0 Capacity = 69.25 GB (145226112 Blocks)
# /c0/p0 Firmware Version = 21.07QR4

                $model = $1 if /^.*Model\s=\s(.*)/;
                $serialnumber = $1 if /^.*Serial\s=\s(.*)/;
                $capacity = 1024*$1 if /^.*Capacity\s=\s(\S+)\sGB.*/;
                $firmware = $1 if /^.*Firmware Version\s=\s(.*)/;
              }
              foreach $hd (@devices) {

# How does this work with multiple older cards where serial for units is not implemented ?
# Need to be tested on a system with multiple 3ware cards.
                if (($hd->{SERIALNUMBER} eq 'AMCC_' . $sn) or ($hd->{MODEL} eq 'Logical_Disk_' . $unit_id)) {
                  $device = %$hd->{NAME};
                }
              }

# Getting description from card model, very basic and unreliable
# Assuming only IDE drives can be plugged in 5xxx/6xxx cards and
# SATA drives only to 7xxx/8xxx/9xxxx cards
              $description = undef;
              foreach ($card_model) {
                $description = "IDE" if /^[5-6].*/;
                $description = "SATA" if /^[7-9].*/;
              }
              $media = 'disk';
              $manufacturer = FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::getManufacturer($model);
              $port = undef;
              $logger->debug("3ware: $device, $manufacturer, $model, $description, $media, $capacity, $serialnumber, $firmware");
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
            $port = undef;
          }
          $unit = undef;
        }
      }
      $card = undef;
      $card_model = undef;
    }
  }
}

1;
