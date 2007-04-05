package Ocsinventory::Agent::Backend::OS::Linux::Archs::PowerPC;
use strict;

sub check { 
  return unless -r "/proc/cpuinfo";
  my $arch = `arch`;
  return unless $arch =~ /^ppc/;
  1; 
};

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

######### CPU
  my $processort;
  my $processorn;
  my $processors;
  open CPUINFO, "</proc/cpuinfo" or warn;
  foreach(<CPUINFO>){
    $processort = $1 if (/^cpu\s*:\s*(.+)/i);
    $processorn++ if (/^processor/);
    $processors = $1 if (/^clock\s*:\s*(\d+?)\./i);
  }
  close CPUINFO;
  

  my $arch = `arch`;
  if ($arch eq "ppc64") {
    $processort = "PowerPC64 ".$processort;
  } else {
    $processort = "PowerPC ".$processort;
  }

  $inventory->setHardware({

      PROCESSORT => $processort,
      PROCESSORN => $processorn,
      PROCESSORS => $processors

    });


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
