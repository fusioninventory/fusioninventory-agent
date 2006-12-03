package Ocsinventory::Agent::Backend::OS::POSIX::Dmidecode::Bios;
use strict;
sub check {
  my $dmipath = `which dmidecode`;
  return 1 if $dmipath =~ /\w+/;
  0
}

sub run {
  my $inventory = shift;
# Parsing dmidecode output
# Using "type 0" section
  my( $SystemSerial , $SystemModel, $SystemManufacturer, $BiosManufacturer,
    $BiosVersion, $BiosDate, $YEAR, $MONTH, $DAY, $HOUR, $MIN, $SEC);

  my @dmidecode = `dmidecode`; # TODO retrive error
  s/^\s+// for (@dmidecode);


  my $flag=0;
  for(@dmidecode){
    $flag=1 if /dmi type 0,/i;
    if((/dmi type (\d+),/i) && ($flag)){($1!='0')?last:1;}
    if((/^vendor\s*:\s*(.+)/i) && ($flag)) { $BiosManufacturer = $1 }
    if((/^release date\s*:\s*(.+)/i) && ($flag)) { $BiosDate = $1 }
    if((/^version\s*:\s*(.+)/i) && ($flag)) { $BiosVersion = $1 }
  }

  $flag=0;
  for(@dmidecode){
    if(/dmi type 1,/i){$flag=1;}
    if((/dmi type (\d+),/i) && ($flag)){($1!='1')?last:1;}
    if((/^serial number\s*:\s*(.+?)\s*$/i) && ($flag)) { $SystemSerial = $1 }
    if((/^product name\s*:\s*(.+?)\s*$/i) && ($flag)) { $SystemModel = $1 }
    if((/^manufacturer\s*:\s*(.+?)\s*$/i) && ($flag)) { $SystemManufacturer = $1 }
  }

# Writing data
  $inventory->setBios ({
      SMANUFACTURER => $SystemManufacturer,
      SMODEL => $SystemModel,
      SSN => $SystemSerial,
      BMANUFACTURER => $BiosManufacturer,
      BVERSION => $BiosVersion,
      BDATE => $BiosDate,
    });
}

1;
