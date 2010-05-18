package FusionInventory::Agent::Task::Inventory::OS::HPUX::Drives;

sub isInventoryEnabled  { can_run('fstyp') and can_run('grep') and can_run('bdf') }

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $type;
  my $fs;
  my $lv;
  my $total;
  my $free;

  for ( `fstyp -l | grep -v nfs` ) {
    chomp;
    $type=$_;
    for ( `bdf -t $type `) {
      next if ( /Filesystem/ );
      if ( /^(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+%)\s+(\S+)/ ) {
        $lv=$1;
        $total=$2;
        $free=$3;
        $fs=$6;
        $inventory->addDrive({
          FREE => $free,
          FILESYSTEM => $type,
          TOTAL => $total,
          TYPE => $fs,
          VOLUMN => $lv,
        })
      } elsif ( /^(\S+)\s/) {
        $lv=$1
      } elsif ( /(\d+)\s+(\d+)\s+(\d+)\s+(\d+%)\s+(\S+)/) {
        $total=$1;
        $free=$3;
        $fs=$5;
        # print "fs $fs lv $lv total $total free $free type $type\n";
        $inventory->addDrive({
          FREE => $free,
          FILESYSTEM => $type,
          TOTAL => $total,
          TYPE => $fs,
          VOLUMN => $lv,
        })
      }
    } # for bdf -t $type
  }
}

1;
