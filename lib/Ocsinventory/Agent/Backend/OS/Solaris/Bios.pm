package Ocsinventory::Agent::Backend::OS::Solaris::Bios;

#Hostname: 157501s021plc
#Hostid: 83249bbf
#Release: 5.10
#Kernel architecture: sun4u
#Application architecture: sparc
#Hardware provider: Sun_Microsystems
#Domain: be.cnamts.fr
#Kernel version: SunOS 5.10 Generic_118833-17


use strict;

sub check {
	`showrev 2>&1`;
	return if ($? >> 8)!=0;
	1;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

# Parsing dmidecode output
# Using "type 0" section
  my( $SystemSerial , $SystemModel, $SystemManufacturer, $BiosManufacturer,
    $BiosVersion, $BiosDate);
    
  foreach(`showrev`){
  	if(/^Hostid:\s+(\S+)/){$SystemSerial = $1;}
  	if(/^Application architecture:\s+(\S+)/){$SystemModel = $1};
  	if(/^Hardware provider:\s+(\S+)/){$SystemManufacturer = $1};
  	#TODO We dont know get informations about Firmware (Bios) for Solaris System;
  }

 
  # Writing data
  $inventory->setBios ({
      SMANUFACTURER => $SystemManufacturer,
      SMODEL => $SystemModel,
      SSN => $SystemSerial     
    });
}

1;
