package Ocsinventory::Agent::Backend::OS::Generic::Dmidecode::Bios;
use strict;

sub check {1}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

# Parsing dmidecode output
# Using "type 0" section
  my( $SystemSerial , $SystemModel, $SystemManufacturer, $BiosManufacturer,
    $BiosVersion, $BiosDate, $YEAR, $MONTH, $DAY, $HOUR, $MIN, $SEC);

  my @dmidecode = `dmidecode`; # TODO retrive error
  s/^\s+// for (@dmidecode);


  my $flag=0;
  for(@dmidecode){
    $flag=1 if /dmi type 0,/i;
    last if($flag && (/dmi type (\d+),/i) && ($1!=0));
    if((/^vendor:\s*(\S+)/i) && ($flag)) { $BiosManufacturer = $1 }
    if((/^release dates:\s*(\S+)/i) && ($flag)) { $BiosDate = $1 }
    if((/^version:\s*(\S+)/i) && ($flag)) { $BiosVersion = $1 }
  }

  $flag=0;
  for(@dmidecode){
    if(/dmi type 1,/i){$flag=1;}
    last if($flag && (/dmi type (\d+),/i) && ($1!=1));
    if((/^serial number*:\s*(\S+)/i) && ($flag)) { $SystemSerial = $1 }
    if((/^product name:\s*(\S+)/i) && ($flag)) { $SystemModel = $1 }
    if((/^manufacturer:\s*(\S+)/i) && ($flag)) { $SystemManufacturer = $1 }
  }

  $flag=0;
  for(@dmidecode){
    if(/dmi type 2,/i){$flag=1;}
    last if($flag && (/dmi type (\d+),/i) && ($1!=2));
    if((/^serial number:\s*(\S+)/i) && ($flag) && (!$SystemSerial)) { $SystemSerial = $1 }
    if((/^product name:\s*(\S+)/i) && ($flag) && (!$SystemModel)) { $SystemModel = $1 }
    if((/^manufacturer:\s*(\S+)/i) && ($flag) && (!$SystemManufacturer)) { $SystemManufacturer = $1 }
  }

# Some bad bioses don't provide a serial number so I check for CPU ID (e.g: server from dedibox.fr)
  if (!$SystemSerial) {
    $flag=0;
    for(@dmidecode){
      if(/dmi type 4,/i){$flag=1;}
      elsif(/^processor information:/i){$flag=2;}
      elsif((/^ID:\s*(.*)/i) && ($flag)) {
	$SystemSerial = $1;
	$SystemSerial =~ s/\ /-/g;
	last
      }
    }
  }

  print "
      SMANUFACTURER => $SystemManufacturer\n
      SMODEL => $SystemModel\n
      SSN => $SystemSerial\n
      BMANUFACTURER => $BiosManufacturer\n
      BVERSION => $BiosVersion\n
      BDATE => $BiosDate\n";
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
