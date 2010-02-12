package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::PowerPC::Various;

use strict;

sub isInventoryEnabled { 1 };

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

############ Motherboard
  my $SystemManufacturer;
  my $SystemModel;
  my $SystemSerial;
  my $BiosManufacturer;
  my $BiosVersion;
  my $BiosDate;

 if (open SERIAL,"</proc/device-tree/serial-number") {
   $SystemSerial = <SERIAL>;
   $SystemSerial =~ s/[^\,^\.^\w^\ ]//g; # I remove some unprintable char
   close SERIAL;
 }

 if (open MODEL,"</proc/device-tree/model") {
   $SystemModel = <MODEL>;
   $SystemModel =~ s/[^\,^\.^\w^\ ]//g;
   close MODEL;
 }

 if (open COLOR,"</proc/device-tree/color-code") {
   my $tmp = <COLOR>;
   close COLOR;
   my ($color) = unpack "h7" , $tmp;
   $SystemModel = $SystemModel." color: $color" if $color;
 }

 if (open OPENBOOT,"</proc/device-tree/openprom/model") {
   $BiosVersion = <OPENBOOT>;
   $BiosVersion =~ s/[^\,^\.^\w^\ ]//g;
   close OPENBOOT;
 }

 if (open COPYRIGHT,"</proc/device-tree/copyright") {
   my $tmp = <COPYRIGHT>;
   close COPYRIGHT;

   if ($tmp =~ /Apple/) {
   # What about the Apple clone?
     $BiosManufacturer = "Apple Computer, Inc.";
     $SystemManufacturer = "Apple Computer, Inc." 
   }
 }
  
  $inventory->setBios ({
      SMANUFACTURER => $SystemManufacturer,
      SMODEL => $SystemModel,
      SSN => $SystemSerial,
      BMANUFACTURER => $BiosManufacturer,
      BVERSION => $BiosVersion,
      BDATE => $BiosDate,
    });

}

1
