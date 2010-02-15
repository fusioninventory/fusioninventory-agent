package FusionInventory::Agent::Task::Inventory::OS::AIX::Bios;
use strict;

sub doInventory { $^O =~ /hpux/ }

sub run { 
  my $params = shift;
  my $inventory = $params->{inventory};

  my $BiosVersion;
  my $BiosDate;
  my $SystemModel;
  my $SystemSerial;
  
  
  $SystemModel=`model`;
  if ( `machinfo | grep 'Firmware revision' ` =~ /revision\s+=\s+(\S+)/ ) 
  {
     $BiosVersion=$1;
  }
  else
  {
     for ( `echo 'sc product cpu;il' | /usr/sbin/cstm | grep "PDC Firmware"` ) 
     {
        if ( /Revision:\s+(\S+)/ ) 
        {
             $BiosVersion="PDC $1";
        }
     }
  }

  for ( `echo 'sc product system;il' | /usr/sbin/cstm | grep "System Serial Number"` ) 
  {
      if ( /:\s+(\w+)/ ) 
      {
         $SystemSerial=$1;
      };
  };


  $inventory->setBios ({
      BVERSION => $BiosVersion,
      BDATE => $BiosDate,
      BMANUFACTURER => "HP",
      SMANUFACTURER => "HP",
      SMODEL => $SystemModel,
      SSN => $SystemSerial,
    });
}

1;
