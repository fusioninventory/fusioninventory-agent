package FusionInventory::Agent::Task::Inventory::OS::BSD::Drives;

use strict;

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $free;
  my $filesystem;
  my $total;
  my $type;
  my $volumn;


  for my $t ("ffs","ufs") {
# OpenBSD has no -m option so use -k to obtain results in kilobytes
    for(`df -P -t $t -k`){
      if(/^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\n/){
          $type = $1;
          $filesystem = $t;
          $total = sprintf("%i",$2/1024);
          $free = sprintf("%i",$4/1024);
          $volumn = $6;
  
        $inventory->addDrive({
            FREE => $free,
            FILESYSTEM => $filesystem,
            TOTAL => $total,
            TYPE => $type,
            VOLUMN => $volumn
          })
      }
    }
  }
}
1;
