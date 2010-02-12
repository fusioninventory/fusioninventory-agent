package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios;
use strict;

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

# Parsing dmidecode output
# Using "type 0" section
  my( $SystemSerial , $SystemModel, $SystemManufacturer, $BiosManufacturer,
    $BiosVersion, $BiosDate, $YEAR, $MONTH, $DAY, $HOUR, $MIN, $SEC, $AssetTag);

  my @dmidecode = `dmidecode`;
  s/^\s+// for (@dmidecode);

  # get the BIOS values
  my $flag=0;
  for(@dmidecode){
    $flag=1 if /dmi type 0,/i;
    last if($flag && (/dmi type (\d+),/i) && ($1!=0));
    if((/^vendor:\s*(.+?)(\s*)$/i) && ($flag)) { $BiosManufacturer = $1 }
    if((/^release\ date:\s*(.+?)(\s*)$/i) && ($flag)) { $BiosDate = $1 }
    if((/^version:\s*(.+?)(\s*)$/i) && ($flag)) { $BiosVersion = $1 }
  }
 
  # Try to query the machine itself 
  $flag=0;
  for(@dmidecode){
    if(/dmi type 1,/i){$flag=1;}
    last if($flag && (/dmi type (\d+),/i) && ($1!=1));
    if((/^serial number:\s*(.+?)(\s*)$/i) && ($flag)) { $SystemSerial = $1 }
    if((/^(product name|product):\s*(.+?)(\s*)$/i) && ($flag)) { $SystemModel = $2 }
    if((/^(manufacturer|vendor):\s*(.+?)(\s*)$/i) && ($flag)) { $SystemManufacturer = $2 }
  }

  # Failback on the motherbord
  $flag=0;
  for(@dmidecode){
    if(/dmi type 2,/i){$flag=1;}
    last if($flag && (/dmi type (\d+),/i) && ($1!=2));
    if((/^serial number:\s*(.+?)(\s*)/i) && ($flag) && (!$SystemSerial)) { $SystemSerial = $1 }
    if((/^product name:\s*(.+?)(\s*)/i) && ($flag) && (!$SystemModel)) { $SystemModel = $1 }
    if((/^manufacturer:\s*(.+?)(\s*)/i) && ($flag) && (!$SystemManufacturer)) { $SystemManufacturer = $1 }
  }

  $flag=0;
  for(@dmidecode){
      if ($flag) {
          if (/^Asset Tag:\s*(.+\S)/i) {
              $AssetTag = $1;
              $AssetTag = '' if $AssetTag eq 'Not Specified';
              last;
          } elsif (/dmi type \d+,/i) {  # End of the section
              last;
          }
      }
      if (/dmi type 3,/i) {
          $flag=1;
      }
  }

# Some bioses don't provide a serial number so I check for CPU ID (e.g: server from dedibox.fr)
  if (!$SystemSerial ||$SystemSerial =~ /^0+$/) {
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

# Writing data
  $inventory->setBios ({
      ASSETTAG => $AssetTag,
      SMANUFACTURER => $SystemManufacturer,
      SMODEL => $SystemModel,
      SSN => $SystemSerial,
      BMANUFACTURER => $BiosManufacturer,
      BVERSION => $BiosVersion,
      BDATE => $BiosDate,
    });
}

1;
