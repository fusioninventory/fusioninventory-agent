package FusionInventory::Agent::Task::Inventory::OS::AIX::Mem;
use strict;

sub doInventory { $^O =~ /hpux/ }

sub run { 
  my $params = shift;
  my $inventory = $params->{inventory};

  my $mem;
  my $swap;

  $mem = `grep Physical /var/adm/syslog/syslog.log|tr -s " "|cut -f 7 -d " "` ;
  if ( $mem eq "" ) {
      $mem = `grep Physical /var/adm/syslog/OLDsyslog.log|tr -s " "|cut -f 7 -d " "` ;
  };
  $mem = int ($mem/1024);

  $swap = `swapinfo -mdfq`;


  $inventory->setHardware({
      MEMORY =>  $mem,
      SWAP =>    $swap,
			 });
}

1;
