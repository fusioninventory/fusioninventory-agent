package Ocsinventory::Agent::Backend::OS::HPUX::Bios;
use strict;

sub check { $^O =~ /hpux/ }

sub run { 
  my $params = shift;
  my $inventory = $params->{inventory};

  my $BiosVersion;
  my $BiosDate;
  my $SystemModel;
  my $SystemSerial;
  
  
  $SystemModel=`model`;
  for ( `echo 'sc product cpu;il' | /usr/sbin/cstm | grep "PDC Firmware"` ) {
    if ( /Revision:\s+(\S+)/ ) {
          $BiosVersion=$1;
        };
  };
  for ( `echo 'sc product system;il' | /usr/sbin/cstm | grep "System Serial Number"` ) {
    if ( /:\s+(\S+)/ ) {
          $SystemSerial=$1;
        };
  };


  $inventory->setBios ({
      BVERSION => "PDC $BiosVersion ",
      BDATE => $BiosDate,
      BMANUFACTURER => "HP",
      SMANUFACTURER => "HP",
      SMODEL => $SystemModel,
      SSN => $SystemSerial,
    });
}

1;
