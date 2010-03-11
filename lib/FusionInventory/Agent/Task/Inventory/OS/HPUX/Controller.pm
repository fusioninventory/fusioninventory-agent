package FusionInventory::Agent::Task::Inventory::OS::AIX::Controller;
use strict;

sub isInventoryEnabled { $^O =~ /hpux/ }

sub doInventory { 
  my $params = shift;
  my $inventory = $params->{inventory};

  my $name;
  my $interface;
  my $info;
  my $type;
  my @typeScaned=('ext_bus','fc','psi');
  my $scaned;

  for (@typeScaned ) {
    $scaned=$_;
    for ( `ioscan -kFC $scaned| cut -d ':' -f 9,11,17,18` ) {
       if ( /(\S+):(\S+):(\S+):(.+)/ ) {
           $name=$2;
           $interface=$3;
           $info=$4;
           $type=$1;
           $inventory->addController({
                        'NAME'          => $name,
                        'MANUFACTURER'  => "$interface $info",
                        'TYPE'          => $type,
           });
        };
     };
  };
}

1;
